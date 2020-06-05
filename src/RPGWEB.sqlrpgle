        ctl-opt option(*nodebugio:*srcstmt) nomain;
        /include RPGWEB/QRPGLESRC,RPGWEB_H

        dcl-proc RPGWEB_start export;
          dcl-pi *n;
            config likeds(RPGWEBAPP);
            port int(10:0) options(*nopass) const;
          end-pi;
          dcl-s index int(10:0) inz;
          dcl-s index2 int(10:0) inz;
          dcl-s route_found ind inz;
          dcl-ds response likeds(RPGWEBRSP) inz;
          dcl-ds request likeds(RPGWEBRQST) inz;
          dcl-s continue_request ind;

          if config.port = 0 and %parms < 2;
            config.port = 3000;
          elseif %parms = 2;
            config.port = port;
          endif;

          if (RPGWEB_setup(config));
            dow 1 = 1;
              monitor;
                clear request;
                request = RPGWEB_acceptRequest(config);

                clear response;
                clear route_found;
                continue_request = *on;

                // run middlewares
                for index2 = 1 to %elem(config.middlewares) by 1;
                  if continue_request;
                    if config.middlewares(index2).url <> *blanks;
                      if RPGWEB_mwMatches(config.middlewares(index2) : 
                                          request);
                        RPGWEB_mwCallback_ptr = 
                          config.middlewares(index2).procedure;
                        continue_request = 
                            RPGWEB_mwCallback(request : response);
                      endif;
                    else;
                      index2 = %elem(config.middlewares) + 1;
                    endif;
                  else;
                    index2 = %elem(config.middlewares) + 1;
                  endif;
                endfor;

                // run routes
                if continue_request;
                  for index = 1 to %elem(config.routes) by 1;
                    if (config.routes(index).url <> *blanks);
                      if RPGWEB_routeMatches(config.routes(index) : request);
                        RPGWEB_callback_ptr = config.routes(index).procedure;
                        response = RPGWEB_callback(request);
                        route_found = *on;
                        index = %elem(config.routes) + 1;
                      endif;
                    else;
                      index = %elem(config.routes) + 1;
                    endif;
                  endfor;
                endif;
                
                // look for static content
                if not route_found and continue_request;
                  if RPGWEB_contentFound(config.static_content : request.route);
                    route_found = *on;
                    response = RPGWEB_loadStaticContent(config : request);
                  endif;
                endif;

                // end of the rope just 404 it
                if not route_found and continue_request;
                  response = RPGWEB_setResponse(request :  HTTP_NOT_FOUND);
                endif;

                RPGWEB_sendResponse(config : response);
              on-error;
                response = RPGWEB_setResponse(request : 
                                              HTTP_INTERNAL_SERVER);
              endmon;
            enddo;
          else;
            RPGWEB_log('RPGWEB - Could not setup the application.');
            RPGWEB_log(RPGWEB_CRLF);
            RPGWEB_log('RPGWEB - Please see earlier logs for reason.');
            RPGWEB_log(RPGWEB_CRLF);
          endif;

          RPGWEB_stop(config);
        end-proc;



        dcl-proc RPGWEB_stop export;
          dcl-pi *n;
            config likeds(RPGWEBAPP) const;
          end-pi;

          close_port( config.return_socket_descriptor );
          close_port( config.socket_descriptor );
        end-proc;



        dcl-proc RPGWEB_acceptRequest export;
          dcl-pi *n likeds(RPGWEBRQST);
            config likeds(RPGWEBAPP);
          end-pi;
          dcl-ds socket_address likeds(socketaddr);
          dcl-s data char(32766);
          dcl-s return_code int(10:0) inz(0);

          clear socket_address;
          socket_address.sin_family = AF_INET;
          socket_address.sin_port = config.port;
          socket_address.sin_addr = INADDR_ANY;
          config.return_socket_descriptor = accept( config.socket_descriptor :
                                %addr(socket_address) :
                                socketaddrlena );
          return_code = read( config.return_socket_descriptor :
                              %addr(data) :
                              %size(data) );

          RPGWEB_translate( %len(%trim(data)) : data : 
                            'QJSONIN' : 'RPGWEB');
          return RPGWEB_parse(data);
        end-proc;



        dcl-proc RPGWEB_parse;
          dcl-pi *n likeds(RPGWEBRQST);
            raw_request varchar(32000) const;
          end-pi;
          dcl-ds request likeds(RPGWEBRQST);
          dcl-s line char(1024);
          dcl-s start int(10:0);
          dcl-s stop int(10:0);
          dcl-s position int(10:0);
          dcl-s raw_headers char(32000);
          dcl-s parts char(1024) dim(50);
          dcl-s pieces char(1024) dim(2);
          dcl-s index int(10:0);

          clear request;
          position = %scan(RPGWEB_CRLF : raw_request);
          start = 1;
          stop = position;
          line = %subst(raw_request:start:stop);

          parts = RPGWEB_split(line : ' ');
          request.method = parts(1);
          request.route = parts(2);
          request.protocol = parts(3);

          start = 0;
          start = %scan('?' : request.route);

          if start > 0;
            request.query_string =
                  RPGWEB_cleanString(%subst(request.route : start + 1));
            request.route = %subst(request.route : 1 : start - 1);
          endif;

          parts = RPGWEB_split(request.query_string : '&');
          for index = 1 to %elem(parts) by 1;
            if parts(index) <> *blanks;
              pieces = RPGWEB_split(parts(index) : '=');
              request.query_params(index).name = pieces(1);
              request.query_params(index).value = %trim(pieces(2));
            else;
              index = %elem(parts) + 1;
            endif;
          endfor;

          start = stop + 1;
          stop = %scan(RPGWEB_DBL_CRLF : raw_request);
          raw_headers = %subst(raw_request : start : stop - start);
          parts = RPGWEB_split(raw_headers : RPGWEB_CRLF);

          for index = 1 to %elem(parts) by 1;
            if parts(index) <> *blanks;
              pieces = RPGWEB_split(parts(index) : ':');
              request.headers(index).name = pieces(1);
              request.headers(index).value = %trim(pieces(2));
            else;
              index = %elem(parts) + 1;
            endif;
          endfor;

          start = stop + 1;
          request.body = RPGWEB_cleanString(%subst(raw_request : start ));

          return request;
        end-proc;
      


        dcl-proc RPGWEB_getParam export;
          dcl-pi *n varchar(1024);
            request likeds(RPGWEBRQST) const;
            param char(50) const;
          end-pi;
          dcl-s param_value varchar(1024);
          dcl-s index int(10:0);

          clear param_value;
          for index = 1 to %elem(request.params) by 1;
            if RPGWEB_toUpper(request.params(index).name) =
              RPGWEB_toUpper(param);
              param_value = request.params(index).value;
              index = %elem(request.params) + 1;
            endif;
          endfor;

          return %trim(param_value);
        end-proc;


        dcl-proc RPGWEB_getQueryParam export;
          dcl-pi *n varchar(1024);
            request likeds(RPGWEBRQST) const;
            param char(50) const;
          end-pi;
          dcl-s param_value varchar(1024);
          dcl-s index int(10:0);

          clear param_value;
          for index = 1 to %elem(request.query_params) by 1;
            if RPGWEB_toUpper(request.query_params(index).name) =
              RPGWEB_toUpper(param);
              param_value = request.query_params(index).value;
              index = %elem(request.query_params) + 1;
            endif;
          endfor;

          return %trim(param_value);
        end-proc;


        dcl-proc RPGWEB_getHeader export;
          dcl-pi *n varchar(1024);
            request likeds(RPGWEBRQST) const;
            header char(50) const;
          end-pi;
          dcl-s header_value varchar(1024);
          dcl-s index int(10:0);

          clear header_value;
          for index = 1 to %elem(request.headers) by 1;
            if RPGWEB_toUpper(request.headers(index).name) =
              RPGWEB_toUpper(header);
              header_value = request.headers(index).value;
              index = %elem(request.headers) + 1;
            endif;
          endfor;

          return %trim(header_value);
        end-proc;



        dcl-proc RPGWEB_setHeader export;
          dcl-pi *n;
            response likeds(RPGWEBRSP);
            header_name char(50) const;
            header_value varchar(1024) const;
          end-pi;
          dcl-s index int(10:0) inz;

          for index = 1 to %elem(response.headers) by 1;
            if response.headers(index).name = *blanks;
              response.headers(index).name = header_name;
              response.headers(index).value = header_value;
              index = %elem(response.headers) + 1;
            endif;
          endfor;
        end-proc;



        dcl-proc RPGWEB_routeMatches export;
          dcl-pi *n ind;
            route likeds(RPGWEB_route_ds);
            request likeds(RPGWEBRQST);
          end-pi;
          dcl-s position int(10:0);
          dcl-s url varchar(32000);
          dcl-s start int(10:0);
          dcl-s new_start int(10:0);
          dcl-s stop int(10:0);
          dcl-s quit ind inz;
          dcl-s index int(10:0);
          dcl-s route_comparison varchar(32000);

          clear request.params;
          url = request.route;
          route_comparison = route.url;

          start = 0;
          new_start = 1;
          quit = *off;
          dow not quit;
            start = %scan('{' : route_comparison);
            if start > 0;
              stop = %scan('}' : route_comparison : start);

              for index = 1 to %elem(request.params) by 1;
                if request.params(index).name = *blanks;
                  request.params(index).name = %subst( route_comparison :
                                                      start + 1 :
                                                      stop - start - 1 );
                  stop = %scan('/' : request.route : start + 1);
                  if stop = 0;
                    request.params(index).value = %subst( request.route :
                                                          start);
                  else;
                    request.params(index).value = %subst( request.route :
                                                          start :
                                                          stop - start);
                  endif;

                  route_comparison = %scanrpl('{' + 
                            %trim(request.params(index).name) + '}' : 
                            %trim(request.params(index).value) :
                            route_comparison );
                  index = %elem(request.params) + 1;
                endif;
              endfor;
            else;
              quit = *on;
            endif;
          enddo;

          position = 0;
          exec sql set :position = regexp_instr(:url, :route_comparison);
          if (sqlstate = '42704');
            if (url = route_comparison);
              position = 1;
            endif;
          endif;

          return position > 0 and request.method = route.method;
        end-proc;


        dcl-proc RPGWEB_mwMatches export;
          dcl-pi *n ind;
            route likeds(RPGWEB_route_ds);
            request likeds(RPGWEBRQST);
          end-pi;
          dcl-s position int(10:0);
          dcl-s url varchar(32000);
          dcl-s start int(10:0);
          dcl-s new_start int(10:0);
          dcl-s stop int(10:0);
          dcl-s quit ind inz;
          dcl-s index int(10:0);
          dcl-s route_comparison varchar(32000);

          clear request.params;
          url = request.route;
          route_comparison = route.url;

          start = 0;
          new_start = 1;
          quit = *off;
          dow not quit;
            start = %scan('{' : route_comparison);
            if start > 0;
              stop = %scan('}' : route_comparison : start);

              for index = 1 to %elem(request.params) by 1;
                if request.params(index).name = *blanks;
                  request.params(index).name = %subst( route_comparison :
                                                      start + 1 :
                                                      stop - start - 1 );
                  stop = %scan('/' : request.route : start + 1);
                  if stop = 0;
                    request.params(index).value = %subst( request.route :
                                                          start);
                  else;
                    request.params(index).value = %subst( request.route :
                                                          start :
                                                          stop - start);
                  endif;

                  route_comparison = %scanrpl('{' + 
                            %trim(request.params(index).name) + '}' : 
                            %trim(request.params(index).value) :
                            route_comparison );
                  index = %elem(request.params) + 1;
                endif;
              endfor;
            else;
              quit = *on;
            endif;
          enddo;

          position = 0;
          exec sql set :position = regexp_instr(:url, :route_comparison);
          if (sqlstate = '42704');
            if (url = route_comparison);
              position = 1;
            endif;
          endif;

          // allowing middlewares for all routes
          if (%trim(route_comparison) = RPGWEB_GLOBAL_MIDDLEWARE);
            position = 1;
          endif;

          return position > 0;
        end-proc;


        dcl-proc RPGWEB_sendResponse export;
          dcl-pi *n;
            config likeds(RPGWEBAPP) const;
            response likeds(RPGWEBRSP) const;
          end-pi;
          dcl-s data char(32766);
          dcl-s return_code int(10:0) inz(0);
          dcl-s index int(10:0) inz;

          data = 'HTTP/1.1 ' + %char(response.status) + ' ' +
                %trim(RPGWEB_getMessage(response.status)) + RPGWEB_CRLF;
          data = %trim(data) + 'Connection: close' + RPGWEB_CRLF;

          for index = 1 to %elem(response.headers) by 1;
            if response.headers(index).name <> *blanks;
              data = %trim(data) +
                            %trim(response.headers(index).name) + ': ' +
                            %trim(response.headers(index).value) + 
                            RPGWEB_CRLF;
            else;
              index = %elem(response.headers) + 1;
            endif;
          endfor;

          if %len(%trim(response.body)) > 0;
            data = %trim(data) + 'Content-Length: ' +
                    %char(%len(%trim(response.body)));

            data = %trim(data) + RPGWEB_DBL_CRLF + %trim(response.body);
          else;
            data = %trim(data) + RPGWEB_DBL_CRLF;
          endif;

          RPGWEB_translate( %len(%trim(data)) : data :
                            'QJSON': 'RPGWEB');
          return_code = write( config.return_socket_descriptor :
                              %addr(data) :
                              %len(%trim(data)) );
          close_port( config.return_socket_descriptor );
        end-proc;



        dcl-proc RPGWEB_setup;
          dcl-pi *n ind;
            config likeds(RPGWEBAPP);
          end-pi;
          dcl-s return_code int(10:0) inz(0);
          dcl-ds socket_address likeds(socketaddr);
          dcl-s tries int(10:0) inz;
          dcl-s bound ind inz;
      
          HTTP_messages(1).status = HTTP_OK;
          HTTP_messages(1).text = 'OK';
          HTTP_messages(2).status = HTTP_CREATED;
          HTTP_messages(2).text = 'Created';
          HTTP_messages(3).status = HTTP_BAD_REQUEST;
          HTTP_messages(3).text = 'Bad Request';
          HTTP_messages(4).status = HTTP_UNAUTHORIZED;
          HTTP_messages(4).text = 'Unauthorized';
          HTTP_messages(5).status = HTTP_NOT_FOUND;
          HTTP_messages(5).text = 'Not Found';
          HTTP_messages(6).status = HTTP_INTERNAL_SERVER;
          HTTP_messages(6).text = 'Internal Server Error';
          HTTP_messages(7).status = HTTP_NO_CONTENT;
          HTTP_messages(7).text = 'No Content';
          HTTP_messages(8).status = HTTP_MOVED_PERMANENTLY;
          HTTP_messages(8).text = 'Moved Permanently';
          HTTP_messages(9).status = HTTP_FOUND;
          HTTP_messages(9).text = 'Found';
          HTTP_messages(10).status = HTTP_FORBIDDEN;
          HTTP_messages(10).text = 'Forbidden';

          tries = 1;
          bound = *off;
          dow (tries <= 3);
            config.socket_descriptor = socket(AF_INET : SOCK_STREAM : 0);
            return_code = set_socket_options( config.socket_descriptor :
                                              SOL_SOCKET :
                                              SO_REUSEADDR :
                                              %addr(option_val) :
                                              %size(option_val) );

            clear socket_address;
            socket_address.sin_family = AF_INET;
            socket_address.sin_port = config.port;
            socket_address.sin_addr = INADDR_ANY;
            return_code = bind( config.socket_descriptor :
                                %addr(socket_address) :
                                %size(socket_address) );
            if (return_code < 0);
              RPGWEB_log('RPGWEB - Failed to bind to port %s.' : 
                          %char(config.port));
              RPGWEB_log(RPGWEB_CRLF);           
              RPGWEB_stop(config);
              tries = tries + 1;
            else;
              tries = 4;
              bound = *on;
            endif;
          enddo;
          
          if bound;
            return_code = listen( config.socket_descriptor : 1 );
          else;
            return_code = -1;
          endif;

          return (return_code = 0);
        end-proc;



        dcl-proc RPGWEB_setRoute export;
          dcl-pi *n;
            config likeds(RPGWEBAPP);
            method char(10) const;
            url varchar(32000) const;
            procedure pointer(*proc) const;
          end-pi;
          dcl-s index int(10:0) inz;

          for index = 1 to %elem(config.routes) by 1;
            if config.routes(index).url = *blanks;
              config.routes(index).method = method;
              config.routes(index).url = url;
              config.routes(index).procedure = procedure;
              index = %elem(config.routes) + 1;
            endif;
          endfor;
        end-proc;


        dcl-proc RPGWEB_setMiddleware export;
          dcl-pi *n;
            config likeds(RPGWEBAPP);
            url varchar(32000) const;
            procedure pointer(*proc) const;
          end-pi;
          dcl-s index int(10:0) inz;

          for index = 1 to %elem(config.middlewares) by 1;
            if config.middlewares(index).url = *blanks;
              config.middlewares(index).url = url;
              config.middlewares(index).procedure = procedure;
              index = %elem(config.middlewares) + 1;
            endif;
          endfor;
        end-proc;

        dcl-proc RPGWEB_setStatus export;
          dcl-pi *n;
            response likeds(RPGWEBRSP);
            status int(10:0) const;
          end-pi;

          response.status = status;
        end-proc;

        dcl-proc RPGWEB_setBody export;
          dcl-pi *n;
            response likeds(RPGWEBRSP);
            body varchar(32000) const;
          end-pi;

          response.body = body;
        end-proc;


        dcl-proc RPGWEB_get export;
          dcl-pi *n;
            config likeds(RPGWEBAPP);
            url varchar(32000) const;
            procedure pointer(*proc) const;
          end-pi;

          RPGWEB_setRoute(config: HTTP_GET : url : procedure);
        end-proc;



        dcl-proc RPGWEB_put export;
          dcl-pi *n;
            config likeds(RPGWEBAPP);
            url varchar(32000) const;
            procedure pointer(*proc) const;
          end-pi;

          RPGWEB_setRoute(config: HTTP_PUT : url : procedure);
        end-proc;



        dcl-proc RPGWEB_patch export;
          dcl-pi *n;
            config likeds(RPGWEBAPP);
            url varchar(32000) const;
            procedure pointer(*proc) const;
          end-pi;

          RPGWEB_setRoute(config: HTTP_PATCH : url : procedure);
        end-proc;

      

        dcl-proc RPGWEB_post export;
          dcl-pi *n;
            config likeds(RPGWEBAPP);
            url varchar(32000) const;
            procedure pointer(*proc) const;
          end-pi;

          RPGWEB_setRoute(config: HTTP_POST : url : procedure);
        end-proc;



        dcl-proc RPGWEB_delete export;
          dcl-pi *n;
            config likeds(RPGWEBAPP);
            url varchar(32000) const;
            procedure pointer(*proc) const;
          end-pi;

          RPGWEB_setRoute(config: HTTP_DELETE : url : procedure);
        end-proc;


        dcl-proc RPGWEB_setStatic export;
          dcl-pi *n;
            config likeds(RPGWEBAPP);
            directory varchar(1000) const;
          end-pi;
            
          config.static_content = directory;
        end-proc;


        dcl-proc RPGWEB_setResponse;
          dcl-pi *n likeds(RPGWEBRSP);
            request likeds(RPGWEBRQST);
            status zoned(3:0) const;
          end-pi;
          dcl-ds response likeds(RPGWEBRSP) inz;

          clear response;
          response.status = status;
          RPGWEB_setHeader(response : 'Connection' : 'Close');
        
          return response;
        end-proc;



        dcl-proc RPGWEB_toUpper;
          dcl-pi *n varchar(32000);
            param varchar(32000) const;
          end-pi;
          dcl-s return_param varchar(32000);

          exec sql set :return_param = upper(:param);

          return return_param;
        end-proc;



        dcl-proc RPGWEB_split;
          dcl-pi *n char(1024) dim(50);
            line varchar(32000) const;
            delimiter char(1) const;
          end-pi;
          dcl-s parts char(1024) dim(50);
          dcl-s start int(10:0);
          dcl-s stop int(10:0);
          dcl-s index int(10:0);
          dcl-s length int(10:0);
          dcl-s location int(10:0);

          clear parts;
          length = %len(%trim(line));

          index = 1;
          dow index < 50;
              start = stop + 1;
              if start <= length;
                  stop = %scan(delimiter:line:start);
                  if stop = *zeros;
                      stop = %len(%trim(line)) + 1;
                  endif;
                  parts(index) =
                    RPGWEB_cleanString(%subst(line:start:stop-start));
              else;
                  index = 49;
              endif;

              index = index + 1;
          enddo;

          return parts;
        end-proc;



        dcl-proc RPGWEB_cleanString;
          dcl-pi *n varchar(32000);
            dirty_string varchar(32000) const;
          end-pi;
          dcl-s cleaned_string varchar(32000);

          cleaned_string =
            %trim(%scanrpl(RPGWEB_CR : '' : 
                      %scanrpl(RPGWEB_LF : '' : dirty_string)));
          return cleaned_string;
        end-proc;



        dcl-proc RPGWEB_getMessage;
          dcl-pi *n char(25);
            status zoned(3:0) const;
          end-pi;
          dcl-s index int(10:0);
          dcl-s message char(25) inz;

          for index = 1 to %elem(HTTP_messages) by 1;
            if HTTP_messages(index).status = status;
              message = HTTP_messages(index).text;
              index = %elem(HTTP_messages) + 1;
            endif;
          endfor;

          return %trim(message);
        end-proc;

        dcl-proc RPGWEB_contentFound;
          dcl-pi *n ind;
            content varchar(1000) const;
            route char(250);
          end-pi;
          dcl-s foundfile ind inz;
          dcl-s fd int(10:0) inz;
          
          foundFile = *off;
          
          fd = RPGWEB_openFile(%trim(content) + %trim(route) :
                                O_RDONLY + O_TEXTDATA + O_CCSID :
                                S_IRGRP : 37);

          foundFile = (fd > -1);
          RPGWEB_closeFile( fd );

          return foundFile;
        end-proc;

        dcl-proc RPGWEB_loadStaticContent;
          dcl-pi *n likeds(RPGWEBRSP);
            config likeds(RPGWEBAPP);
            request likeds(RPGWEBRQST);
          end-pi;
          dcl-ds response likeds(RPGWEBRSP) inz;

          response.body = RPGWEB_loadContent(
                            %trim(config.static_content) + 
                            %trim(request.route));
          RPGWEB_setStatus(response : HTTP_OK);
          RPGWEB_setHeader(response : 'Content-Type' : 'text/html');

          return response;
        end-proc;

        dcl-proc RPGWEB_loadContent;
          dcl-pi *n varchar(32000);
            content varchar(1000) const;
          end-pi;
          dcl-s output varchar(32000) inz;
 
          dcl-s fd int(10:0) inz;
          dcl-s data char(80) inz;
          dcl-s length int(10:0) inz;
          
          fd = RPGWEB_openFile(%trim(content) :
                                O_RDONLY + O_TEXTDATA + O_CCSID :
                                S_IRGRP : 37);

          if (fd > -1);
            clear data;
            length = RPGWEB_readFile(fd : %addr(data) : %size(data));
            dow length > 0;
              output = %trim(output) + data;

              clear data;
              length = RPGWEB_readFile(fd : %addr(data) : %size(data));
            enddo;
          endif;

          RPGWEB_closeFile( fd );

          return output;
        end-proc;

        dcl-proc RPGWEB_setView export;
          dcl-pi *n;
            config likeds(RPGWEBAPP);
            directory varchar(1000) const;
          end-pi;
          
          config.view_location = directory;
        end-proc;

        dcl-proc RPGWEB_render export;
          dcl-pi *n varchar(32000);
            config likeds(RPGWEBAPP);
            view_name varchar(150) const;
            injected_data varchar(32000) const;
          end-pi;
          dcl-s output varchar(32000) inz;
          dcl-s data_decs varchar(32000) inz;
          dcl-s outputFile varchar(1000) inz;
          dcl-s program varchar(1000) inz;
          dcl-s fd int(10:0) inz;
          dcl-s line char(100) inz;
          dcl-s cmd varchar(500) inz;
          dcl-s rpg_pgm varchar(32000) inz;
          dcl-s start_pos int(10:0) inz;
          dcl-s stop_pos int(10:0) inz;

          output = RPGWEB_loadContent(
                     %trim(config.view_location) + '/' + 
                     %trim(view_name) + '.erpg');

          // parse the erpg file
          start_pos = -1;
          start_pos = %scan('<%=' : output);
          if start_pos > 0;
            stop_pos = -1;
            stop_pos = %scan('=%>' : output);

            data_decs = %subst(output : start_pos : stop_pos + 3);
            data_decs = %scanrpl('RPGWEB_injected_data()' : 
                  '''' + %trim(injected_data) + '''' : data_decs);
            output = %subst(output : stop_pos + 3);
            data_decs = %scanrpl('<%=' : '' : data_decs);
            data_decs = %scanrpl('=%>' : '' : data_decs);
          endif;

          output = 'RPGWEB_write(fd:''' + %trim(output);
          output = %scanrpl(RPGWEB_CRLF : '' : output);
          output = %scanrpl('<%' : ''');' + RPGWEB_CRLF : output);
          output = %scanrpl('%>' : 'RPGWEB_write(fd:''' : output);
          output = %scanrpl('RPGWEB_write(''' : 
                            'RPGWEB_write(fd:''' : output);
          output = %scanrpl(';' : ';' + RPGWEB_CRLF : output);
          output = %trim(output) + ''');'  + RPGWEB_DBL_CRLF;

          // create the ifs rpg program to run 
          outputFile = RPGWEB_tempFile();

          fd = RPGWEB_openFile(%trim(outputFile) :
                        O_WRONLY + O_CREATE + O_CODEPAGE :
                        S_IRGRP : 819);

          RPGWEB_closeFile(fd);

          fd = RPGWEB_openFile(%trim(outputFile) :
                        O_WRONLY + O_TEXTDATA);

          if fd > -1;
            rpg_pgm = 
            '**FREE' + RPGWEB_CRLF + 
            'ctl-opt bnddir(''RPGWEB/RPGWEB'') dftactgrp(*no);' + RPGWEB_CRLF +
            '/include RPGWEB/QRPGLESRC,RPGWEB_H' + RPGWEB_CRLF +
            'dcl-c outputFile ''' + %trim(outputFile) + '.html'';' + 
                                                                  RPGWEB_CRLF +
            'dcl-s fd int(10:0) inz;' + RPGWEB_CRLF +
            %trim(data_decs) + RPGWEB_CRLF +
            'fd = RPGWEB_openFile(%trim(outputFile):O_WRONLY + O_CREATE' +
            '+ O_CODEPAGE:S_IRGRP:819);' + RPGWEB_CRLF +
            'RPGWEB_closeFile(fd);' + RPGWEB_CRLF +
            'fd = RPGWEB_openFile(%trim(outputFile):O_WRONLY+O_TEXTDATA);' +
                                                                  RPGWEB_CRLF +
            'if fd > -1;' + RPGWEB_CRLF +
            %trim(output) + RPGWEB_CRLF +
            'endif;' + RPGWEB_CRLF +
            'RPGWEB_closeFile(fd);' + RPGWEB_CRLF +
            '*inlr = *on;' + RPGWEB_CRLF +
            'return;' + RPGWEB_CRLF;
            
            RPGWEB_writeFile(fd : %addr(rpg_pgm)+2 : %len(%trim(rpg_pgm)));

            RPGWEB_closeFile(fd);              
          endif;

          // compile the ifs rpg program
          program = %scanrpl('/tmp/' : '' : outputFile);
          cmd = 'CRTBNDRPG PGM(QTEMP/' + %trim(program) + ') ' +                  
                'SRCSTMF(''' + %trim(outputFile) + ''')';
          RPGWEB_system(cmd);

          // run the program
          cmd = 'CALL QTEMP/' + %trim(program);
          RPGWEB_system(cmd);

          // read the output file into output
          output = RPGWEB_loadContent(%trim(outputFile) + '.html');

          return output;
        end-proc;

        dcl-proc RPGWEB_write export;
          dcl-pi *n;
            fd int(10:0) const;
            output varchar(32000) const;
          end-pi;
          dcl-s line varchar(32000) inz;
          dcl-s length int(10:0) inz;

          line = output;
          length = %len(%trim(line));

          RPGWEB_writeFile(fd: %addr(line)+2:length);
        end-proc;

        dcl-proc RPGWEB_tempFile;
          dcl-pi *n varchar(1000);
          end-pi;
          dcl-s filename varchar(1000);

          filename = %str(RPGWEB_tempFileName(*omit));  
          return filename;
        end-proc;
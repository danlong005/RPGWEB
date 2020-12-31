        ctl-opt option(*nodebugio:*srcstmt) dftactgrp(*no) bnddir('RPGWEB');
        /include RPGWEB/QRPGLESRC,RPGWEB_H

        dcl-ds response likeds(RPGWEBRSP) inz;
        dcl-s index int(10:0) inz;
        dcl-s index2 int(10:0) inz;
        dcl-s route_found ind inz;
        dcl-s continue_request ind;

        dcl-pi *N extpgm('RPGWEB_THD');
          request_id varchar(1000);
        end-pi;

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

        *inlr = *on;
        return;
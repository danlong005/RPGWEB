      /if not defined(RPGAPI_H)
      /define RPGAPI_H

      /include RPGAPI/QRPGLESRC,HTTP_H

        dcl-c RPGAPI_LF x'0d';
        dcl-c RPGAPI_CR x'25';
        dcl-c RPGAPI_CRLF x'0d25';
        dcl-c RPGAPI_DBL_CRLF x'0d250d25';
        dcl-c RPGAPI_GLOBAL_MIDDLEWARE '*';


        dcl-ds RPGAPI_header_ds qualified template;
          name char(50);
          value varchar(1024);
        end-ds;

        dcl-ds RPGAPI_param_ds qualified template;
          name char(50);
          value varchar(1024);
        end-ds;

        dcl-ds RPGAPI_route_ds qualified template;
          method char(10);
          url varchar(32000);
          procedure pointer(*proc);
        end-ds;

        dcl-ds RPGAPIRQST qualified template;
          body varchar(32000);
          headers likeds(RPGAPI_header_ds) dim(100);
          hostname char(250);
          method char(10);
          params likeds(RPGAPI_param_ds) dim(100);
          protocol char(250);
          query_params likeds(RPGAPI_param_ds) dim(100);
          query_string char(1024);
          route char(250);
        end-ds;

        dcl-ds RPGAPIRSP qualified template;
          body varchar(32000);
          headers likeds(RPGAPI_header_ds) dim(100);
          status int(10:0);
        end-ds;

        dcl-ds RPGAPIAPP qualified template;
          port int(10:0);
          socket_descriptor int(10:0);
          return_socket_descriptor int(10:0);
          routes likeds(RPGAPI_route_ds) dim(250);
          middlewares likeds(RPGAPI_route_ds) dim(100);
          static_content varchar(1000);
        end-ds;


        dcl-s RPGAPI_callback_ptr pointer(*proc);
        dcl-pr RPGAPI_callBack extproc(RPGAPI_callBack_ptr) likeds(RPGAPIRSP);
          request likeds(RPGAPIRQST) const;
        end-pr;

        dcl-s RPGAPI_mwCallback_ptr pointer(*proc);
        dcl-pr RPGAPI_mwCallback ind extproc(RPGAPI_mwCallback_ptr);
          request likeds(RPGAPIRQST) const;
          response likeds(RPGAPIRSP);
        end-pr;

        dcl-pr RPGAPI_start;
          config likeds(RPGAPIAPP);
          port int(10:0) options(*nopass) const;
        end-pr;

        dcl-pr RPGAPI_stop;
          config likeds(RPGAPIAPP) const;
        end-pr;

        dcl-pr RPGAPI_acceptRequest likeds(RPGAPIRQST);
          config likeds(RPGAPIAPP);
        end-pr;

        dcl-pr RPGAPI_parse likeds(RPGAPIRQST);
          raw_request varchar(32000) const;
        end-pr;

        dcl-pr RPGAPI_getParam varchar(1024);
          request likeds(RPGAPIRQST) const;
          param char(50) const;
        end-pr;

        dcl-pr RPGAPI_getQueryParam varchar(1024);
          request likeds(RPGAPIRQST) const;
          param char(50) const;
        end-pr;

        dcl-pr RPGAPI_getHeader varchar(1024);
          request likeds(RPGAPIRQST) const;
          header char(50) const;
        end-pr;

        dcl-pr RPGAPI_setHeader;
          response likeds(RPGAPIRSP);
          header_name char(50) const;
          header_value varchar(1024) const;
        end-pr;

        dcl-pr RPGAPI_routeMatches ind;
          route likeds(RPGAPI_route_ds);
          request likeds(RPGAPIRQST);
        end-pr;

        dcl-pr RPGAPI_mwMatches ind;
          route likeds(RPGAPI_route_ds);
          request likeds(RPGAPIRQST);
        end-pr;

        dcl-pr RPGAPI_sendResponse;
          config likeds(RPGAPIAPP) const;
          response likeds(RPGAPIRSP) const;
        end-pr;

        dcl-pr RPGAPI_setup ind;
          config likeds(RPGAPIAPP);
        end-pr;

        dcl-pr RPGAPI_setRoute;
          config likeds(RPGAPIAPP);
          method char(10) const;
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGAPI_setMiddleware;
          config likeds(RPGAPIAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGAPI_setStatus;
          response likeds(RPGAPIRSP);
          status int(10:0) const;
        end-pr;

        dcl-pr RPGAPI_setBody;
          response likeds(RPGAPIRSP);
          body varchar(32000) const;
        end-pr;

        dcl-pr RPGAPI_get;
          config likeds(RPGAPIAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGAPI_put;
          config likeds(RPGAPIAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGAPI_patch;
          config likeds(RPGAPIAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGAPI_post;
          config likeds(RPGAPIAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGAPI_delete;
          config likeds(RPGAPIAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGAPI_setStatic;
          config likeds(RPGAPIAPP);
          directory varchar(1000) const;
        end-pr;

        dcl-pr RPGAPI_setResponse likeds(RPGAPIRSP);
          request likeds(RPGAPIRQST);
          status zoned(3:0) const;        
        end-pr;

        dcl-pr RPGAPI_staticContentFound ind;
          config likeds(RPGAPIAPP);
          route char(250);
        end-pr;

        dcl-pr RPGAPI_loadStaticContent likeds(RPGAPIRSP);
          config likeds(RPGAPIAPP)
          request likeds(RPGAPIRQST);
        end-pr;
        end-pr;

        dcl-pr RPGAPI_openFile int(10:0) extproc('open');
          *n pointer value options(*string);
          *n int(10) value;
          *n uns(10) value options(*nopass);
          *n uns(10) value options(*nopass);
          *n uns(10) value options(*nopass);
        end-pr;

        dcl-pr RPGAPI_readFile int(10) extproc('read');
          *n int(10) value; 
          *n pointer value;
          *n uns(10) value;
        end-pr ;

        dcl-pr RPGAPI_closeFile int(10) extproc('close');
          *n  int(10) value;
        end-pr;

        dcl-pr RPGAPI_toUpper varchar(32000);
          line varchar(32000) const;
        end-pr;

        dcl-pr RPGAPI_split char(1024) dim(50);
          line varchar(32000) const;
          delimiter char(1) const;
        end-pr;

        dcl-pr RPGAPI_cleanString varchar(32000);
          dirty_string varchar(32000) const;
        end-pr;

        dcl-pr RPGAPI_getMessage char(25);
          status zoned(3:0) const;
        end-pr;

        dcl-pr RPGAPI_log int(10) extproc('Qp0zLprintf');
          *n pointer value options(*string);
          *n pointer value options(*string:*nopass);
          *n pointer value options(*string:*nopass);
          *n pointer value options(*string:*nopass);
          *n pointer value options(*string:*nopass);
          *n pointer value options(*string:*nopass);
          *n pointer value options(*string:*nopass);
          *n pointer value options(*string:*nopass);
          *n pointer value options(*string:*nopass);
          *n pointer value options(*string:*nopass);
          *n pointer value options(*string:*nopass);
        end-pr;

     D RPGAPI_translate...
     D                 PR                  ExtPgm('QDCXLATE')
     D   Length                       5P 0 const
     D   Data                     32766A   options(*varsize)
     D   Table                       10A   const
     D   Lib                         10A   const options(*nopass)

        dcl-s option_val int(10:0);

        dcl-pr socket int(10:0) extproc('socket');
          addr_family int(10:0) value;
          type int(10:0) value;
          protocol int(10:0) value;
        end-pr;

        dcl-pr set_socket_options int(10:0) extproc('setsockopt');
          socket_descriptor int(10:0) value;
          level int(10:0) value;
          option_name int(10:0) value;
          option_value pointer value;
          option_length int(10:0) value;
        end-pr;

        dcl-pr read int(10:0) extproc('read');
          socket_descriptor int(10:0) value;
          data pointer value;
          data_length int(10:0) value;
        end-pr;

        dcl-pr write int(10:0) extproc('write');
          socket_descriptor int(10:0) value;
          data pointer value;
          data_length int(10:0) value;
        end-pr;

        dcl-pr close_port extproc('close');
          socket_descriptor int(10:0) value;
        end-pr;

        dcl-pr connect int(10:0) extproc('connect');
          socket_descriptor int(10:0) value;
          address pointer value;
          address_length int(10:0) value;
        end-pr;

        dcl-pr bind int(10:0) extproc('bind');
          socket_descriptor int(10:0) value;
          local_address pointer value;
          address_length int(10:0) value;
        end-pr;

        dcl-pr listen int(10:0) extproc('listen');
          socket_descriptor int(10:0) value;
          max_clients int(10:0) value;
        end-pr;

        dcl-pr accept int(10:0) extproc('accept');
          socket_descriptor int(10:0) value;
          address pointer value;
          address_length pointer value;
        end-pr;

        dcl-pr inet_address int(10:0) extproc('inet_addr');
          ip_address pointer value;
        end-pr;

        dcl-pr get_host_by_name pointer extproc('gethostbyname');
          host_name pointer value;
        end-pr;

        dcl-pr get_host_by_addr pointer extproc('gethostbyaddr');
          host_address pointer value;
          address_length int(10:0) value;
          address_type int(10:0) value;
        end-pr;

     D SocketAddr      ds
     D   sin_family                   5I 0
     D   sin_port                     5U 0
     D   sin_addr                    10U 0
     D   sin_zero                     8A   inz(*ALLX'00')

     D SocketAddrLen   s             10I 0
     D SocketAddrLena  s               *   inz(%addr(SocketAddrLen))

     D HostEnta        s               *

     D HostEnt         ds                  align based(HostEnta)
     D  h_namea                        *
     D  h_aliasesa                     *
     D  h_addrtype                   10I 0
     D  h_len                        10I 0
     D  h_addr_lista                   *

     D HostEntDataa    s               *

     D HostEntData     ds                  align based(HostEntDataa)
     D  h_name                      256A
     D  h_aliases2a                    *   dim(65)
     D  h_aliases2                  256A   dim(64)
     D  h_addra                        *   dim(101)
     D  h_addr                       10U 0 dim(100)
     D  open_flag                    10I 0
     D  f0a                            *
     D  filep0                      260A
     D  reserved0                   150A
     D  f1a                            *
     D  filep1                      260A
     D  reserved1                   150A
     D  f2a                            *
     D  filep2                      260A
     D  reserved2                   150A

       dcl-c AF_UNIX 1;
       dcl-c AF_INET 2;
       dcl-c AF_NS 6;
       dcl-c AF_TELEPHONY 99;
       dcl-c SOCK_STREAM 1;
       dcl-c SOCK_DGRAM 2;
       dcl-c SOCK_RAW 3;
       dcl-c SOCK_SEQPACKET 5;
       dcl-c SOL_SOCKET -1;
       dcl-c SO_BROADCAST 5;
       dcl-c SO_DEBUG 10;
       dcl-c SO_DONTROUTE 15;
       dcl-c SO_ERROR 20;
       dcl-c SO_KEEPALIVE 25;
       dcl-c SO_LINGER 30;
       dcl-c SO_OOBINLINE 35;
       dcl-c SO_RCVBUF 40;
       dcl-c SO_RCVLOWAT 45;
       dcl-c SO_REUSEADDR 55;
       dcl-c SO_SNDBUF 60;
       dcl-c SO_SNDLOWAT 65;
       dcl-c SO_SNDTIMEO 70;
       dcl-c SO_TYPE 75;
       dcl-c SO_USELOOPBACK 80;
       dcl-c INADDR_ANY 0;
       dcl-c RC_OK 0;
       
       dcl-c O_RDONLY 1;         
       dcl-c O_TEXTDATA 16777216; 
       dcl-c O_CCSID 32; 
       dcl-c S_IRGRP 32;

      /endif

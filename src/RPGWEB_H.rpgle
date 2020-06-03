      /if not defined(RPGWEB_H)
      /define RPGWEB_H

      /include RPGWEB/QRPGLESRC,HTTP_H

        dcl-c RPGWEB_LF x'0d';
        dcl-c RPGWEB_CR x'25';
        dcl-c RPGWEB_CRLF x'0d25';
        dcl-c RPGWEB_DBL_CRLF x'0d250d25';
        dcl-c RPGWEB_GLOBAL_MIDDLEWARE '*';


        dcl-ds RPGWEB_header_ds qualified template;
          name char(50);
          value varchar(1024);
        end-ds;

        dcl-ds RPGWEB_param_ds qualified template;
          name char(50);
          value varchar(1024);
        end-ds;

        dcl-ds RPGWEB_route_ds qualified template;
          method char(10);
          url varchar(32000);
          procedure pointer(*proc);
        end-ds;

        dcl-ds RPGWEBRQST qualified template;
          body varchar(32000);
          headers likeds(RPGWEB_header_ds) dim(100);
          hostname char(250);
          method char(10);
          params likeds(RPGWEB_param_ds) dim(100);
          protocol char(250);
          query_params likeds(RPGWEB_param_ds) dim(100);
          query_string char(1024);
          route char(250);
        end-ds;

        dcl-ds RPGWEBRSP qualified template;
          body varchar(32000);
          headers likeds(RPGWEB_header_ds) dim(100);
          status int(10:0);
        end-ds;

        dcl-ds RPGWEBAPP qualified template;
          port int(10:0);
          socket_descriptor int(10:0);
          return_socket_descriptor int(10:0);
          routes likeds(RPGWEB_route_ds) dim(250);
          middlewares likeds(RPGWEB_route_ds) dim(100);
          static_content varchar(1000);
          view_location varchar(1000);
        end-ds;


        dcl-s RPGWEB_callback_ptr pointer(*proc);
        dcl-pr RPGWEB_callBack extproc(RPGWEB_callBack_ptr) likeds(RPGWEBRSP);
          request likeds(RPGWEBRQST) const;
        end-pr;

        dcl-s RPGWEB_mwCallback_ptr pointer(*proc);
        dcl-pr RPGWEB_mwCallback ind extproc(RPGWEB_mwCallback_ptr);
          request likeds(RPGWEBRQST) const;
          response likeds(RPGWEBRSP);
        end-pr;

        dcl-pr RPGWEB_start;
          config likeds(RPGWEBAPP);
          port int(10:0) options(*nopass) const;
        end-pr;

        dcl-pr RPGWEB_stop;
          config likeds(RPGWEBAPP) const;
        end-pr;

        dcl-pr RPGWEB_acceptRequest likeds(RPGWEBRQST);
          config likeds(RPGWEBAPP);
        end-pr;

        dcl-pr RPGWEB_parse likeds(RPGWEBRQST);
          raw_request varchar(32000) const;
        end-pr;

        dcl-pr RPGWEB_getParam varchar(1024);
          request likeds(RPGWEBRQST) const;
          param char(50) const;
        end-pr;

        dcl-pr RPGWEB_getQueryParam varchar(1024);
          request likeds(RPGWEBRQST) const;
          param char(50) const;
        end-pr;

        dcl-pr RPGWEB_getHeader varchar(1024);
          request likeds(RPGWEBRQST) const;
          header char(50) const;
        end-pr;

        dcl-pr RPGWEB_setHeader;
          response likeds(RPGWEBRSP);
          header_name char(50) const;
          header_value varchar(1024) const;
        end-pr;

        dcl-pr RPGWEB_routeMatches ind;
          route likeds(RPGWEB_route_ds);
          request likeds(RPGWEBRQST);
        end-pr;

        dcl-pr RPGWEB_mwMatches ind;
          route likeds(RPGWEB_route_ds);
          request likeds(RPGWEBRQST);
        end-pr;

        dcl-pr RPGWEB_sendResponse;
          config likeds(RPGWEBAPP) const;
          response likeds(RPGWEBRSP) const;
        end-pr;

        dcl-pr RPGWEB_setup ind;
          config likeds(RPGWEBAPP);
        end-pr;

        dcl-pr RPGWEB_setRoute;
          config likeds(RPGWEBAPP);
          method char(10) const;
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_setMiddleware;
          config likeds(RPGWEBAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_setStatus;
          response likeds(RPGWEBRSP);
          status int(10:0) const;
        end-pr;

        dcl-pr RPGWEB_setBody;
          response likeds(RPGWEBRSP);
          body varchar(32000) const;
        end-pr;

        dcl-pr RPGWEB_get;
          config likeds(RPGWEBAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_put;
          config likeds(RPGWEBAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_patch;
          config likeds(RPGWEBAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_post;
          config likeds(RPGWEBAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_delete;
          config likeds(RPGWEBAPP);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_setStatic;
          config likeds(RPGWEBAPP);
          directory varchar(1000) const;
        end-pr;

        dcl-pr RPGWEB_setResponse likeds(RPGWEBRSP);
          request likeds(RPGWEBRQST);
          status zoned(3:0) const;
        end-pr;

        dcl-pr RPGWEB_setView;
          config likeds(RPGWEBAPP);
          directory varchar(1000) const;
        end-pr;

        dcl-pr RPGWEB_render varchar(32000);
          config likeds(RPGWEBAPP);
          view_name varchar(150) const;
        end-pr;

        dcl-pr RPGWEB_write;
          fd int(10:0) const;
          output varchar(32000) const;
        end-pr;

        dcl-pr RPGWEB_contentFound ind;
          content varchar(1000) const;
          route char(250);
        end-pr;

        dcl-pr RPGWEB_loadContent varchar(32000);
          content varchar(1000) const;
        end-pr;

        dcl-pr RPGWEB_loadStaticContent likeds(RPGWEBRSP);
          config likeds(RPGWEBAPP);
          request likeds(RPGWEBRQST);
        end-pr;

        dcl-pr RPGWEB_openFile int(10:0) extproc('open');
          *n pointer value options(*string);
          *n int(10) value;
          *n uns(10) value options(*nopass);
          *n uns(10) value options(*nopass);
          *n uns(10) value options(*nopass);
        end-pr;

        dcl-pr RPGWEB_readFile int(10) extproc('read');
          *n int(10) value; 
          *n pointer value;
          *n uns(10) value;
        end-pr ;
       
        dcl-pr RPGWEB_writeFile int(10) extproc('write');
          *n int(10) value;
          *n pointer value;
          *n uns(10) value;
        end-pr;

        dcl-pr RPGWEB_closeFile int(10) extproc('close');
          *n  int(10) value;
        end-pr;

        dcl-pr RPGWEB_toUpper varchar(32000);
          line varchar(32000) const;
        end-pr;

        dcl-pr RPGWEB_split char(1024) dim(50);
          line varchar(32000) const;
          delimiter char(1) const;
        end-pr;

        dcl-pr RPGWEB_cleanString varchar(32000);
          dirty_string varchar(32000) const;
        end-pr;

        dcl-pr RPGWEB_getMessage char(25);
          status zoned(3:0) const;
        end-pr;

        dcl-pr RPGWEB_tempFile varchar(1000);
        end-pr;

        dcl-pr RPGWEB_tempFileName pointer extproc('_C_IFS_tmpnam');
          string char(39) options(*omit);
        end-pr;

        dcl-pr RPGWEB_log int(10) extproc('Qp0zLprintf');
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

        dcl-pr RPGWEB_system int(10:0) extproc('system');
          *n pointer value options(*string);
        end-pr;

     D RPGWEB_translate...
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
       dcl-c O_WRONLY 2;  
       dcl-c O_RDWR   4;
       dcl-c O_CREATE 8;    
       dcl-c O_CODEPAGE 8388608; 
       dcl-c O_TEXTDATA 16777216; 
       dcl-c O_CCSID 32; 
       dcl-c S_IRGRP 32;

      /endif

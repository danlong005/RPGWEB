      /if not defined(RPGWEB_H)
      /define RPGWEB_H

      /include RPGWEB/QRPGLESRC,HTTP_H

        dcl-c RPGWEB_LF x'0d';
        dcl-c RPGWEB_CR x'25';
        dcl-c RPGWEB_CRLF x'0d25';
        dcl-c RPGWEB_DBL_CRLF x'0d250d25';

        dcl-ds HTTP_messages qualified dim(100);
          status zoned(3:0);
          text char(25);
        end-ds;

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
          routes likeds(RPGWEB_route_ds) dim(500);
        end-ds;


        dcl-s RPGWEB_callback_ptr pointer(*proc);
        dcl-pr RPGWEB_callBack extproc(RPGWEB_callBack_ptr) likeds(RPGWEBRSP);
          request likeds(RPGWEBRQST) const;
        end-pr;

        dcl-pr RPGWEB_start;
          config likeds(RPGWEBAPP);
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

        dcl-pr RPGWEB_sendResponse;
          config likeds(RPGWEBAPP) const;
          response likeds(RPGWEBRSP) const;
        end-pr;

        dcl-pr RPGWEB_setup;
          config likeds(RPGWEBAPP);
        end-pr;

        dcl-pr RPGWEB_setRoute;
          config likeds(RPGWEBAPP);
          method char(10) const;
          url varchar(32000) const;
          procedure pointer(*proc) const;
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

        dcl-pr RPGWEB_setResponse likeds(RPGWEBRSP);
          request likeds(RPGWEBRQST);
          status zoned(3:0) const;
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

 
     D RPGWEB_translate...
     D                 PR                  ExtPgm('QDCXLATE')
     D   Length                       5P 0 const
     D   Data                     32766A   options(*varsize)
     D   Table                       10A   const

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
     D SocketAddrLen@  s               *   inz(%addr(SocketAddrLen))

     D HostEnt@        s               *

     D HostEnt         ds                  align based(HostEnt@)
     D  h_name@                        *
     D  h_aliases@                     *
     D  h_addrtype                   10I 0
     D  h_len                        10I 0
     D  h_addr_list@                   *

     D HostEntData@    s               *

     D HostEntData     ds                  align based(HostEntData@)
     D  h_name                      256A
     D  h_aliases2@                    *   dim(65)
     D  h_aliases2                  256A   dim(64)
     D  h_addr@                        *   dim(101)
     D  h_addr                       10U 0 dim(100)
     D  open_flag                    10I 0
     D  f0@                            *
     D  filep0                      260A
     D  reserved0                   150A
     D  f1@                            *
     D  filep1                      260A
     D  reserved1                   150A
     D  f2@                            *
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
       
      /endif

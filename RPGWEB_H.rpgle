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

        dcl-ds RPGWEBCFG qualified template;
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
          config likeds(RPGWEBCFG);
        end-pr;

        dcl-pr RPGWEB_stop;
          config likeds(RPGWEBCFG) const;
        end-pr;

        dcl-pr RPGWEB_acceptRequest likeds(RPGWEBRQST);
          config likeds(RPGWEBCFG);
        end-pr;

        dcl-pr RPGWEB_parse likeds(RPGWEBRQST);
          raw_request varchar(32000) const;
        end-pr;

        dcl-pr RPGWEB_getParam varchar(1024);
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
          config likeds(RPGWEBCFG) const;
          response likeds(RPGWEBRSP) const;
        end-pr;

        dcl-pr RPGWEB_setup;
          config likeds(RPGWEBCFG);
        end-pr;

        dcl-pr RPGWEB_setRoute;
          config likeds(RPGWEBCFG);
          method char(10) const;
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_get;
          config likeds(RPGWEBCFG);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_put;
          config likeds(RPGWEBCFG);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_post;
          config likeds(RPGWEBCFG);
          url varchar(32000) const;
          procedure pointer(*proc) const;
        end-pr;

        dcl-pr RPGWEB_delete;
          config likeds(RPGWEBCFG);
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

      ***************************************************************
      * Socket Address Families
      ***************************************************************
     D AF_UNIX         c                   1
     D AF_INET         c                   2
     D AF_NS           c                   6
     D AF_TELEPHONY    c                   99

      ***************************************************************
      * Socket Types
      ***************************************************************
     D SOCK_STREAM     c                   1
     D SOCK_DGRAM      c                   2
     D SOCK_RAW        c                   3
     D SOCK_SEQPACKET  c                   5

      ***************************************************************
      * Socket Level Option
      ***************************************************************
     D SOL_SOCKET      c                   -1

      ***************************************************************
      * Socket Level Option Names
      ***************************************************************
     D SO_BROADCAST    c                   5
     D SO_DEBUG        c                   10
     D SO_DONTROUTE    c                   15
     D SO_ERROR        c                   20
     D SO_KEEPALIVE    c                   25
     D SO_LINGER       c                   30
     D SO_OOBINLINE    c                   35
     D SO_RCVBUF       c                   40
     D SO_RCVLOWAT     c                   45
     D SO_REUSEADDR    c                   55
     D SO_SNDBUF       c                   60
     D SO_SNDLOWAT     c                   65
     D SO_SNDTIMEO     c                   70
     D SO_TYPE         c                   75
     D SO_USELOOPBACK  c                   80

      ***************************************************************
      * Address Wildcard
      ***************************************************************
     D INADDR_ANY      c                   0

      ***************************************************************
      * Return Code "OK" value
      ***************************************************************
     D RC_OK           c                   0
      /endif

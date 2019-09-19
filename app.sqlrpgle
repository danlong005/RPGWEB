       ctl-opt option(*nodebugio:*srcstmt) bnddir('RPGWEB':'YAJL')
              dftactgrp(*no);

      /copy rpgweb/qrpglesrc,RPGWEB_H
      /include yajl/qrpglesrc,YAJL_H

       dcl-ds request likeds(RPGWEBRQST);
       dcl-ds response likeds(RPGWEBRSP);
       dcl-ds app likeds(RPGWEBCFG);

       clear app;
       app.port = 3017;

       RPGWEB_get(app : '/api/v1/memberships/{id}' : %paddr(MBR_show));

       RPGWEB_start(app);

       *inlr = *on;
       return;


       dcl-proc MBR_show;
         dcl-pi *n likeds(RPGWEBRSP);
           request likeds(RPGWEBRQST) const;
         end-pi;
         dcl-s Length Int(10:0) Inz;
         dcl-s CCSID Int(10:0) Inz;
         dcl-s id_number zoned(11:0) inz;
         dcl-ds row qualified;
           id zoned(11:0);
           first_name char(25);
           last_name char(25);
         end-ds;
         dcl-s data char(500);

         clear row;
         id_number = %dec(RPGWEB_getParam(request: 'id') : 11 : 0);

         exec sql select id, fname, lname
                  into :row
                  from testdta
                  where id = :id_number;

         clear response;
         clear data;
         response.status = HTTP_OK;
         RPGWEB_setHeader(response : 'Content-Type' : 'application/json');
         
         if row.id <> *zeros;
           YAJL_genOpen( *off );
           YAJL_beginObj();
              YAJL_addNum('id' : %trim(%char(row.id)));
              YAJL_addChar('first_name' : %trim(row.first_name));
              YAJL_addChar('last_name' : %trim(row.last_name));
           YAJL_endObj();
           YAJL_copyBuf(CCSID : %addr(data) : %size(data) : 
                        length);
           YAJL_genClose();
           response.body = data;
         else;
           response.status = HTTP_NOT_FOUND;
         endif;

         return response;
       end-proc;
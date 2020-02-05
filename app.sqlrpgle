       ctl-opt option(*nodebugio:*srcstmt) bnddir('RPGAPI':'YAJL')
              dftactgrp(*no);

      /copy RPGAPI/qrpglesrc,RPGAPI_H
      /include yajl/qrpglesrc,YAJL_H

       dcl-ds request likeds(RPGAPIRQST);
       dcl-ds response likeds(RPGAPIRSP);
       dcl-ds app likeds(RPGAPIAPP);

       clear app;
       app.port = 3012;

       RPGAPI_setMiddleware(app : '/api/v1/memberships' : %paddr(CHECK_AUTH));
       RPGAPI_get(app : '/api/v1/memberships/{id}' : %paddr(MBR_show));

       RPGAPI_start(app);

       *inlr = *on;
       return;


       dcl-proc CHECK_AUTH;
         dcl-pi *n ind;
           request likeds(RPGAPIRQST) const;
           response likeds(RPGAPIRSP) const;
         end-pi;

         return *on;
       end-proc;

       dcl-proc MBR_show;
         dcl-pi *n likeds(RPGAPIRSP);
           request likeds(RPGAPIRQST) const;
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
         id_number = %dec(RPGAPI_getParam(request: 'id') : 11 : 0);

         exec sql select id, fname, lname
                  into :row
                  from testdta
                  where id = :id_number;

         clear response;
         clear data;
         response.status = HTTP_OK;
         RPGAPI_setHeader(response : 'Content-Type' : 'application/json');
         
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
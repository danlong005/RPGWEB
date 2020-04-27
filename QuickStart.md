```
       ctl-opt option(*nodebugio:*srcstmt) bnddir('RPGAPI')
              dftactgrp(*no);

      /copy RPGAPI/qrpglesrc,RPGAPI_H

       dcl-ds request likeds(RPGAPIRQST);
       dcl-ds response likeds(RPGAPIRSP);
       dcl-ds app likeds(RPGAPIAPP);

       clear app;

       RPGAPI_get(app : '/hello' : %paddr(test_proc));

       RPGAPI_start(app: 3017);

       *inlr = *on;
       return;


       dcl-proc test_proc;
         dcl-pi *n likeds(RPGAPIRSP);
           request likeds(RPGAPIRQST) const;
         end-pi;

         response.body = 'hello';
         response.status = HTTP_OK;
         RPGAPI_setHeader(response : 'Content-Type' : 'application/text');

         return response;
       end-proc;
```
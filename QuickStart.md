```
       ctl-opt option(*nodebugio:*srcstmt) bnddir('RPGAPI')
              dftactgrp(*no);

      /copy RPGAPI/qrpglesrc,RPGAPI_H

       dcl-ds request likeds(RPGAPIRQST);
       dcl-ds response likeds(RPGAPIRSP);
       dcl-ds app likeds(RPGAPIAPP);

       clear app;
       app.port = 3017;  // default is 3000

       RPGAPI_get(app : '/hello' : %paddr(test_proc));

       RPGAPI_start(app);

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
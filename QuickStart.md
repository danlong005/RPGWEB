```
       ctl-opt option(*nodebugio:*srcstmt) bnddir('RPGWEB')
              dftactgrp(*no);

      /copy rpgweb/qrpglesrc,RPGWEB_H

       dcl-ds request likeds(RPGWEBRQST);
       dcl-ds response likeds(RPGWEBRSP);
       dcl-ds app likeds(RPGWEBCFG);

       clear app;
       app.port = 3017;

       RPGWEB_get(app : '/hello' : %paddr(test_proc));

       RPGWEB_start(app);

       *inlr = *on;
       return;


       dcl-proc test_proc;
         dcl-pi *n likeds(RPGWEBRSP);
           request likeds(RPGWEBRQST) const;
         end-pi;

         response.body = 'hello';
         response.status = HTTP_OK;
         RPGWEB_setHeader(response : 'Content-Type' : 'application/text');

         return response;
       end-proc;
```
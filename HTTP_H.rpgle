      /if not defined(HTTP_H)       
      /define HTTP_H                
                                    
        dcl-c HTTP_GET 'GET';       
        dcl-c HTTP_POST 'POST';     
        dcl-c HTTP_PUT 'PUT';       
        dcl-c HTTP_PATCH 'PATCH';   
        dcl-c HTTP_DELETE 'DELETE'; 

        dcl-c HTTP_OK 200;          
        dcl-c HTTP_CREATED 201;    
        dcl-c HTTP_ACCEPTED 202;
        dcl-c HTTP_NO_CONTENT 204; 
        dcl-c HTTP_MOVED_PERMANENTLY 301;
        dcl-c HTTP_FOUND 302;
        dcl-c HTTP_BAD_REQUEST 400; 
        dcl-c HTTP_UNAUTHORIZED 401;
        dcl-c HTTP_FORBIDDEN 403;
        dcl-c HTTP_NOT_FOUND 404;   
        dcl-c HTTP_INTERNAL_SERVER 500;

        dcl-ds HTTP_messages qualified dim(100);
          status zoned(3:0);
          text char(25);
        end-ds;
      /endif                        
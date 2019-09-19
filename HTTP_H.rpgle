      /if not defined(HTTP_H)       
      /define HTTP_H                
                                    
        dcl-c HTTP_GET 'GET';       
        dcl-c HTTP_POST 'POST';     
        dcl-c HTTP_PUT 'PUT';       
        dcl-c HTTP_PATCH 'PATCH';   
        dcl-c HTTP_DELETE 'DELETE'; 
                                    
        dcl-c HTTP_OK 200;          
        dcl-c HTTP_CREATED 201;     
        dcl-c HTTP_BAD_REQUEST 400; 
        dcl-c HTTP_UNAUTHORIZED 401;
        dcl-c HTTP_NOT_FOUND 404;   
        dcl-c HTTP_INTERNAL_SERVER 500;
                                    
      /endif                        
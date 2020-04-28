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

        HTTP_messages(1).status = HTTP_OK;
        HTTP_messages(1).text = 'OK';
        HTTP_messages(2).status = HTTP_CREATED;
        HTTP_messages(2).text = 'Created';
        HTTP_messages(3).status = HTTP_BAD_REQUEST;
        HTTP_messages(3).text = 'Bad Request';
        HTTP_messages(4).status = HTTP_UNAUTHORIZED;
        HTTP_messages(4).text = 'Unauthorized';
        HTTP_messages(5).status = HTTP_NOT_FOUND;
        HTTP_messages(5).text = 'Not Found';
        HTTP_messages(6).status = HTTP_INTERNAL_SERVER;
        HTTP_messages(6).text = 'Internal Server Error';
        HTTP_messages(7).status = HTTP_NO_CONTENT;
        HTTP_messages(7).text = 'No Content';
        HTTP_messages(8).status = HTTP_MOVED_PERMANENTLY;
        HTTP_messages(8).text = 'Moved Permanently';
        HTTP_messages(9).status = HTTP_FOUND;
        HTTP_messages(9).text = 'Found';
        HTTP_messages(10).status = HTTP_FORBIDDEN;
        HTTP_messages(10).text = 'Forbidden';
      /endif                        
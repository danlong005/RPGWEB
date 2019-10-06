# RPGWEB Documentation

### Application Data Structures
```
        //
        // the request data structure
        //
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

        //
        // the response data structure
        //
        dcl-ds RPGWEBRSP qualified template;
          body varchar(32000);
          headers likeds(RPGWEB_header_ds) dim(100);
          status int(10:0);
        end-ds;

        //
        // the application data structure
        //
        dcl-ds RPGWEBAPP qualified template;
          port int(10:0);
          socket_descriptor int(10:0);
          return_socket_descriptor int(10:0);
          routes likeds(RPGWEB_route_ds) dim(500);
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
```

### Application
For a simple application to get you up and running checkout our [Quick Start](QuickStart.md) guide. This will get you up and running with a RPG web application in no time.

#### Callbacks
To create web application in RPGWEB you have to follow a simple pattern on your callbacks(procedures) that process the requests. 

```
dcl-proc index;
  dcl-pi *n likeds(RPGWEBRSP);
    request likeds(RPGWEBRQST) const;
  end-pi;
  dcl-ds response likeds(RPGWEBRSP);
  
  ...your code...
  
  return response;
end-proc;
```
You will notice that the procedure takes a RPGWEBRQST(RPGWEB request) and returns a RPGWEBRSP(RPGWEB response). That's it! Inside of the method you can create whatever you need and load it into the response before you return it. We will dive more into this later.

#### Kicking off the application
Once you have registered some routes in the app data structure you can start the application so that your app can start handling request. You can start the application using the following api call

```
RPGWEB_start(app);
```



#### Routing
To create routes in your application we have given you several ways to create those. 

First up is the setRoute method. This can be used for all types of routes. POST, PATCH, PUT, DELETE, GET... etc You simply pass the application data structure, METHOD, url and a pointer to the procedure you want to call when this route is hit. 

```
RPGWEB_setRoute(app : METHOD : url : %paddr(procedure));
```

There are also the following methods that are more descriptive that you may want to use for creating your routes.

```
RPGWEB_get(app : url : %paddr(procedure));
RPGWEB_post(app : url : %paddr(procedure));
RPGWEB_put(app : url : %paddr(procedure));
RPGWEB_delete(app : url : %paddr(procedure));
```

We find that these make the code _MUCH_ more readable.

##### Defining Routes


### Middleware
To create middleware on your routes you can use the following method.

```
  RPGWEB_setMiddleware(app : '/api/v1/memberships' : %paddr(CHECK_AUTH));
```

and the defintion of the middleware callback is as follows

```
  dcl-proc CHECK_AUTH;
    dcl-pi *n ind;
      request likeds(RPGWEBRQST) const;
      response likeds(RPGWEBRSP) const;
    end-pi;

    return *on;
  end-proc;
```

If you want to continue the request after the middleware method has ran then 
return *on, else you can return *off and the request will be cancelled. You of 
course will need to set the response accordingly in the middleware.


### Requests
Given that you followed the outline specs for your callback procedures the request datastructure will be passed into the method that is handing the current request. You can find everything out about the request by looking in the request data structure. 

#### Headers
These are the headers that came in on the request. You can access those headers using the following api method

```
header_value = RPGWEB_getHeader(request : 'Content-Type');
```

#### Params
These are the route params that came in on the request. To define route params in your route see the section on routing. You can access the params using the following api method

```
id_value = RPGWEB_getParam(request : 'id');
```

#### Body
To access the body of the request you can use the following variable in the 
request data structure.

```
body_value = request.body;
```

#### QueryString/QueryParams
The query string can be accessed in two different ways.

First you can get they full query string by access the query_string variable 
in the request data structure

```
query_string_value = request.query_string;
```

or you can access the various values in the query string using the following
method

```
query_string_param = RPGWEB_getQueryParam(request : 'q');
```
Note: q would be the param name in the query string like `q=fish`


#### Protocol
The protocol that the request used can be accessed using the following variable 
on the request data structure.

```
protocol = request.protocol;
```

#### Method
The method that the request used can be accessed using the following variable 
on the request data structure.

```
method = request.method;
```

#### Route
The route that the request used can be accessed using the following variable 
on the request data structure.

```
route = request.route;
```

### Responses
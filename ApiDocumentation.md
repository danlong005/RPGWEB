# RPGWEB Documentation

## Application Data Structure

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
Currently we do not yet support middleware. That is coming soon though. Please check back.





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

#### Status

#### QueryString/QueryParams

#### Protocol

#### Method

#### Route


### Responses
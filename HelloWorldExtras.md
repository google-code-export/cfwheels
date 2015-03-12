# Introduction #

These are sections taken out of the Hello World Chapter...


## The Role of MVC in Wheels ##

Imagine a football team where everyone tries to be quarterback. Things would get pretty messy rather quickly. On a football team, or any team for that matter, each member should have a specific job and responsibility.

Wheels helps clean up this mess by using a design pattern called _Model-View-Controller (MVC)_. Let's take a brief look at MVC and see how it helps organize your Wheels applications.

At a basic level, a MVC framework like Wheels breaks your application into 3 distinct pieces, each having a well-defined role and responsibility. The 3 pieces are called models, views and controllers. Pretty intuitive so far, eh?

### Model Layer ###

The **model** is responsible for the data objects of your application. In general, models interact with your databases and contain any specific business rules that tell your applications how to use that data.

### View Layer ###

The **view** is responsible for the user interface, or presentation layer, of your application. Views build and present the web pages and other interface elements that make up your application.

### Controller Layer ###

The **controller** is the central command of your application. Controllers define and know about the functions or actions that your application can handle. These actions are generally the web requests initiated by the users by invoking URLs. A controller's job is to listen for these actions, interact with the model to get any data that is needed by the action, and then finally hand off the data to the view so it can display a page for the user.

Others have written entire volumes describing the MVC pattern and its pros and cons. Some of these books are great reads, but this high level understanding of MVC should be all that you need in order to get starting using Wheels.

## URLs in Wheels ##

Wheels handles three different classes of URLs depending on the capabilities of your web server. The most basic form is No URL Rewriting, then Partial URL Rewriting, and finally Full URL Rewriting. Wheels will attempt to determine what level of URL Rewriting your server supports and automatically configure your application to use the most advanced level of URL Rewriting your server environment allows. So lets take a look at each class of URLs that Wheels supports.

### No URL Rewriting ###

This is the most basic form of URLs that Wheels handles. There is really nothing special about this since its what we are all used to. The URLs make use of a single file that all requests are routed through and specifically pass all the variables and values in the query string. Lets take a look at an example URL in this format:

```
http://www.mydomain.com/index.cfm?controller=say&action=hello
```

Now lets break this apart and see what is going on. There really is no magic here, we first specify the protocol to use, in this case `http`, then we specify the domain name, here we are using a dummy domain `www.mydomain.com`, then we specify the file to call `index.cfm`. Up to this point there is nothing new going on, we've seen this all before. Now we start telling Wheels what we want it to do, we specify that we want to call the **say** controller using `controller=say` and finally we indicate that we want to invoke the **hello** action of the say controller using `action=hello`.

This is the most basic form of URLs that Wheels can handle. It will work on all web servers and doesn't require you to configure anything special for it to work. It's ugly but it works...now lets see how we can clean these URLs up a bit.

### Partial URL Rewriting ###

The next class of URLs that we should look at are what we call Partial URL Rewriting. With Partial rewriting we get rid of all the special characters in the URL. All the `?` and `&` are removed and even the `controller=` and `action=` are removed from the URL. So lets take a look at what the above URL would look like in Partial Rewriting form.

```
http://www.mydomain.com/index.cfm/say/hello
```

As you can see this form of URLs are much cleaner. We've trimmed off most of the unnecessary pieces of the URL. What remains is the protocol, domain, and file like before, but now we sprinkle some Wheels magic. The next item on the URL is the controller in this case `say` and finally the action to invoke in that controller which in this case is `hello`.

Here is where we start depending on some server capabilities though. In order for partial URLs to work, your server environment must support Path Info.Typically this means that the Servlet Engine you are using for your CFML engine must support Path Info. A server that supports the Path Info variable will take whatever was on the query string beyond the file name, in the example above `/say/hello`, and make it available to the application by passing it in the cgi variable path\_info.

That is how Wheels knows what controller and action you want to call. Unfortunately this information is not always passed along. For example the Jetty servlet engine does not support Path info so if you use the Railo Express server you will not be able to get Partial URLs to work. The easiest way to see if your server supports passing Path Info information is to create a test.cfm page and put the following code in the page.

```
<cfoutput>#cgi.path_info#</cfoutput>
```

Then call the page using a URL like:

```
http://my-dev-server/test.cfm/more/information/to/pass
```

Obviously you'll have to change `my-dev-server` to the path of the server you placed your test page on. But what is important is what comes after the `test.cfm` file name. If your server supports Path Info then your test page should output:

```
more/information/to/pass
```

So that is Partial URL Rewriting. The URLs are shorter and cleaner than No URL Rewriting and typically don't require you to configure anything. Your server either supports them or it doesn't. Wheels will automatically determine if your server supports them and begin using them so really there is nothing for you to do here. The only issue with these URLs is the `index.cfm` in the middle of the URL. Lets see how we can get rid of that as well.

### Full URL Rewriting ###

So far we've looked at standard URLs with no rewriting applied and Partial URL Rewriting. Now we'll look at Full URL rewriting. This class of URLs eliminate the `index.cfm` from the URL as well. We know we are always routing things through a single file, so why should we have to specify it on every URL. Well in short we don't! So the above URL in Full URL Rewriting more would look like this:

```
http://www.mydomain.com/say/hello
```

Now we're getting somewhere. We're using all the magic Wheels has to offer. We've gotten rid of the `index.cfm` from the URLs so your application can live along side a Ruby on Rails application or a Django application and have the same pretty URLs. So how does Wheels do this. Although Wheels can support this third class of URLs it requires some additional capabilities from your server environment. First of all it requires Path Info support similar to Partial URL Rewriting but it also requires additional URL processing support by your web server.

On Apache web servers the `mod_rewrite` module is required. We won't get into how to install that but if it is installed in your Apache server then you can use it and wheels has a configuration file that you can use right away. On IIS 6.0 servers this capability is not built in but can be added using [IIRF](http://cheeso.members.winisp.net/IIRF.aspx).

Wheels ships with two configuration files for Apache there is a `.htaccess' file at the root of the Wheels directory and for IIS there is a `IsapiRewrite4.ini` configuration file also at the root of the Wheels directory. You only need one of these files but the other is there in case you decide to move your application to a different server and change technologies.

Lets take a look at the contents of the `.htaccess` file as it ships with the Wheels distribution.

```
# this file can be deleted if you're not planning on using URL rewriting with Apache.

# you can add your own files and folders that should be excluded from URL rewriting by adding them to the "RewriteCond" line below.

# please read the online documentation on http://cfwheels.org for more information about URL rewriting.


# UNCOMMENT ALL LINES BELOW THIS ONE TO TURN ON THE URL REWRITING RULES

# Options +FollowSymLinks

# RewriteEngine On

# RewriteCond %{REQUEST_URI} !^.*/(flex2gateway|jrunscripts|cfide|cfformgateway|railo-context|files|images|javascripts|miscellaneous|stylesheets|robots.txt|sitemap.xml|rewrite.cfm)($|/.*$) [NC]
# RewriteRule ^(.*)$ ./rewrite.cfm/$1 [L]
```

As the contents of the file suggest you need to uncomment the last few lines to turn on the Rewriting Engine and configure the rules for the Wheels framework.

The contents of the `IsapiRewrite4.ini` file are similarly commented out and look like this:

```
# this file can be deleted if you're not planning on using URL rewriting with IIS 6.

# you can add your own files and folders that should be excluded from URL rewriting by adding them to the first "RewriteRule" line below.

# please read the online documentation on http://cfwheels.org for more information about URL rewriting.


# UNCOMMENT ALL LINES BELOW THIS ONE TO TURN ON THE URL REWRITING RULES

# RewriteRule (^/(flex2gateway|jrunscripts|cfide|cfformgateway|railo-context|files|images|javascripts|miscellaneous|stylesheets|robots.txt|sitemap.xml|rewrite.cfm)($|/.*$)) $1 [L,I]
# RewriteRule ^/(.*)$ /rewrite.cfm/$1 [L]
```

Once again you'll have to uncomment the last few lines of the file before the configuration rules take effect but you first have to make sure the `IsapiRewrite4.dll` is installed and functioning properly.

So how does all this magic work? In Full Rewriting mode, Wheels takes the passed in URL...

```
http://www.mydomain.com/say/hello
```

...and converts it to the following:

```
http://www.mydomain.com/rewrite.cfm/say/hello
```

From that point on the URL is treated like a Partial Rewriting URL as we discussed above. All this is happening in the background without you having to do anything beyond the initial configuration.

So we've seen the three different classes of URLs that Wheels supports. We've seen how Partial URL Rewriting depends on the server support for Path Info CGI variables and also how the Full URL Rewriting require a rewriting engine like mod\_rewrite for Apache or IIRF for IIS 6.0 in addition to Path Info CGI support.
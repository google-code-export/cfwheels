## The Theory Behind Testing ##

At some point your code is going to break and the scary thing is it might not even be your fault. Upgrades, feature enhancements, bug fixes are all part of the development lifecycle and with deadlines and screaming managers you don't have the time to test the functionality of your entire application with every change you make.

The problem is that today's fix could be tomorrow's bug. What if there was an automated way of seeing if that change you're making is going to break something? That's where writing tests for your application can be invaluable.

In the past writing test against your application meant downloading, configuring and learning a completely separate framework. Often times this caused more headaches then it was worth and was the reason why most developers didn't bother writing tests. With Wheels we've included a small and very simple testing framework to help address just this issue.

With Wheels, writing tests for your application is part of the development lifecycle itself and running the test is as simple as clicking a link.

## Touring the Testing Framework ##

Like everything else in Wheels, the testing framework is very simple yet powerful. You're not going to having to remember a hundred different commands and methods since Wheels' testing framework has only three commands and four methods (you can't get any simpler than that). Let's take a tour and go over the conventions, commands and methods that make up the different parts of the Testing Framework:

### Writing Tests ###

Any components that will contain tests **MUST** extend the **_wheelsMapping.Test_** component:

```
<cfcomponent extends="wheelsMapping.Test">
```

If the testing engine sees that a component **DOES NOT** extend **_wheelsMapping.Test_**, that component skipped. This let's you create and store any _mock_ components you might want to use with your tests and keep everything together.

Any methods that will be used as tests **MUST** begin their name with **_test_**:

```
<cffunction name="testAEqualsB">
```

If a method **DOES NOT** begin with **_test_** it is ignored and skipped. This let's you create as many helper methods for your testing components as you want.

### Conventions ###

<font color='red'>DO NOT VAR ANY VARIABLES</font>**used in your tests. In order for the testing framework to get access to the variables within the tests that you're writing, all variables need to be within the components**variables scope**. The easy way to do this is to just not "var" variables within your tests and Railo/ColdFusion will automatically assign these variables into the variables scope of the component for you.**

The only gotcha with this approach is that this could cause some variables to overwrite each other and gets kinda of confusing of what's being thrown into the variables scope. In order to prevent this, we recommend that you create your own sudo-scope by prepending the variables used within your test. The suggested scope to use is **_loc_**. You will see this scope used through the examples below.

### Evaluation ###

**assert():** This is the main method that you will be using when developing tests. To use, all you have to do is provide a quoted expression. The power of this is that **ANY** expression can be used.

An example test that checks that two values equal each other:

```
<cffunction name="testAEqualsB">
	<cfset loc.a = 1>
	<cfset loc.b = 1>
	<cfset assert("loc.a eq loc.b")>
</cffunction>
```

An example test that checks that the first value is less then the second value:

```
<cffunction name="testAIsLessThanB">
	<cfset loc.a = 1>
	<cfset loc.b = 5>
	<cfset assert("loc.a lt loc.b")>
</cffunction>
```

You get the idea since you've used these kinds of expressions a thousand times. If you think of the assert() command as another way of using [evaluate()](http://livedocs.adobe.com/coldfusion/8/htmldocs/functions_e-g_03.html), it will all make sense. Remember that you can use **ANY** expression, so you can write assertions against structures, arrays, objects, you name it, you can test it!

An example test that checks that a key exists in a structure:

```
<cffunction name="testKeyExistsInStructure">
	<cfset loc.a = {a=1, b=2, c=3}>
	<cfset loc.b = "d">
	<cfset assert("StructKeyExists(loc.a, loc.b)")>
</cffunction>
```

**raised():** Used when you want to test that an exception will be thrown. Raised() will raise and catch the exception and return to you the exception type (think cfcatch.type). Just like assert(), raised() takes a quoted expression as it's argument.

An example of raising the Wheels.TableNotFound error when you specify an invalid model name:

```
<cffunction name="testTableNotFound">
	<cfset loc.e = raised("model('thisHasNoTable')")>
	<cfset loc.r = "Wheels.TableNotFound">
	<cfset assert("loc.e eq loc.r")>
</cffunction>
```

### Debugging ###

**debug():** Will display it's output after the test result so you can examine an expression more closely.

  * expression (string) - a quoted expression to display
  * display (boolean) - whether or not to display the output

_NOTE:_ overloaded arguments will be passed to the internal cfdump attributeCollection.

An example of displaying the debug output:

```
<cffunction name="testKeyExistsInStructure">
	<cfset loc.a = {a=1, b=2, c=3}>
	<cfset loc.b = "d">
	<cfset debug("loc.a")>
	<cfset assert("StructKeyExists(loc.a, loc.b)")>
</cffunction>
```

An example of calling debug but NOT displaying the output:

```
<cffunction name="testKeyExistsInStructure">
	<cfset loc.a = {a=1, b=2, c=3}>
	<cfset loc.b = "d">
	<cfset debug("loc.a", false)>
	<cfset assert("StructKeyExists(loc.a, loc.b)")>
</cffunction>
```

An example of displaying the output of debug as `text`:

```
<cffunction name="testKeyExistsInStructure">
	<cfset loc.a = {a=1, b=2, c=3}>
	<cfset loc.b = "d">
	<cfset debug(expression="loc.a", format="text")>
	<cfset assert("StructKeyExists(loc.a, loc.b)")>
</cffunction>
```

### Setup and Teardown ###

It's common when writing a group of tests that there will be some duplicate code, global configuration, and/or cleanup needed to be run before or after each test. In order to keep things DRY (Don't Repeat Yourself), the testing framework offers two special methods that you can optionally use to handle such configuration.

**setup():** Used to initialize or override any variables or execute any code that needs to be run **BEFORE EACH** test.

**teardown():** Used to cleanup any variables or execute any code that needs to be ran **AFTER EACH** test.

Example:

```
<cfcomponent extends="wheelsMapping.Test">

	<cffunction name="setup">
		<cfset loc.controller = $controller(name="dummy")>
		<cfset loc.f = loc.controller.distanceOfTimeInWords>
		<cfset loc.args = {}>
		<cfset loc.args.fromTime = now()>
		<cfset loc.args.includeSeconds = true>
	</cffunction>

	<cffunction name="testWithSecondsBelow5Seconds">
		<cfset loc.c = 5 - 1>
		<cfset loc.args.toTime = DateAdd('s', c, args.fromTime)>
		<cfinvoke method="loc.f" argumentCollection="#loc.args#" returnVariable="loc.e">
		<cfset loc.r = "less than 5 seconds">
		<cfset assert("loc.e eq loc.r")>
	</cffunction>

	<cffunction name="testWithSecondsBelow10Seconds">
		<cfset loc.c = 10 - 1>
		<cfset loc.args.toTime = DateAdd('s', loc.c, loc.args.fromTime)>
		<cfinvoke method="loc.f" argumentCollection="#loc.args#" returnVariable="loc.e">
		<cfset loc.r = "less than 10 seconds">
		<cfset assert("loc.e eq loc.r")>
	</cffunction>

</cfcomponent>
```

## Testing Your Application ##

In order to run tests against your application, you must first create a `tests` directory off the root of your Wheels application. All tests **MUST** reside in the `tests` directory or within a subdirectory thereof.

When you run the tests for your application, Wheels recursively scans your application's `tests` directory and looks for any available valid tests to run, so feel free to organize the subdirectories and place whatever files needed to run your tests under the `tests` directory any way you like.

### Model Testing ###

The first part of your application that you are going to want to test against are your models since this is where all the business logic of your application lives. Suppose that we have the following model:

```
<cfcomponent extends="Model" output="false">

	<cffunction name="init">

		<!--- validations on the properties of model --->
		<cfset validatesPresenceOf("username,firstname,lastname")>
		<cfset validatesPresenceOf(property="password", when="oncreate")>
		<cfset validatesConfirmationOf(property="password", when="oncreate")>
		
		<!--- we never want to retrieve the password --->
		<cfset afterFind("blankPassword")>
		
		<!--- this callback will secure the password when the model is saved --->
		<cfset beforeSave("securePassword")>
		
	</cffunction>
	
	<cffunction name="securePassword" access="private">
		
		<cfif not len(this.password)>
			<!--- we remove the password if it is blank. the password could be blank --->
			<cfset structdelete(this, "password")>
		<cfelse>
			<!--- else we secure it --->
			<cfset this.password = _securePassword(this.password)>
		</cfif>
		
	</cffunction>	
	
	<cffunction name="_securePassword">
		<cfargument name="password" type="string" required="true">
		
		<cfreturn hash(arguments.password)>	
			
	</cffunction>
	
	<cffunction name="_blankPassword" access="private">
		
		<cfif StructKeyExists(arguments, "password")>
			<cfset arguments.password = "">
		</cfif>
		<cfreturn arguments>
		
	</cffunction>

</cfcomponent>
```

As you can see from the code above, our model has 4 properties (username, firstname, lastname and password). We have some validations against these properties and a callback that runs whenever a new model is created. Let's get started writing some tests against this model to make sure that these validations and callback work properly.

First, create a test component and in the setup create an instance of the model that we can use in each test we write along with some default values for the properties of the model using a structure.

```
<cfcomponent extends="wheelsMapping.Test">
	
	<cffunction name="setup">
		
		<!--- create an instance of our model --->
		<cfset loc.user = model("user").new()>
		
		<!--- a struct that we wil use to set values of the property of the model --->
		<cfset loc.properties = {
			username = "myusername"
			,firstname = "Bob"
			,lastname = "Parkins"
			,password = "something"
			,passwordConfirmation = "something"
		}>
	</cffunction>
	
</cfcomponent>
```

As you can see we invoke our model by using the _model()_ method just like you would normally do in your controllers:

The first thing we want to test is that if we assign are default properties to the model that the model will pass validations:

```
<cffunction name="test_user_valid">
	
	<!--- set the properties of the model --->
	<cfset loc.user.setProperties(loc.properties)>
	
	<!--- assert that because the properties are set correct and meet validation, the model is valid --->
	<cfset assert("loc.user.valid() eq true")>
	
</cffunction>
```

Next, we add a simple test to make sure that the validatons we add to our model work. Notice that we haven't assigned values to any of the properties of the model:

```
<cffunction name="test_user_not_valid">
	
	<!--- assert the model is invalid when no properties are set --->
	<cfset assert("loc.user.valid() eq false")>
	
</cffunction>
```

Now we write a more specific test against the validations. Why don't we want make sure that when a password and passwordConfirmation are passed to the model and they are different, the model becomes invalid:

```
<cffunction name="test_user_not_valid_password_confirmation">
	
	<!--- change the passwordConfirmation property so it doesn't match the password property --->
	<cfset loc.properties.passwordConfirmation = "something1">
	
	<!--- set the properties of the model --->
	<cfset loc.user.setProperties(loc.properties)>
	
	<!--- assert that because the password and passwordConfirmation DO NOT match, the model is invalid --->
	<cfset assert("loc.user.valid() eq false")>
	
</cffunction>
```

We now have tests to make sure that the validations in model work. Now it's time to make sure that the callback works propertly when a valid model is created:

```
<cffunction name="test_password_secure_before_save_testing_a_callback">
	
	<!--- set the properties of the model --->
	<cfset loc.user.setProperties(loc.properties)>
	
	<!--- call the _securePassword directly so we can test the value after the record is saved --->
	<cfset loc.hashed = loc.user._securePassword(loc.properties.password)>
	
	<!--- 
		save the model, but use transactions so we don't actually write to the database.
		this prevents us from having to have to reload a new copy of the database everytime the test run
	--->
	<cfset loc.user.save(transaction="rollback")>
	
	<!--- get the password property of the model --->
	<cfset loc.password = loc.user.password>
	
	<!--- make sure that password was hashed --->
	<cfset assert('loc.password eq loc.hashed')>
	
</cffunction>
```

### Controller Testing ###

The next part of our application that we need to test is our controllers. Below is what a typically controller for our user model would contain for creating and dsiplaying a list of users:

```
<cfcomponent extends="Controller" output="false">
	
	<!--- users/index --->
	<cffunction name="index">
		<cfset users = model("User").findAll()>
	</cffunction>
	
	<!--- users/new --->
	<cffunction name="new">
		<cfset user = model("User").new()>
	</cffunction>
	
	<!--- users/create --->
	<cffunction name="create">
		<cfset user = model("User").new(params.user)>
		
		<!--- Verify that the user creates successfully --->
		<cfif user.save()>
			<cfset flashInsert(success="The user was created successfully.")>
			<!--- notice something about the next line? --->
			<cfreturn redirectTo(action="index", delay="true")>
		<!--- Otherwise --->
		<cfelse>
			<cfset flashInsert(error="There was an error creating the user.")>
			<cfset renderPage(action="new")>
		</cfif>
	</cffunction>
	
</cfcomponent>
```

**Woa woa woa**, what in the world is that `cfreturn` doing in the `create` action and why doesn the `redirectTo()` method have a `delay` argument? First, I would like to say that I'm very proud of you for noticing that line :) Secondly the reason for this is quite simple, underneath the hood when you call `redirectTo()`, Wheels is using `cflocation`. As we all know, there is no way to intercept or stop a cflocation from happening. This can cause quite a number of problems when testing out a controller as you will never be able to get back any information about the redirection. To work around this, Wheels allow you to "delay" the execution of a redirect until after the controller has finished processing. This allow Wheels to gather and present some information to you about what redirection will occur. The drawback to this though is that the controller will continue processing and as such we need to explicitly exit out of the controller action on our own, thus the reason why we use `cfreturn`.

Now we can look at the test we will write to make sure the create action works as expected:

```
<cfcomponent extends="wheelsMapping.Test">
	
	<cffunction name="test_redirects_to_index_after_a_user_is_created">
		
		<!--- default params that are required by the controller --->
		<cfset loc.params = {controller="users", action="create"}>
		
		<!--- set the user params for creating a user --->
		<cfset loc.params.user = {
			username = "myusername"
			,firstname = "Bob"
			,lastname = "Parkins"
			,password = "something"
			,passwordConfirmation = "something"
		}>
		
		<!--- create an instance of the controller --->
		<cfset loc.controller = controller(name="users", params=loc.params)>

		<!--- process the create action of the controller --->
		<cfset loc.controller.$processAction()>
		
		<!--- get the information about the redirect that should have happened --->
		<cfset loc.redirect = loc.controller.$getRedirect()>
		
		<!--- make sure that the redirect happened --->
		<cfset assert('StructKeyExists(loc.redirect, "$args")')>
		<cfset assert('loc.redirect.$args.action eq "index"')>
		
	</cffunction>

</cfcomponent>
```

Obviously a lot more goes into testing a controller then a model. The first step is setting up the params that will need to be passed to the controller. Next we have to create an instance of the controller. Finally we tell the controller to process the action that we want to test.

After the controller is finished processing the action, we can get the information about the redirection that happened by using the $getRedirect() method. We use this information to make sure that the controller redirected the visitor to the `index` action once the action was completed.

### View Testing ###

The last part of your application that we will look at testing is the `view` layer. Below is the view for the code (new.cfm) that are controller's new action would call:

```
<cfoutput>
<h1>Create a New user</h1>

#flashMessages()#

#errorMessagesFor("user")#

#startFormTag(action="create")#

	
	#textField(objectName='user', property='username', label='Username')#
		
	#passwordField(objectName='user', property='password', label='Password')#
	#passwordField(objectName='user', property='passwordConfirmation', label='Confirm Password')#
		
	#textField(objectName='user', property='firstname', label='Firstname')#
		
	#textField(objectName='user', property='lastname', label='Lastname')#

	#submitTag()#
	
#endFormTag()#

#linkTo(text="Return to the listing", action="index")#
</cfoutput>
```

Testing the view layer is very simiailar to testing controllers, you will create an instance of the controller, passing in the params required for the controller's action to run. The main difference is we will be calling the `response()` action of the controller which will return to us the output that the view generated. Once we have this output, we can then search through it to make sure that whenever we wanted the view to display is presented to our visitor. In the test below, we want to make sure that if the visitor recieves an error when creating a new user, a flash message is displaying telling them that errors have occurred.

```
<cfcomponent extends="wheelsMapping.Test">
	
	<cffunction name="test_errors_display_when_new_user_is_invalid">
		
		<!--- setup some default params for the tests --->
		<cfset loc.params = {controller="users", action="create"}>
		
		<!--- create an empty user param to pass to the controller action --->
		<cfset loc.params.user = StructNew()>
		
		<!--- create an instance of the controller --->
		<cfset loc.controller = controller("users", loc.params)>
		
		<!--- process the create action of the controller --->
		<cfset loc.controller.$processAction()>
		
		<!--- get copy of the code the view generated --->
		<cfset loc.response = loc.controller.response()>
		
		<!--- make sure the flashmessage was displayed  --->
		<cfset loc.message = '<div class="flashMessages">'>
		<cfset assert('loc.response contains loc.message')>
		
	</cffunction>

</cfcomponent>
```

## Running Tests ##

Down in the debug area of your Wheels application (that grey area at the bottom of the page), you will notice a couple of **Run Tests** links in the following areas:

**Application Name** and **Plugins**.These links runs the following suite of tests:

**Application Name**: Runs any tests that you have created for your application. You should run these tests before deploying your application.

**Plugins**: A **Run Tests** link will be next to **each** installed plugin you have in your wheels installation. You should run these tests whenever you install or update a plugin. **NOTE:** the `Run Tests` will appear if there are no tests that were packaged with the plugin.

### Running Selected Test Packages ###

Very often you might want to only run a package of tests (a group of tests within a single directory). In order to do this, just append the **package** argument to the url with the name of the package you want to run. For instance, say you had a test package called UserVerifcation. To run only that test package, add **&package=UserVerifcation** to the end of the test url.
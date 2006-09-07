<!--- 
	IMPORTANT: Only use this file if you have ColdFusion MX 7 or higher
	If you have ColdFusion MX 6.1 you should use Application.cfm instead and can safely delete this file
--->
<cfcomponent>

	<cfset appName = GetDirectoryFromPath(getBaseTemplatePath())>
	<cfset appName = left(appName, len(appName)-1)>
	<cfset appName = replace(appName, "\", "/", "all")>
	<cfset appName = reverse(spanExcluding(reverse(appName), "/"))>
	<cfset this.name = appName>
	<cfset this.clientManagement = false>
	<cfset this.sessionManagement = true>
	
	<!--- Runs the first time the application is started --->
	<cffunction name="onApplicationStart">
	
		<cflock scope="application" type="exclusive" timeout="30">
	
			<!--- Component paths --->
			<cfset application.componentPathTo = structNew()>
			<cfset application.filePathTo = structNew()>
			<cfset application.componentPathTo.controllers = "app.controllers">
			<cfset application.filePathTo.controllers = "/app/controllers">
			<cfset application.componentPathTo.models = "app.models">
			<cfset application.filePathTo.models = "/app/models">
			<!---
			<cfset application.componentPathTo.generatedModels = application.componentPathTo.models & ".generated">
			<cfset application.filePathTo.generatedModels = application.filePathTo.models & "/generated">
			--->
			
			<!--- App directory paths --->
			<cfset application.pathTo = structNew()>
			<cfset application.pathTo.app = "/app">
			<cfset application.pathTo.cfwheels = "/cfwheels">
			<cfset application.pathTo.config = "/config">
			<cfset application.pathTo.views = application.pathTo.app & "/views">
			<cfset application.pathTo.layouts = application.pathTo.views & "/layouts">
			<cfset application.pathTo.helpers = application.pathTo.app & "/helpers">
			<cfset application.pathTo.includes = application.pathTo.cfwheels & "/includes">
			
			<!--- Default public paths --->
			<cfset application.pathTo.images = "/images">
			<cfset application.pathTo.stylesheets = "/stylesheets">
			<cfset application.pathTo.javascripts = "/javascripts">
			
			<!--- File system paths --->
			<cfset application.absolutePathTo = structNew()>
			<cfset application.absolutePathTo.webroot = expandPath("/")>
			<cfset application.absolutePathTo.cfwheels = expandPath(application.pathTo.cfwheels)>
			
			<!--- Setup some sensible defaults --->
			<cfset application.default = structNew()>
			<cfset application.default.action = "index">
			
			<!--- Include some Wheels specific stuff --->
			<cfinclude template="#application.pathTo.includes#/application_includes.cfm">
			
			<!--- Take the framework functions and save them to application --->
			<cfset application.core = structNew()>
			<cfinclude template="#application.pathTo.includes#/core_includes.cfm">
	
			<!--- Include environment and database connection info --->
			<cfinclude template="#application.pathTo.config#/environment.cfm" />
			<cfinclude template="#application.pathTo.config#/database.cfm" />
	
		</cflock>
	
	</cffunction>
	
	
	<!--- Runs when the application ends or the server is shut down --->
	<cffunction name="onApplicationEnd">
	
	</cffunction>
	
	
	<!--- Runs the first time a user comes to the site (when their session begins) --->
	<cffunction name="onSessionStart">
	
	</cffunction>
	
	
	<!--- Runs when a user's session expires --->
	<cffunction name="onSessionEnd">
	
	</cffunction>
	
	
	<!--- Runs before each page load --->
	<cffunction name="onRequestStart">
		
		<!---
		<cfif (left(cgi.script_name, 8) IS "/config/" OR left(cgi.script_name, 5) IS "/app/" OR left(cgi.script_name, 10) IS "/cfwheels/") OR (left(cgi.script_name, 14) IS "/generator.cfm" AND application.settings.environment IS "production")>
			<cfthrow type="wheels.unauthorizedAccess">
		</cfif>
		--->
		
		<!--- Some handy development-only features --->
		<cfif application.wheels.environment IS "development">
			
			<!--- Reload all application variables --->
			<cfif structKeyExists(url,'reload')>
				<cfset this.onApplicationStart()>
			</cfif>
			
			<!--- Clear out session data --->
			<cfif structKeyExists(url,'clearsession')>
				<cfset structClear(session)>
			</cfif>
				
		</cfif>
		
	</cffunction>
	
	
	<!--- Runs at the end of each page load --->
	<cffunction name="onRequestEnd">
	
	</cffunction>


</cfcomponent>
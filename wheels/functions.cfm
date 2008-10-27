<cfset this.rootDir = getDirectoryFromPath(getBaseTemplatePath())>
<cfset this.name = Hash(this.rootDir & cgi.http_host)>
<cfset this.mappings["/wheels"] = this.rootDir & "wheels">
<cfset this.sessionManagement = true>

<cfinclude template="wheels/global/appfunctions.cfm">
<cfinclude template="wheels/controller/appfunctions.cfm">

<cffunction name="onApplicationStart" output="false">
	<cfset var loc = {}>
	<cfset application.wheels = StructNew()>
	<cfif StructKeyExists(server, "railo")>
		<cfset application.wheels.serverName = "Railo">
		<cfset application.wheels.serverVersion = server.railo.version>
	<cfelse>
		<cfset application.wheels.serverName = "Adobe ColdFusion">
		<cfset application.wheels.serverVersion = server.coldfusion.productversion>
	</cfif>
	<cfset loc.majorVersion = Left(application.wheels.serverVersion, 1)>
	<cfif (application.wheels.serverName IS "Railo" AND loc.majorVersion LT 3) OR (application.wheels.serverName IS "Adobe ColdFusion" AND loc.majorVersion LT 8)>
		<cfset $throw(type="Wheels.NoSupport", message="#application.wheels.serverName# #application.wheels.serverVersion# is not supported by Wheels.", extendedInfo="Upgrade to Adobe ColdFusion 8 or Railo 3.")>
	</cfif>
	<cfset application.wheels.version = "0.8.3">
	<cfif cgi.script_name IS "/rewrite.cfm">
		<cfset application.wheels.URLRewriting = "On">
	<cfelseif cgi.path_info IS NOT "">
		<cfset application.wheels.URLRewriting = "Partial">
	<cfelse>
		<cfset application.wheels.URLRewriting = "Off">	
	</cfif>
	<cfset application.wheels.controllers = StructNew()>
	<cfset application.wheels.models = StructNew()>
	<cfset application.wheels.existingModelFiles = "">
	<cfset application.wheels.existingControllerFiles = "">
	<cfset application.wheels.routes = ArrayNew(1)>
	<cfset application.wheels.namedRoutePositions = StructNew()>
	<!--- setup folder paths --->
	<cfif DirectoryExists(this.rootDir & "config")>
		<cfset loc.root = this.rootDir>
		<cfset loc.path = "">
		<cfset loc.componentPath = "">
	<cfelse>
		<cfset loc.folder = LCase(cgi.http_host)>
		<cfset loc.folder = ListDeleteAt(loc.folder, ListLen(loc.folder, "."), ".")>
		<cfset loc.folder = Replace(loc.folder, "www.", "")>
		<cfset loc.folder = Replace(loc.folder, ".co", "")>
		<cfset loc.root = this.rootDir & loc.folder & "/">
		<cfset loc.path = loc.folder & "/">
		<cfset loc.componentPath = loc.folder & ".">
	</cfif>
	<cfset application.wheels.configPath = loc.path & "config">
	<cfset application.wheels.controllerPath = loc.path & "controllers">
	<cfset application.wheels.controllerComponentPath = loc.componentPath & "controllers">
	<cfset application.wheels.eventPath = loc.path & "events">
	<cfset application.wheels.filePath = loc.path & "files">
	<cfset application.wheels.imagePath = loc.path & "images">
	<cfset application.wheels.javascriptPath = loc.path & "javascripts">
	<cfset application.wheels.modelPath = loc.path & "models">
	<cfset application.wheels.modelComponentPath = loc.componentPath & "models">
	<cfset application.wheels.pluginPath = loc.path & "plugins">
	<cfset application.wheels.pluginComponentPath = loc.componentPath & "plugins">
	<cfset application.wheels.stylesheetPath = loc.path & "stylesheets">
	<cfset application.wheels.viewPath = loc.path & "views">
	<!--- Set up struct for caches --->
	<cfset application.wheels.cache = StructNew()>
	<cfset application.wheels.cache.internal = StructNew()>
	<cfset application.wheels.cache.internal.sql = StructNew()>
	<cfset application.wheels.cache.internal.image = StructNew()>
	<cfset application.wheels.cache.external = StructNew()>
	<cfset application.wheels.cache.external.main = StructNew()>
	<cfset application.wheels.cache.external.action = StructNew()>
	<cfset application.wheels.cache.external.page = StructNew()>
	<cfset application.wheels.cache.external.partial = StructNew()>
	<cfset application.wheels.cache.external.query = StructNew()>
	<cfset application.wheels.cacheLastCulledAt = Now()>
	<!--- load environment settings --->
	<cfif StructKeyExists(URL, "reload") AND NOT IsBoolean(URL.reload) AND Len(url.reload) AND (Len(application.settings.reloadPassword) IS 0 OR (StructKeyExists(URL, "password") AND URL.password IS application.settings.reloadPassword))>
		<cfset application.settings.environment = URL.reload>
	<cfelse>
		<cfinclude template="../#application.wheels.configPath#/environment.cfm">
	</cfif>
	<cfinclude template="../#application.wheels.configPath#/settings.cfm">
	<cfinclude template="../#application.wheels.configPath#/environments/#application.settings.environment#.cfm">
	<!--- Load developer routes and add wheels default ones --->
	<cfinclude template="../#application.wheels.configPath#/routes.cfm">
	<cfinclude template="routes.cfm">
	<cfset application.wheels.webPath = Replace(cgi.script_name, Reverse(spanExcluding(Reverse(cgi.script_name), "/")), "")>
	<!--- load plugins --->
	<cfset application.wheels.plugins = {}>
	<cfset loc.pluginFolder = this.rootDir & "plugins">
	<!--- get a list of plugin files and folders --->
	<cfset loc.pluginFolders = $directory(directory=loc.pluginFolder, type="dir")>
	<cfset loc.pluginFiles = $directory(directory=loc.pluginFolder, filter="*.zip", type="file", sort="name DESC")>
	<!--- delete plugin folders if no corresponding plugin file exist --->
	<cfloop query="loc.pluginFolders">
		<cfif name IS NOT ".svn" AND ListContainsNoCase(ValueList(loc.pluginFiles.name), name & "-") IS 0>
			<cfset loc.temp = directory & "/" & name>
			<cfdirectory action="delete" directory="#loc.temp#" recurse="true">
		</cfif>
	</cfloop>
	<!--- create directory and unzip code for the most recent version of each plugin --->
	<cfif loc.pluginFiles.recordCount IS NOT 0>
		<cfloop query="loc.pluginFiles">
			<cfset loc.pluginName = ListFirst(name, "-")>
			<cfif NOT StructKeyExists(application.wheels.plugins, loc.pluginName)>
				<cfset loc.pluginVersion = Replace(ListLast(name, "-"), ".zip", "", "one")>
				<cfset loc.thisPluginFile = loc.pluginFolder & "/" & name>
				<cfset loc.thisPluginFolder = loc.pluginFolder & "/" & LCase(loc.pluginName)>
				<cfif NOT DirectoryExists(loc.thisPluginFolder)>
					<cfdirectory action="create" directory="#loc.thisPluginFolder#">
					<cfzip action="unzip" destination="#loc.thisPluginFolder#" file="#loc.thisPluginFile#"></cfzip>
				</cfif>
				<cfset loc.fileName = LCase(loc.pluginName) & "." & loc.pluginName>
				<cfset loc.rootObject = "pluginObject">
				<cfinclude template="../root.cfm">
				<cfset application.wheels.plugins[loc.pluginName] = loc.rootObject>
				<cfif application.wheels.plugins[loc.pluginName].version IS NOT application.wheels.version>
					<cfset $throw(type="Wheels.IncompatiblePlugin", message="#loc.pluginName# is incompatible with this version of Wheels.", extendedInfo="You're running version #application.wheels.version# of Wheels and the #loc.pluginName# plugin you have installed only supports version #application.wheels.plugins[loc.pluginName].version#. Download a new version of #loc.pluginName#, drop it in the 'plugins' folder and restart Wheels by issuing a 'reload=true' request.")>
				</cfif>
			</cfif>
		</cfloop>
		<!--- look for plugins that are incompatible with each other --->
		<cfset loc.addedFunctions = "">
		<cfloop list="#StructKeyList(application.wheels.plugins)#" index="loc.i">
			<cfloop list="#StructKeyList(application.wheels.plugins[loc.i])#" index="loc.j">
				<cfif NOT ListFindNoCase("init,version", loc.j)>
					<cfif ListFindNoCase(loc.addedFunctions, loc.j)>
						<cfset $throw(type="Wheels.IncompatiblePlugin", message="#loc.i# is incompatible with a previously installed plugin.", extendedInfo="make sure none of the plugins you have installed overrides the same Wheels functions.")>
					<cfelse>
						<cfset loc.addedFunctions = ListAppend(loc.addedFunctions, loc.j)>			
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
	</cfif>
	<cfif application.settings.environment IS NOT "maintenance">
		<!--- determine and set database brand --->
		<cfinclude template="../#application.wheels.configPath#/database.cfm">
		<cfif !Len(application.settings.database.datasource)>
			<cfset application.settings.database.datasource = LCase(ListLast(this.rootDir, Right(this.rootDir, 1)))>
		</cfif>
		<cftry>
			<cfset loc.info = $dbinfo(datasource=application.settings.database.datasource, username=application.settings.database.username, password=application.settings.database.password, type="version")>
		<cfcatch>
			<cfset $throw(type="Wheels.DataSourceNotFound", message="The '#application.settings.database.datasource#' data source could not be found.", extendedInfo="You need to add a data source with this name in the #application.wheels.serverName# Administrator before running Wheels. You can specify a different name for the data source in 'config/database.cfm' if necessary.")>
		</cfcatch>
		</cftry>
		<cfif loc.info.driver_name Contains "MySQL">
			<cfset loc.adapterName = "MySQL">
		<cfelseif loc.info.driver_name Contains "Oracle">
			<cfset loc.adapterName = "Oracle">
		<cfelseif loc.info.driver_name Contains "SQLServer">
			<cfset loc.adapterName = "MicrosoftSQLServer">
		<cfelse>
			<cfset $throw(type="Wheels.NoSupport", message="#loc.info.database_productname# is not supported by Wheels.", extendedInfo="Use Microsoft SQL Server, Oracle or MySQL.")>
		</cfif>
		<cfset application.wheels.adapter = CreateObject("component", "wheels.#loc.adapterName#")>
		<cfset application.wheels.databaseProductName = loc.info.database_productname>
		<cfset application.wheels.databaseVersion = loc.info.database_version>
	</cfif>
	<cfset application.wheels.dispatch = CreateObject("component", "wheels.Dispatch")>
	<cfinclude template="../#application.wheels.eventPath#/onapplicationstart.cfm">
</cffunction>

<cffunction name="onSessionStart" output="false">
	<cflock scope="application" type="readonly" timeout="30">
		<cfinclude template="../#application.wheels.eventPath#/onsessionstart.cfm">
	</cflock>
</cffunction>

<cffunction name="onRequestStart" output="false">
	<cfargument name="targetPage">
	<cfset var loc = {}>
		<cfif Right(arguments.targetPage, 4) IS ".cfc">
		<cfset StructDelete(this, "onRequest")>
		<cfset StructDelete(variables, "onRequest")>
	</cfif>
	<cfif StructKeyExists(URL, "reload") AND (Len(application.settings.reloadPassword) IS 0 OR (StructKeyExists(URL, "password") AND URL.password IS application.settings.reloadPassword))>
		<cflock scope="application" type="exclusive" timeout="30">
			<cfset onApplicationStart()>
		</cflock>
	</cfif>
	<cflock scope="application" type="readonly" timeout="30">
		<cfif application.settings.environment IS "maintenance">
			<cfif StructKeyExists(URL, "except")>
				<cfset application.settings.ipExceptions = URL.except>
			</cfif>
			<cfif Len(application.settings.ipExceptions) IS 0 OR ListFind(application.settings.ipExceptions, cgi.remote_addr) IS 0>
				<cfinclude template="../#application.wheels.eventPath#/onmaintenance.cfm">
				<cfabort>
			</cfif>
		</cfif>
		<cfset request.wheels = StructNew()>
		<cfset request.wheels.params = StructNew()>
		<cfset request.wheels.cache = StructNew()>
		<cfif application.settings.showDebugInformation>
			<cfset request.wheels.execution = StructNew()>
			<cfset request.wheels.execution.components = StructNew()>
			<cfset request.wheels.execution.componentTotal = GetTickCount()>
			<cfset request.wheels.execution.components.requestStart = GetTickCount()>
		</cfif>
		<cfif NOT application.settings.cacheModelInitialization>
			<cfset structClear(application.wheels.models)>
		</cfif>
		<cfif NOT application.settings.cacheControllerInitialization>
			<cfset structClear(application.wheels.controllers)>
		</cfif>
		<cfif NOT application.settings.cacheRoutes>
			<cfset arrayClear(application.wheels.routes)>
			<cfinclude template="../#application.wheels.configPath#/routes.cfm">
			<cfinclude template="routes.cfm">
		</cfif>
		<cfif NOT application.settings.cacheDatabaseSchema>
			<cfset $clearCache("sql", "internal")>
		</cfif>
		<cfinclude template="../#application.wheels.eventPath#/onrequeststart.cfm">
		<cfif application.settings.showDebugInformation>
			<cfset request.wheels.execution.components.requestStart = GetTickCount() - request.wheels.execution.components.requestStart>
		</cfif>
	</cflock>
</cffunction>

<cffunction name="onRequest" output="true">
	<cfargument name="targetpage">
	<cflock scope="application" type="readonly" timeout="30">
		<cfinclude template="#arguments.targetpage#">
	</cflock>
</cffunction>

<cffunction name="onMissingTemplate" output="true">
	<cfargument name="targetpage">
	<cflock scope="application" type="readonly" timeout="30">
		<cfinclude template="../#application.wheels.eventPath#/onmissingtemplate.cfm">
	</cflock>
</cffunction>

<cffunction name="onError" output="true">
	<cfargument name="exception">
	<cfargument name="eventname">
	<cfset var loc = {}>
	<cflock scope="application" type="readonly" timeout="30">
		<cfif application.settings.sendEmailOnError>
			<cfmail to="#application.settings.errorEmailAddress#" from="#application.settings.errorEmailAddress#" subject="Error" type="html">
				<cfinclude template="error.cfm">
			</cfmail>
		</cfif>
		<cfif application.settings.showErrorInformation>
			<cfif NOT StructKeyExists(arguments.exception, "cause")>
				<cfset arguments.exception.cause = arguments.exception>
			</cfif>
			<cfif Left(arguments.exception.cause.type, 6) IS "Wheels">
				<cfinclude template="errors/header.cfm">
				<cfinclude template="errors/error.cfm">
				<cfinclude template="errors/footer.cfm">
			<cfelse>
				<cfthrow object="#arguments.exception#">
			</cfif>
		<cfelse>
			<cfinclude template="../#application.wheels.eventPath#/onerror.cfm">
		</cfif>
	</cflock>
</cffunction>

<cffunction name="onRequestEnd" output="true">
	<cfargument name="targetpage">
	<cfset var loc = {}>
	<cflock scope="application" type="readonly" timeout="30">
		<cfif application.settings.showDebugInformation>
			<cfset request.wheels.execution.components.requestEnd = getTickCount()>
		</cfif>
		<cfinclude template="../#application.wheels.eventPath#/onrequestend.cfm">
		<cfif application.settings.showDebugInformation>
			<cfset request.wheels.execution.components.requestEnd = GetTickCount() - request.wheels.execution.components.requestEnd>
		</cfif>
		<cfinclude template="debug.cfm">
	</cflock>
</cffunction>

<cffunction name="onSessionEnd" output="false">
	<cfargument name="sessionscope">
  <cfargument name="applicationscope">
	<cflock scope="application" type="readonly" timeout="30">
		<cfinclude template="../#arguments.applicationscope.wheels.eventPath#/onsessionend.cfm">
	</cflock>
</cffunction>

<cffunction name="onApplicationEnd" output="false">
	<cfargument name="applicationscope">
	<cfinclude template="../#arguments.applicationscope.wheels.eventPath#/onapplicationend.cfm">
</cffunction>
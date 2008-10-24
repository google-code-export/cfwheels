<cfif loc.rootObject IS "controllerClass">
	<cfset loc.rootObject = CreateObject("component", "#application.wheels.controllerComponentPath#.#capitalize(arguments.name)#").$initControllerClass(arguments.name)>
<cfelseif loc.rootObject IS "controllerObject">
	<cfset loc.rootObject = CreateObject("component", "#application.wheels.controllerComponentPath#.#capitalize(variables.wheels.name)#").$initControllerObject(variables.wheels.name, arguments.params)>
<cfelseif loc.rootObject IS "modelClass">
	<cfset loc.rootObject = CreateObject("component", "#application.wheels.modelComponentPath#.#loc.fileName#").$initClass(arguments.name)>
<cfelseif loc.rootObject IS "modelObject">
	<cfset loc.rootObject = CreateObject("component", "#application.wheels.modelComponentPath#.#capitalize(variables.wheels.class.name)#").$initObject(name=variables.wheels.class.name, properties=arguments.properties, persisted=arguments.persisted, row=arguments.row)>
<cfelseif loc.rootObject IS "pluginObject">
	<cfset loc.rootObject = CreateObject("component", "#application.wheels.pluginComponentPath#.#loc.fileName#").init()>
</cfif>
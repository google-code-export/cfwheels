<cfcomponent extends="wheelsMapping.test">

	<cfset global.controller = createobject("component", "wheelsMapping.tests._assets.controllers.ControllerWithModel")>

	<cffunction name="test_x_textArea_valid">
		<cfset global.controller.textArea(objectName="ModelUsers1", property="firstname")>
	</cffunction>

</cfcomponent>
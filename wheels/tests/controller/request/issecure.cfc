<cfcomponent extends="wheelsMapping.test">

	<cfinclude template="common.cfm">

	<cffunction name="test_isSecure_valid">
		<cfset request.cgi.server_port_secure = "yes">
		<cfset assert("controller.isSecure() eq true")>
	</cffunction>
	
	<cffunction name="test_isSecure_invalid">
		<cfset request.cgi.request_method = "">
		<cfset assert("controller.isSecure() eq false")>
	</cffunction>

</cfcomponent>
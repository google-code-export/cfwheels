<cfcomponent extends="wheels.test">

	<cfset global.controller = createobject("component", "wheels.controller") />
	
	<cffunction name="test_redirectTo_valid">
		<!--- not sure how we are going to test this when the end point is to redirect the browser --->
		<cfset assert("1 eq 0") />
	</cffunction>
	
</cfcomponent>
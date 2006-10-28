<cfif application.settings.environment IS "development">
	<cfif NOT structKeyExists(application.wheels, "dispatch")>
	    <cflock name="dispatchLock" type="exclusive" timeout="5">
	        <cfif NOT structKeyExists(application.wheels, "dispatch")>
	            <cfset application.wheels.dispatch = createObject("component", "dispatch")>
	        </cfif>
	    </cflock>
	</cfif>
	<cfset application.wheels.dispatch.dispatch()>
<cfelse>
	<cfset createObject("component","dispatch").dispatch()>
</cfif>
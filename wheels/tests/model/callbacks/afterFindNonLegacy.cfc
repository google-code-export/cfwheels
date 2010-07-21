<cfcomponent extends="wheelsMapping.test">

	<cffunction name="setup">
		<cfset application.wheels.afterFindCallbackLegacyCompatability = false>
		<cfset model("post").$registerCallback(type="afterFind", methods="afterFindCallback")>
	</cffunction>
	
	<cffunction name="teardown">
		<cfset application.wheels.afterFindCallbackLegacyCompatability = true>
		<cfset model("post").$clearCallbacks(type="afterFind")>
	</cffunction>

	<cffunction name="test_setting_property_on_one_object">
		<cfset loc.post = model("post").findOne()>
		<cfset assert("loc.post.title IS 'setOnQueryRecord'")>
	</cffunction>

	<cffunction name="test_setting_properties_on_multiple_objects">
		<cfset loc.postsOrg = model("post").findAll(returnAs="objects", callbacks="false", orderby="views DESC")>
		<cfset loc.views1 = loc.postsOrg[1].views + 100>
		<cfset loc.views2 = loc.postsOrg[2].views + 100>
		<cfset loc.posts = model("post").findAll(returnAs="objects", orderby="views DESC")>
		<cfset assert("loc.posts[1].title IS 'setOnQueryRecord'")>
		<cfset assert("loc.posts[2].title IS 'setOnQueryRecord'")>
		<cfset assert("loc.posts[1].views EQ loc.views1")>
		<cfset assert("loc.posts[2].views EQ loc.views2")>
	</cffunction>

</cfcomponent>
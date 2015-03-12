These functions are called from the `init` function of your controller files.

## Example ##

`controllers/Blog.cfc`:

```
<cffunction name="init">
  <cfset filters(through="userVerification")>
</cffunction>
```

## Functions ##

<font color='red'><b>THE REST OF THE CONTENT ON THIS PAGE WILL BE GENERATED FROM THE SOURCE CODE</b></font>
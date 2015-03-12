These methods are called from the `init` function of your model files.

## Example ##

`models/Author.cfc`:

```
<cffunction name="init">
  <cfset hasMany("posts")>
</cffunction>
```

## Functions ##

<font color='red'><b>THE REST OF THE CONTENT ON THIS PAGE WILL BE GENERATED FROM THE SOURCE CODE</b></font>
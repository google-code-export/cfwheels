These functions can be called from the view pages to create output for use in a HTML page. When a view helper creates a HTML tag you can set additional attributes on it by passing them in as named arguments to the function.

## Example ##

`views/blog/listauthors.cfm`:

```
<cfoutput>
  #paginationLinks(action="listArticles", windowSize=5, class="link-list")#
</cfoutput>
```

## Functions ##

<font color='red'><b>THE REST OF THE CONTENT ON THIS PAGE WILL BE GENERATED FROM THE SOURCE CODE</b></font>
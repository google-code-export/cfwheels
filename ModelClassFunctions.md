These methods operate on the class as a whole and not on individual objects and thus need to be prefaced with `model("name")`. You can call these methods from anywhere but it is **not** recommended to call them from view pages. When calling them from its own model file it is recommended to reference the scope explicitly with the `this` keyword.

## Examples ##

`controllers/Blog.cfc`:

```
<cfset allAuthors = model("author").findAll()>
```

`models/Author.cfc`:

```
<cfset allAuthors = this.findAll()>
```

## Functions ##

**Read:**
  * [findAllByXXX()](findAll.md)
  * [findAllByXXXAndXXX()](findAll.md)
  * [findOneByXXX()](findOne.md)
  * [findOneByXXXAndXXX()](findOne.md)

<font color='red'><b>THE REST OF THE CONTENT ON THIS PAGE WILL BE GENERATED FROM THE SOURCE CODE</b></font>
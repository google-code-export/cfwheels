These methods operate on individual objects which means you first have to fetch or create an object and then call the method on that object. You can call these methods from anywhere but it is not recommended to call them from view pages. When calling them from its own model file it is recommended to reference the scope explicitly with the `this` keyword.

## Example ##

`controllers/Blog.cfc`:

```
<cfset anAuthor = model("author").findByKey(1)>
<cfset anAuthor.delete()>
```

## Functions ##

**Associations (`hasMany`):**

  * [addXXX()](updateByKey.md)
  * [createXXX()](create.md)
  * [deleteXXX()](deleteByKey.md)
  * [deleteAllXXX()](deleteAll.md)
  * [findOneXXX()](findOne.md)
  * [hasXXX()](exists.md)
  * [newXXX()](new.md)
  * [removeXXX()](updateByKey.md)
  * [removeAllXXX()](updateAll.md)
  * [XXX()](findAll.md)
  * [XXXCount()](count.md)

**Associations (`hasOne`):**

  * [createXXX()](create.md)
  * [deleteXXX()](deleteOne.md)
  * [hasXXX()](exists.md)
  * [newXXX()](new.md)
  * [removeXXX()](updateOne.md)
  * [setXXX()](updateByKey.md)
  * [XXX()](findOne.md)

**Associations (`belongsTo`):**

  * [hasXXX()](exists.md)
  * [XXX()](findByKey.md)

**Changes:**
  * [XXXHasChanged()](hasChanged.md)
  * [XXXChangedFrom()](changedFrom.md)

<font color='red'><b>THE REST OF THE CONTENT ON THIS PAGE WILL BE GENERATED FROM THE SOURCE CODE</b></font>
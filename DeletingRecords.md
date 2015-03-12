Deleting records in Wheels is simple. If you have fetched an object, you can just call its [delete()](delete.md) method. If you don't have any callbacks specified for the class, all that will happen is that the record will be deleted from the table and `true` will be returned.

## Delete Callbacks ##

If you have callbacks, however, this is what happens.

First, all methods registered to be run before a delete happens (these are registered using a [beforeDelete()](beforeDelete.md) call from the `init` function) will be executed, if any exist.

If these return `true`, Wheels will proceed and delete the record from the table. If `false` is returned from the callback code, processing will return to your code without the record being deleted. (`false` is returned to you in this case.)

If the record was deleted, the [afterDelete()](afterDelete.md) callback code is executed, and whatever that code returns will be returned to you. (You should make all your callbacks return `true` or `false`.)

If you're unfamiliar with the concept of callbacks, you can read about them in the [Object Callbacks](ObjectCallbacks.md) chapter.

## Example of Deleting a Record ##

Here's a simple example of fetching a record from the database and then deleting it.

```
<cfset aPost = model("post").findByKey(33)>
<cfset aPost.delete()>
```

There are also three class-level delete methods available: [deleteByKey()](deleteByKey.md), [deleteOne()](deleteOne.md), and [deleteAll()](deleteAll.md). These work similarly to the class level methods for updating, which you can read more about in [Updating Records](UpdatingRecords.md).
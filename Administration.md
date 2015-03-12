This sample application is full of comments, so it's a good way to learn Wheels if
you prefer playing around with code rather than reading more abstract tutorials.

This sample application covers how to set up validation rules on a model, make a form for it, save to the database, and so on.

## Instructions ##

Create a new database with a table named `users` containing the following columns:

| **Name** | **Type** | **Nullable** | **Primary Key** |
|:---------|:---------|:-------------|:----------------|
| id | int, identity | No | Yes |
| firstname | varchar(100) | No | No |
| lastname | varchar(100) | No | No |
| email | varchar(100) | No | No |
| password | varchar(20) | No | No |

Add a data source in the ColdFusion or Railo Administrator named `cfwheelsUserAdministration`, pointing to your new database.

Once that's all done, just download, unzip, and run the application. (It includes
with ColdFusion on Wheels 1.0.)

## Download ##

[Download Administration Sample](http://cfwheels.googlecode.com/files/administration.1.0-r3855.zip)
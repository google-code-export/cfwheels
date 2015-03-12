The easiest way to upgrade is to setup an empty website, deploy a fresh copy of Wheels 1.0, and then transfer your application code to it. When transferring, please make note of the following changes and make the appropriate changes to your code.

**Note:** To accompany the newest 1.0 release, we've highlighted the changes that are affected by that release.

## Supported System Changes ##

  * **1.0:** URL rewriting with IIS 7 is now supported.
  * **1.0:** URL rewriting in a sub folder on Apache is now supported.
  * ColdFusion 9 is now supported.
  * Oracle 10g or later is now supported.
  * PostgreSQL is now supported.
  * Railo 3.1 is now supported.

## File System Changes ##

  * **1.0:** There is now an `app.cfm` file in the `config` folder. Use it to set variables that you'd normally set in `Application.cfc` (i.e., `this.name`, `this.sessionManagement`, `this.customTagPaths`, etc.)
  * **1.0:** There is now a `web.config` file in the root.
  * **1.0:** There is now a `Wheels.cfc` file in the `models` folder.
  * **1.0:** The `Wheels.cfc` file in the `controllers` folder has been updated.
  * **1.0:** The `IsapiRewrite4.ini` and `.htaccess` files in the root have both been updated.
  * The `controller` folder has been changed to `controllers`.
  * The `model` folder has been changed to `models`.
  * The `view` folder has been changed to `views`.
  * Rename all of your CFCs in `models` and `controllers` to UpperCamelCase. So `controller.cfc` will become `Controller.cfc`, `adminUser.cfc` will become `AdminUser.cfc`, and so on.
  * All images must now be stored in the `images` folder, files in the `files` folder, JavaScript files in the `javascripts` folder, and CSS files in the `stylesheets` folder off of the root.

## Database Structure Changes ##

  * `deletedOn`, `updatedOn`, and `createdOn` are no longer available as auto-generated fields. Please change the names to `deletedAt`, `updatedAt`, and `createdAt` instead to get similar functionality, and make sure that they are of type `datetime`, `timestamp`, or equivalent.

## CFML Code Changes ##

### Config Code ###

  * **1.0:** The `action` of the default route (`home`) has changed to `wheels`.
  * The way configuration settings are done has changed quite a bit. To change a Wheels application setting, use the new `set()` function with the name of the Wheels property to change. (For example, `<cfset set(dataSourceName="mydatasource")>`.) To see a list of available Wheels settings, refer to the [Configuration and Defaults](ConfigurationandDefaults.md) chapter.

### Model Code ###

  * **1.0:** The extends attribute in `models/Model.cfc` should now be `Wheels`.
  * `findById()` is now called `findByKey()`. Additionally, its `id` argument is now named `key` instead. For composite keys, this argument will accept a comma-delimited list.
  * When using a model's `findByKey()` or `findOne()` functions, the `found` property is no longer available. Instead, the functions return `false` if the record was not found.
  * A model's `errorsOn()` function now always returns an array, even if there are no errors on the field. When there are errors for the field, the array elements will contain a `struct` with `name`, `fieldName`, and `message` elements.
  * The way callbacks are created has changed. There is now a method for each callback event (`beforeValidation()`, `beforeValidationOnCreate()`, etc.) that should be called from your model's `init()` method. These methods take a single argument: the method within your model that should be invoked during the callback event. See the chapter on ObjectCallbacks for an example.

### View Code ###

  * **1.0:** The contents of the `views/wheels` folder have been changed.
  * The `wrapLabel` argument in form helpers is now replaced with `labelPlacement`. Valid values are `before`, `after`, and `around`.
  * The first argument for `includePartial()` has changed from `name` to `partial`. If you're referring to it through a named argument, you'll need to replace all instances with `partial`.
  * The variable that keeps a counter of the current record when using [includePartial()](includePartial.md) with a query has been renamed to `current` instead of `currentRow`.
  * There is now an included `wheels` folder in `views`. Be sure to copy that into your existing Wheels application if you're upgrading.
  * The location of the default layout has changed. It is now stored at `/views/layout.cfm`. Now controller-specific layouts are stored in their respective view folder as `layout.cfm`. For example, a custom layout for `www.domain.com/about` would be stored at `/views/about/layout.cfm`.
  * In `linkTo()`, the `id` argument is now called `key`. It now accepts a comma-delimited list in the case of composite keys.
  * The `linkTo()` function also accepts an object for the `key` argument, in which case it will automatically extract the keys from it for use in the hyperlink.
  * The `linkTo()` function can be used only for controller-, action-, and route-driven links now. The `url` argument has been removed, so now all static links should be coded using a standard `<a>` tag.

### Controller Code ###

  * **1.0:** The extends attribute in `controllers/Controller.cfc` should now be `Wheels`.
  * Multiple-word controllers and actions are now word-delimited by hyphens in the URL. For example, if your controller is called `SiteAdmin` and the action is called `editLayout`, the URL to access that action would be `http://www.domain.com/site-admin/edit-layout`.

### URL/Routing ###

  * The default route for Wheels has changed from `[controller]/[action]/[id]` to `[controller]/[action]/[key]`. This is to support composite keys. The `params.id` value will now only be available as `params.key`.
  * You can now pass along composite keys in the URL. Delimit multiple keys with a comma. (If you want to use this feature, then you can't have a comma in the key value itself).
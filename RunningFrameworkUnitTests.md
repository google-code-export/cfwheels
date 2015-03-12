## Running the Tests for Wheels itself ##

Just like writing and running tests for your application, Wheels itself has an ever growing test suite that we use to make sure things don't break as we're fixing and adding things to the framework. Whether you're contributing code, upgrading to a new version of Wheels or moving Wheels from one CFML platform to another; it's a good idea to run the unit tests for Wheels and report any failures back to one of the members of the core team or to our [Google Group](http://groups.google.com/group/cfwheels).

Please note that you have to be running the code off of our SVN repository for the tests to be available. You can check out the latest revision from the following URL:
http://code.google.com/p/cfwheels/source/checkout

Before you run the tests for Wheels, you'll need to setup an empty test database that will be used to test the model portion of Wheels.

The first thing to do is to create a database called "wheelstestdb" in your database of choice. Make sure that whatever user account you assign to the database has full access to it.

Now that the empty database is created, you'll need to create a DSN for the database from within your ColdFusion/Railo Administrator. Name the DSN "wheelstestdb" and, if necessary, enter in the username and password that you assigned to the database when creating it.

Once the SVN code has been checked out and the empty database is setup, it's now time to run the tests!

Open up the Wheels "Congratulations" page in your browser and scroll down the Wheels debug area at the bottom of the page. Next to the framework version there is a link labeled "Run Tests", click it and the entire suite of tests for Wheels will run. It could take a little bit for the entire suite to run as it populates the tables with test data, so be patient.
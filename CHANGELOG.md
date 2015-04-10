# v 0.2.4

* Fixed an issue with static table pulling where errors were not consulted/propagated.
* Fixed an incorrect URL mapping in the FOSParse.adaptermap for users.

# v 0.2.5

* BREAKING CHANGE: Parse now recommends using the 'X-Parse-Client-Key' vs. the original 'X-Parse-REST-API-Key'.  The various FOSParseServiceAdapter initialization APIs have been changed accordingly.
* Updated cache manager's cache flushing routine to ensure that any outstanding operations are completed as well as it's own push operations.
* Updated error code checking for already deleted server nodes from the (obsolete parse.com) 101 status to 404, which should be ubiquitous.
* Converted away from CONFIGURATION_Debug to simply DEBUG.

NOTE: This may mean that client code slows down execution when compiled with the DEBUG flag turned on. There are internal (documented) tests that ensure that things are working correctly, but they execute rather slowly. If the DEBUG flag is off, there should be no concerns.
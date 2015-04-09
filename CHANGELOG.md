# v 0.2.4

* Fixed an issue with static table pulling where errors were not consulted/propagated.
* Fixed an incorrect URL mapping in the FOSParse.adaptermap for users.

# v 0.2.5

* BREAKING CHANGE: Parse now recommends using the 'X-Parse-Client-Key' vs. the original 'X-Parse-REST-API-Key'.  The various FOSParseServiceAdapter initialization APIs have been changed accordingly.
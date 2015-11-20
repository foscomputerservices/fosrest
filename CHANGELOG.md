# v 0.2.4

* Fixed an issue with static table pulling where errors were not consulted/propagated.
* Fixed an incorrect URL mapping in the FOSParse.adaptermap for users.

# v 0.2.5

* BREAKING CHANGE: Parse now recommends using the 'X-Parse-Client-Key' vs. the original 'X-Parse-REST-API-Key'.  The various FOSParseServiceAdapter initialization APIs have been changed accordingly.
* Updated cache manager's cache flushing routine to ensure that any outstanding operations are completed as well as it's own push operations.
* Updated error code checking for already deleted server nodes from the (obsolete parse.com) 101 status to 404, which should be ubiquitous.
* Converted away from CONFIGURATION_Debug to simply DEBUG.

NOTE: This may mean that client code slows down execution when compiled with the DEBUG flag turned on. There are internal (documented) tests that ensure that things are working correctly, but they execute rather slowly. If the DEBUG flag is off, there should be no concerns.

# v 0.2.6

* Minor bug fixes, see logs

# v 0.2.7

* Fixed a serious issue in the way that errors were handled in FOSOperation.isReady.  Previously it looked to self.error as the comments therein indicated.  However, this caused the entire error dependency chain to be examined, which was not the intent.  The sole intent was to determine if self had an error, not the entire chain.  This was fixed by simply looking to _error vs. self.error.

  This fixes issues where an assert would be thrown ("Save op already finished???").  This would happen if a dependency of the FOSSaveOperation failed.  Since the previous implementation was to look at all depdencies for isReady, any dependency of FOSSaveOperation that might have failed would cause FOSSaveOperation to be ready, even though other dependencies were not yet ready.

# v 0.3.0

* Updated to use Xcode 7.0 beta compiler. 
* Began adding new optionality flags to better align with Swift clients.

# v 0.3.[1|2]

* Added the ability to override any NSEntity.managedClassName while merging the models

# v 0.3.3

* Updated away from iOS 9 deprecated APIs..  Yet to do: NSURLConnection->NSURLSession 

# v 0.3.5

* Replaced NSURLConnection with NSURLSession

# v 0.4.0

* Added an associated property cache to FOSCachedManagedObject

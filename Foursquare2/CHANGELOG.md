# Foursquare2 Changelog

__v1.4.6__

* Add endpoint for adding venue to a list (listAddVenueWithId:)
* Add new method to create a list (listAddWithName:)
* Add ability to delete venue from list (listDeleteItemWithId:)
* Add ability to update a list's properties (listUpdateWithId:)
* Clean keychain in case of error 401
* Use NSData instead of UIUmage for photo uploadingq

__v1.4.5__

* Add possibility to specify queue for callbacks.
* Add method to get list detail (listGetDetail:callback:)
* Add method to get menu for a venue (venueGetMenu:callback:)
* Fix authorizeWithCallback: method to call back when user cancels web view authorization.
* Fix crash in case of nil authorization callback
* Remove depricated methods

Thanks to @matehat @imownbey @mzsanford @rodericj @lschwe @ciryx

__v1.4.4__

* Storing access token into keychain.
* Add +accessToken method in Foursquare2 class.

__v1.4.3__

* Open web view if there is no foursquare app installed (it used to open appstore)
* Fix problem with web login. Library didn't clean cookies correctly previouls for non us locals.

__v1.4.2__

* Added FSOperation (subclass of NSOperation) for making network request. Move json serialization into backround thread.
* All API related methods return NSOperation. This operation already enqueued in internal queue. You can use this operation to cancel request. If operation has been canceled callback method is not called. This cancelation is very usefull for searching venues while user typing query string in search field. (see SearchViewController.m in example application.)
* Added venuePhotos parameter to the venueExploreRecommendedNearByLatitude:... method.

__v1.4.1__

*  Fixed possible crash in connectionDidFinishLoading: method.
*  Fixed crash in venueExploreRecommendedNearByLatitude: method.
*  Added venueSearchNearLocation: method
*  Added venueSuggestCompletionByLatitude: method
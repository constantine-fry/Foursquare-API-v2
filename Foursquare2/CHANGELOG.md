# Foursquare2 Changelog

__v1.4.2__
* Added FSOperation (subclass of NSOperation) for making network request. Move json serialization into backround thread.
* All API related methods return NSOperation. This operation already enqueued in internal queue. You can use this operation to cancel request. If operation has been canceled callback method is not called. This cancelation is very usefull for searching venues while user typing query string in search field. (see SearchViewController.m in example application.)
* Added venuePhotos parameter to the venueExploreRecommendedNearByLatitude:... method.

__v1.4.1__

*  Fixed possible crash in connectionDidFinishLoading: method.
*  Fixed crash in venueExploreRecommendedNearByLatitude: method.
*  Added venueSearchNearLocation: method
*  Added venueSuggestCompletionByLatitude: method
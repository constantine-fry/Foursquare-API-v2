#Foursquare Objective-C API 2.0

###Motivation
The main idea behind this library is to provide not abstract library with concrete methods to use.
What do I mean by abstract library? Abstract library for me is API that provide for developers only several
methods to construct request with path and parameters, but you need to read online documentation and
constract NSDictionary with parameters on your own. This library provide concrete, ready-to-use method like this:


    + (NSOperation *)createCheckinAtVenue:(NSString *)venueID
                                    venue:(NSString *)venue
                                    shout:(NSString *)shout
                                 callback:(Foursquare2Callback)callback;
                        
    + (NSOperation *)userGetDetail:(NSString *)userID
                          callback:(Foursquare2Callback)callback;

Don't be scary of NSOperation:). Almost all the time you don't need to use them. But it could be very helpfull
if you want to have more control and cancel operations. Checkout SearchViewController.m as example.

###Features
* Native authentication with Foursquare app and in-app web view authentication.
* Storing access token into keychain.
* Asynchronous requests with blocks.
* Build-in image uploader for adding photos for checkin.


###How To

IMPRORTANT: In case you already use this library and you want to switch on native login: you need to add new redirect URL in app settings on https://developer.foursquare.com and make sure you keep old redirect URL, otherwise current application on AppStore will not be able to open login page. For native login you must have redirect URL like this testapp123://foursquare. testapp123 is URL scheme of your application. It must be in plist(see steps below) and must be unique.


1. Create Your application here https://foursquare.com/developers/register
![](https://raw.github.com/Constantine-Fry/Foursquare-API-v2/master/img/site1.png)
2. You need to make sure you set up the URL scheme in your info.plist properly
CFBundleURLTypes -> CFBundleURLName -> CFBundleURLSchemes -> {app_id}
![](https://github.com/Constantine-Fry/Foursquare-API-v2/blob/master/img/plist.png?raw=true)
3. Add handleURL: method in application:openURL:sourceApplication:annotation: method.


        - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
            return [Foursquare2 handleURL:url];
        }

4. Setup Foursquare to use your credentials


        - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
            [Foursquare2 setupFoursquareWithClientId:YOUR_KEY
                              secret:YOUR_SECRET
                         callbackURL:YOUR_CALLBACK_URL];
        }
 

    



###Useful tips
1. How to get sw and ne from MKMapView?

        CGPoint swPoint = CGPointMake(mapView.bounds.origin.x, mapView.bounds.origin.y+ mapView.bounds.size.height);
        CGPoint nePoint = CGPointMake((mapView.bounds.origin.x + mapView.bounds.size.width), (mapView.bounds.origin.y));
    
        //Then transform those point into lat,lng values
        CLLocationCoordinate2D swCoord;
        swCoord = [mapView convertPoint:swPoint toCoordinateFromView:mapView];
    
        CLLocationCoordinate2D neCoord;
        neCoord = [mapView convertPoint:nePoint toCoordinateFromView:mapView];

2. Rate limits.
    Some Foursquare API methods don't require authentication (such as venueSearch methods). 
    But they have some limitations: https://developer.foursquare.com/overview/ratelimits






###Screnshots
![](https://raw.github.com/Constantine-Fry/Foursquare-API-v2/master/img/photo1.PNG)


![](https://raw.github.com/Constantine-Fry/Foursquare-API-v2/master/img/photo2.PNG)


I got blue pin [here](http://graphicclouds.com/map-pin-icons/).


###Cocoapod

pod 'Foursquare-API-v2'

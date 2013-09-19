#Objective-C Foursquare API 2.0

###Features
* Native and in-app authentication 
* Asynchronous requests with blocks
* Build-in image uploader for photos.
* Made with native frameworks.


###How To

1. Create Your application here https://foursquare.com/developers/register
![](https://github.com/Constantine-Fry/Foursquare-API-v2/blob/master/img/site.png?raw=true)

2. Setup Foursquare to use your credentials


        - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
            [Foursquare2 setupFoursquareWithClientId:YOUR_KEY
                                     		 secret:YOUR_SECRET
	                                 callbackURL:YOUR_CALLBACK_URL];
        }
    
    
3. You need to make sure you set up the URL scheme in your info.plist properly

CFBundleURLTypes -> CFBundleURLName -> CFBundleURLSchemes -> {app_id}

![](https://github.com/Constantine-Fry/Foursquare-API-v2/blob/master/img/plist.png?raw=true)


###Useful tips
1. How to get sw and ne from MKMapView?

        CGPoint swPoint = CGPointMake(mapView.bounds.origin.x, mapView.bounds.origin.y+ mapView.bounds.size.height);
        CGPoint nePoint = CGPointMake((mapView.bounds.origin.x + mapView.bounds.size.width), (mapView.bounds.origin.y));
    
        //Then transform those point into lat,lng values
        CLLocationCoordinate2D swCoord;
        swCoord = [mapView convertPoint:swPoint toCoordinateFromView:mapView];
    
        CLLocationCoordinate2D neCoord;
        neCoord = [mapView convertPoint:nePoint toCoordinateFromView:mapView];









###Screnshots
![](https://github.com/Constantine-Fry/Foursquare-API-v2/blob/master/img/photo%201.PNG?raw=true)


![](https://github.com/Constantine-Fry/Foursquare-API-v2/blob/master/img/photo%202.PNG?raw=true


I got blue pin [here](http://graphicclouds.com/map-pin-icons/).


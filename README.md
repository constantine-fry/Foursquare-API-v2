#Foursquare API 2.0 For iOS and MacOS

###Features
* In-App Authentication
* Asynchronous requests with blocks
* Build-in image uploader for photos.
    * You can use [CFAsyncImageView](https://github.com/Constantine-Fry/CFAsyncImageView) for downloading images.
* Made with native framworks:
    * NSJSONSerialization for JSON parsing
    * NSURLConnection for requests


###How To

1. Create Your application here https://foursquare.com/developers/register
![](https://github.com/Constantine-Fry/Foursquare-API-v2/blob/master/img/site.png?raw=true)

2. You should modify Foursquare2.h

    1. Change OAUTH_KEY and OAUTH_SECRET
    2. Change REDIRECT_URL. It should start with app://
    3. Change VERSION to your current date, so you will use latest API/

3. You need to make sure you set up the URL scheme in your info.plist properly

CFBundleURLTypes -> CFBundleURLName -> CFBundleURLSchemes -> {app_id}

![](https://github.com/Constantine-Fry/Foursquare-API-v2/blob/master/img/plist.png?raw=true)


###Usefull tips
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


![](https://github.com/Constantine-Fry/Foursquare-API-v2/blob/master/img/photo%202.PNG?raw=true)

##My other usefull libs
[CFAsyncImageView](https://github.com/Constantine-Fry/CFAsyncImageView) - is simple subclass of UIImageView for async downloading image. Very simple and powerfull. No extra code. I use native NSCache class for in-memory image caching.



I got blue pin [here](http://graphicclouds.com/map-pin-icons/).


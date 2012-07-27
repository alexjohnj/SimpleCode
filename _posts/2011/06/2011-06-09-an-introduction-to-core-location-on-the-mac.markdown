---
layout: post
title: "An Introduction to Core Location on The Mac"
description: "Outlines how to use Core Location on Mac OS X to find the location of your users' macs." 
keywords: "cocoa, core location, locate, geolocation, mac os x, wifi triangulation" 
excerpt: "Since iOS 2.0, Apple has included an excellent framework with the iOS devices for finding the location of users easily and quickly, Core Location. The framework is very simple to use and it is frequently used by developers thanks to its reliability and integration with the system and Map Kit. Occasionally, developers for the Mac will also want to access the location of the users computer but in the past, there have been no frameworks that have allowed developers to easily do this. In Mac OS 10.6 however, Apple introduced the Core Location framework to OS X Snow Leopard and made it much easier to find the location of users computer. Since no Macs that Apple have shipped actually come with a GPS chip in them (unlike the 3g iPad and iPhone) the location services work using wi-fi triangulation. Whilst this is slightly less accurate than using a GPS signal, it’s still accurate enough for you to be able to get some details about your users location, such as their street or country. Implementing Core Location into a Cocoa application is nearly identical to to doing so in a iOS application, very easy."
---

Since iOS 2.0, Apple has included an excellent framework with the iOS devices for finding the location of users easily and quickly, Core Location. The framework is very simple to use and it is frequently used by developers thanks to its reliability and integration with the system and Map Kit. Occasionally, developers for the Mac will also want to access the location of the users computer but in the past, there have been no frameworks that have allowed developers to easily do this. In Mac OS 10.6 however, Apple introduced the Core Location framework to OS X Snow Leopard and made it much easier to find the location of users computer. Since no Macs that Apple have shipped actually come with a GPS chip in them (unlike the 3g iPad and iPhone) the location services work using wi-fi triangulation. Whilst this is slightly less accurate than using a GPS signal, it’s still accurate enough for you to be able to get some details about your users location, such as their street or country. Implementing Core Location into a Cocoa application is nearly identical to to doing so in a iOS application, very easy.

<!--more-->

The Example
-----------

The example we’re going to make is a typical example, completely useless but perfect for showing you how to use the framework. It’s a really simple Cocoa application which is going to show you some geographical information like your location and heading. It won’t display anything on a map (since Cocoa doesn’t have Map Kit unlike iOS) but if you take the co-ordinates and put them into Google Maps, it will produce a reasonably accurate location of you. This sort of application would be more useful as a widget, but I’m not showing you how to make a widget, I’m showing you how to use Core Location.

Creation
--------

Create a new Cocoa application (non document based and sans core data) and give it a name. The first thing we need to do is add the Core Location framework. If you’ve never added a framework before it’s relatively simple. In the project navigator, select your project (right at the top of the list) and then choose the application target. You’ll get some information on your application target and you can set the icon etc here. Choose the summary tab and under “Linked Frameworks and Libraries” click the plus button. In the sheet that appears, search for Location and add the CoreLocation.framework. Make sure it is set to required. Below is a diagram outlining the steps to add a framework:

![Adding a framework in Xcode.](/images/posts/2011/06/anIntroductionToCoreLocationOnTheMac/adding_core_location_framework.png?w=600&h=375)

Once we’ve added the framework, we can create the UI. Add a single multi-line label to the main window and resize it to fit the window (or the window to fit it). That’s it.

Adding The Code
---------------

For the purpose of this application, we’re going to keep all of our code in the AppDelegate file (since it’s so simple) but in a normal application, you’ll put your code in a variety of class files. Open up the AppDelegate.h file and edit it to look like this:

{% highlight objc %}
#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>

@interface YourAppsNameAppDelegate : NSObject <NSApplicationDelegate, CLLocationManagerDelegate> {
	@private
	NSWindow *window;
	CLLocationManager *manager;
	IBOutlet NSTextField *textField;
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *textField;
@property (retain) CLLocationManager *manager;

@end
{% endhighlight %}

Don't forget to `@synthesize` your properties. Note the #import line. This is important as whilst we’ve included the Core Location framework with our project we haven’t told the class file to use it. CLLocationManager is short for Core Location Manager and is an object that has some useful methods for starting and stopping the core location services as well as some properties for configuring the core location services. It doesn’t have anywhere near as many methods as its iOS counterpart (of the same name) does but on a computer, it’s unlikely you’d need all of those methods. Inside AppDelegate.m, edit the applicationDidFinishLaunching method to look like this:

{% highlight objc %}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.manager = [[CLLocationManager alloc] init];
	[self.manager setDelegate:self];
	[self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
	[self.manager setDistanceFilter:kCLDistanceFilterNone];
	[self.manager startUpdatingLocation];
}
{% endhighlight %}

Breaking this down line-by-line, you initialise the CLLocationManager object first. Then you set the delegate of the manager to self (the AppDelegate class). Then we have the first method, `setDesiredAccuracy:(CLLocationAccuracy *)desiredAccuracy`. On iOS, you’d choose an accuracy based on a trade off between accuracy (duh) and battery life. The higher the accuracy the higher the drain on the battery. This is less of an issue on a computer, since batteries are better but if you are accessing the location of the computer a lot, you may want to use a different parameter. The next method, `setDistanceFilter:(CLLocationAccuracy *)desiredAccuracy` states how far a device must move (laterally) before a new location reading is made. The value is in metres. `kCLDistanceFilterNone` means that the device doesn’t have to be moved at all to update the location, using more battery power but improving the frequency of readings. The final method would be `startUpdatingLocation`, this starts the location services and, obviously, locating the device. Whilst I haven’t included it in this sample, you can use the method `stopUpdatingLocation` to stop updating the location of the device. Just a small side point. `desiredAccuracy`, `distanceFilter` and `delegate` are actually properties and so the following code would be ok too:

{% highlight objc %}
self.manager.delegate = self;
self.manager.desiredAccuracy = kCLLocationAccuracyBest;
self.manager.distanceFilter = kCLDistanceFilterNone;
{% endhighlight %}

Now that we’ve actually started location services, we need to tell the application what to do when we are given a new location. By making our location manager a delegate, we get access to some nice methods, one of which allows us to do stuff when the location is updated. Add the following method to AppDelegate.m (it doesn’t need declaring in AppDelegate.h since it’s a delegate method):

{% highlight objc %}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	[textField setStringValue:[NSString stringWithFormat:@"%@", newLocation]];
}
{% endhighlight %}

I’d advise you copy and paste the method as if you get the title of the method wrong, you won’t get any build warnings but nothing will happen when you run the application. The method should be fairly self explanatory, all we’re doing is setting the string of the multi-line label to a load of information about our location, wrapped up in a single CLLocation object. You also need to add the following method to AppDelegate.m, in order to disable location services when the application quits and to release the CLLocationManager:

{% highlight objc %}
-(void)applicationWillTerminate:(NSNotification *)notification{
	[self.manager stopUpdatingLocation];
	[self.manager release];
}
{% endhighlight %}

The final step is to link up the textField outlet to the multi-line label in Interface Builder. Now build and run the application and click OK when it prompts you to use location services. Give the application a few seconds and the label will update with a load of information on your location like the time zone, heading, co-ordinates , etc. It will continue to update as long as your application is open.

What If It Doesn’t Work?
------------------------

If you find that you don’t get a location and are confident that every line of code is correct (check for errors in the console), add the following method to AppDelegate.m. It’s a delegate method of CLLocationManager, so doesn’t need declaring in your interface file:

{% highlight objc %}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	[textField setStringValue:[NSString stringWithFormat:@"Error: %@", error]];
}
{% endhighlight %}

This will display an error in the label if Core Location fails. Depending on the error, you may be able to work out why it isn’t working (it’s most likely something to do with where you live than the actual code of your application, if it displays and error).

Extracting Data From Your Location
----------------------------------

When we display the location data we get from location services, we’re displaying lots of different pieces of data. Having them all clumped together like that isn’t particularly handy as sometimes, all you need is one specific piece of data, such as the time, or co-ordinates. Extracting this data is relatively simple though as there are several methods that will do this for you. Edit - (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation to look like this:

{% highlight objc %}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	[textField setStringValue:[NSString stringWithFormat:@"%@", [newLocation timestamp]]];
}
{% endhighlight %}

As `newLocation` is nothing more than a CLLocation object, we can pass a variety of methods to it. One of those methods is `timestamp` and, as you will find if you re-build the application, it displays just the timestamp of the location. Again, this variable is simply a property and `newLocation.timestamp` would have been valid too instead of `[newLocation timestamp]`. There are a variety of these properties that allow you to access different aspects of the location data. A description of each one can be found in the CLLocation class reference [here](http://developer.apple.com/library/mac/#documentation/CoreLocation/Reference/CLLocation_Class/CLLocation/CLLocation.html).

Wrap-Up
-------

So, as you can hopefully see, accessing information about your Mac’s location is relatively simple thanks to the Core Location framework. Remember though, this framework is only available in OS 10.6 onwards, so if you need to maintain compatibility with earlier versions of OS X, you’ll need to look for a different method of obtaining location data. In this post I didn’t cover how to actually display this data on a map (in your application at least). Doing so isn’t difficult but since there is no map kit in Mac OS like there is in iOS, it is slightly more challenging than in iOS.

Follow the author of this post, [@alexjohnj](http://twitter.com/alexjohnj).
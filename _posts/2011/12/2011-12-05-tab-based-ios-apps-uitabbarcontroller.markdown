---
layout: post
title: "Tab Based iOS Apps - UITabBarController"
description: "Outlines how to set up UITabBarController to manage a set of views using a tab based application."
keywords: "cocoa, objective-c, cocoa touch, iOS, tab, tab based app, UITabBar, UITabItem, UITabBarController, UINavigationController"
excerpt: "Several weeks ago, I showed you how to use UINavigationController to create an iOS application that manages multiple screens of hierarchical data. UINavigationController was very easy to use and intuitive when it came to managing multiple screens of data that branched off of each other like a tree. Sometimes however, you may need to display screens of data which don't actually link together in a metaphorical tree. To do this, you can use the UITabBarController class a, again, very simple and intuitive class for managing multiple views using a tab bar."
---

Several weeks ago, I showed you how to use UINavigationController to create an iOS application that manages multiple screens of hierarchical data. UINavigationController was very easy to use and intuitive when it came to managing multiple screens of data that branched off of each other like a tree. Sometimes however, you may need to display screens of data which don't actually link together in a metaphorical tree. To do this, you can use the UITabBarController class a, again, very simple and intuitive class for managing multiple views using a tab bar. 

<!-- more -->

## What is UITabBarController?

At its simplest level, UITabBarController is a specialised view controller that displays a series of radio buttons along the bottom of the screen. Tapping the different radio buttons will present a different screen of data, a new root view. Looking at the UITabBarController in slightly more detail reveals that the radio buttons along the bottom of the screen is, in fact, a UITabBar object. The UITabBarController manages an array of UIViewControllers and tapping one of the UITabBarItems in the UITabBar loads the root view for the corresponding UIViewController. From this root view, we can break out a UINavigationController and start navigating through a hierarchy of views. Let's look at an Apple example. 

Consider the YouTube app included on all iOS devices:

<img src="{{ site.baseurl }}/images/posts/2011/12/introductionToUITabBarController/youtubeappdemoscreen.png" width="50%" alt="The YouTube App on iOS showing a tab bar.">

As you can see along the bottom of the screen there's a tab bar with different "modes" which the user can select. Placing these modes in a navigation controller wouldn't make sense since they don't link together in any way (except that they all carry out YouTube related actions). Selecting different tabs loads a new root view and from there new views are pushed onto the navigation stack _for that view controller_. It's fairly logical. _Each tab corresponds to a specific view controller. When the users taps a tab, the root view for the corresponding view controller replaces the previously visible view._ 

## The Rules Of UITabBarController

Before we begin making an example application, I need to run over a few of the rules when using UITabBarController (I'll recap the most important ones at the end of the post). UITabBarController is a subclass of UIViewController however unlike normal UIViewControllers which can be child views of another view controller, UITabBarController must be the root view of your window. If it isn't, your app will crash. In addition, while this sounds counter intuitive, you should **never** directly access the tab bar property of a UITabBarController. How do you handle modifications to the tab bar then? Do it in your view controller's methods. This will make more sense later on but essentially, if you take a look at the tab bar property of the UITabBarController class, you'll see it's declared as readonly (`@property(nonatomic,readonly) UITabBar *tabBar`) and so you can't modify it (doing so will make your application throw an exception). They're the two most important rules for now and the most common mistakes people make when playing around with UITabBarController for the first time but there are some more rules which you may run into. 

## Using UITabBarController

We're going to create a very simple application that has no real world use, it's just a demo application. I'm going to show you how to set up a UITabBarController which manages a couple of UIViewControllers (obviously), how to badge a UITabBarItem in the tab bar and what to do if you need to add more tabs than can fit in a UITabBar. To avoid confusion and countless comments telling me I forgot to release something, this tutorial is written assuming you are using automatic reference counting & Xcode 4.2. If you're not, you should be able to fill in the gaps but I'd strongly urge you to start using automatic reference counting, it's awesome!

### The Example

To begin, open up Xcode and create a new empty iOS application. Name the product whatever you want, make sure that the device family is “iPhone” and check that “Use Automatic Reference Counting” is checked and ”Use Core Data” & “Include Unit Tests” is unchecked. Once the project has been created, make 6 new UIViewController subclasses with XIBs. For simplicities sake, name the view controllers FirstViewController, SecondViewController e.t.c. The reason we're using six view controllers will become apparent later. You may want to open up each view controller's corresponding XIB file and add a label to the view so that you can easily distinguish each view. Once the UIViewControllers have been created, open up the *AppDelegate.h* file and import **all** the UIViewControllers so that the first few lines of the *AppDelegate.h* file look like this:

{% highlight objc %}
#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"
#import "FifthViewController.h"
#import "SixthViewController.h"

//@interface section
{% endhighlight %}

We don't actually need all of these view controllers yet, for the first part of this tutorial, we're going to focus on only the first three view controllers. Still in the *AppDelegate.h* file, we need to declare an instance variable for a UITabBarController. Add one property to your AppDelegate.h file that looks like this:

{% highlight objc %}
@property (nonatomic, strong) UITabBarController *tabController;
{% endhighlight %}

Remember to `@synthesize` the property in the AppDelegate's implementation file. Open up the implementation file (*AppDelegate.m*) and take a look at the `applicationDidFinishLaunching:` method. We need to override this method so that we initialise our UITabBarController with an array of UIViewControllers and then set the UITabBarController as the root view for our application's window. To do this, edit the method to look like this:
	
{% highlight objc %}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	// Custom code
	
	FirstViewController *fistView = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
	SecondViewController *secondView = [[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil];
	ThirdViewController *thirdView = [[ThirdViewController alloc] initWithNibName:@"ThirdViewController" bundle:nil];
	
	NSArray *viewControllersArray = [[NSArray alloc] initWithObjects:fistView, secondView, thirdView, nil];
	
	self.tabController = [[UITabBarController alloc] init];
	[self.tabController setViewControllers:viewControllersArray animated:YES];
	
	self.window.rootViewController = self.tabController;
	
	//end custom code
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	return YES;
}
{% endhighlight %}

The code between the two comments is the code that you need to add to the method's body. Here, we've initialised the first three UIViewControllers and thrown them into an array. We've then initialised the UITabBarController and used the method `setViewControllers: animated:` to set the array of UIViewControllers as the view controllers that our UITabBarController needs to manage. Each tab represents a view controller and the first tab (going from the left of the screen) represents the view controller at index 0 in your array and the last tab represents the last view controller in your array. Finally, we've set our UITabBarController as the root view of our application's window (remember, a UITabBarController can only be the root view and can't be a child view). If you build and run your application now, you'll find that everything works. Your application launches and presents you with a tab bar. Tapping on the individual tabs will load the UIViewController for that tab. There's just one small problem. There's no way to distinguish individual tabs since the tabs don't have a title or an icon. It's relatively easy to fix this however and requires just a small snippet of code in each of your view controllers. 

![The Application So Far]({{ site.baseurl }}/images/posts/2011/12/introductionToUITabBarController/tabbarapps1.png) Our application so far. 

## Customising Tabs

In order to improve the usability of our application, we need to include a small snippet of code in each of our view controller's `init:` method. In the *FirstViewController.m* file add the following piece of code to the `init:` method:

{% highlight objc %}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		//edit
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
		//end edit
    }
    return self;
}

{% endhighlight %}
	
Again, the edit is between the two comments. View controllers which are a part of a UITabBarController automatically have a property called `tabBarItem`. This is a UITabBarItem and there are a variety of methods which can be called on it to change its appearance and functionality. We've manually initialised the tab bar item (normally done automatically) and we've initialised it with one of the default system styles (The “Featured” style). Instead of using one of the default styles we could have used a custom image and title by calling: 

{% highlight objc %}
self.tabBarItem.image = myImage;
self.tabBarItem.title = @"FooBar";
{% endhighlight %}

However the system default styles take care of this for us. There are a [variety of different system styles](http://developer.apple.com/library/IOs/documentation/UIKit/Reference/UITabBarItem_Class/Reference/Reference.html#//apple_ref/c/tdef/UITabBarSystemItem) for UITabBarItems. Play around with them by giving the other two view controller's tabs icons and titles. The `tag:` section of this initialisation method is a way of providing your UITabBarItem with an identifier for referencing it. It's generally best to set the tag to the index of the view controller in the array of view controllers you gave the UITabBarController earlier. 

## Badging a Tab

At some point you may need to carry out an action in the background but keep the user informed on the state of the process. An easy way to do this is by badging the UITabBarItem for the respective action. Apple makes extensive use of this throughout its applications. In the App Store, the updates tab is badged with the number of available updates. The small red oval provides information to the user without being intrusive. In the iTunes store app, the downloads tab is badged with the number of active downloads. This informs the user that there are downloads taking place *and* also informs the user when a download has finished, since the badge disappears. You'll commonly see badges used to convey numbers to users but it's possible to badge an icon with text (although it looks somewhat out of place). It's very easy to badge tab icons and involves editing the instance variable of a UITabBarItem. All UITabBarItems have the property `@property(nonatomic, copy) NSString *badgeValue`. Setting this to any string other than nil will badge the tab with an oval containing the string. 

In our sample application, open up the *ThirdViewController.xib* file and add two buttons to the view. Label one as “Badge Tab” and the other as “Clear Badge”. Now, open *ThirdViewController.h* and declare two methods:

{% highlight objc %}
#import <UIKit/UIKit.h>

@interface ThirdViewController : UIViewController
//methods
-(IBAction)badgeTabIcon:(id)sender;
-(IBAction)clearTabBadge:(id)sender;
@end
{% endhighlight %}

In the implementation file, edit the body of the methods to look like this:

{% highlight objc %}
-(IBAction)badgeTabIcon:(id)sender{
   self.tabBarItem.badgeValue = @"Hi!";
}

-(IBAction)clearTabBadge:(id)sender{
   self.tabBarItem.badgeValue = nil;
}
{% endhighlight %}

In the 	first method, we set the badge's string to “Hi!” and in the second method we set the badge's string to `nil`, thus getting rid of the badge. Pretty simple? In Interface Builder, connect the methods to the two buttons (ctrl+drag from Files Owner to the first button and choose `badgeTabIcon:`. Do the same for the second button but this time choose `clearTabBadge:`) and then build and run the application. Open the third tab, and tap the “Badge Tab” button and the third tab should have “Hi” above it. Tap “Clear Badge” and the badge will disappear. This is pretty handy but what if you need to badge a tab which the currently active view controller doesn't manage? Easy. Edit the `badgeTabIcon:` method to look like this:

{% highlight objc %}
-(IBAction)badgeTabIcon:(id)sender{
    [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:@"Hi!"];
}
{% endhighlight %}

That's a lot of brackets but don't be intimidated by them. All we're doing is obtaining a copy of the original array of view controllers that we gave the UITabBarController and setting the badge value of the view controller we want. In this case, we're badging the first tab (since it's at index 0 in the array). We can use exactly the same snippet of code to clear the badge too, just call `setBadgeValue:nil`. 

## An Expanding Tab Bar

UITabBar is really awesome at managing a lot of views but that tab bar can only squeeze so many icons onto it before they'd be too small to tap. The UITabBarController class includes a nifty work around to fit more tabs than it can hold. It adds a more button and then displays a list of the remaining tabs. So how many tabs can a UITabBar hold? Five. Go back to the *AppDelegate.m* file and edit the `applicationDidFinishLaunching` method to look like this (changes are between the comments): 
	
{% highlight objc %}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   
   FirstViewController *fistView = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
   SecondViewController *secondView = [[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil];
   ThirdViewController *thirdView = [[ThirdViewController alloc] initWithNibName:@"ThirdViewController" bundle:nil];
   // Changes!!!
   FourthViewController *fourthView = [[FourthViewController alloc] initWithNibName:@"FourthViewController" bundle:nil];
   FifthViewController *fifthView = [[FifthViewController alloc] initWithNibName:@"FifthViewController" bundle:nil];
   SixthViewController *sixthView = [[SixthViewController alloc] initWithNibName:@"SixthViewController" bundle:nil];
   
   NSArray *viewControllersArray = [[NSArray alloc] initWithObjects:fistView, secondView, thirdView, fourthView, fifthView, sixthView, nil];
   //!! End Changes
   self.tabController = [[UITabBarController alloc] init];
   [self.tabController setViewControllers:viewControllersArray animated:YES];
   
   self.window.rootViewController = self.tabController;
   
   self.window.backgroundColor = [UIColor whiteColor];
   [self.window makeKeyAndVisible];
   return YES;
}
{% endhighlight %}

This code should seem fairly familiar. We've initialised the remaining three UIViewControllers and then thrown them into the array that we're giving to the UITabBarController. Now the UITabBarController is managing six views. That's one more than you can fit in a UITabBar! Before building the changes, go into the `init` method of the last three view controllers and give each of the tabs an icon and title (scroll up if you can't remember how to do it). Now build and run the application. 

You should end up with an application that looks like this:

![The Application with a more button]({{ site.baseurl }}/images/posts/2011/12/introductionToUITabBarController/tabbarapps2.png)

Note the more tab. Tapping it presents you with a table (which is actually an embedded [UINavigationController](/2011/09/04/an-introduction-to-uinavigationcontroller/)) with the rest of your tabs available for access (although they are hardly tabs any more). You also get an edit button at the top of the list which allows you to reorganise the UITabBar and move tabs in and out of the more section. Whilst tapping it enables the editing mode, you need to add some more (basic) code to get it to save the position of the icons. Whilst this is really basic stuff using NSUserDefaults, it would make this already lengthy tutorial even longer. 

---

And that's it in a nutshell. You now have a basic application up and running, making use of a UITabBarController to manage an array of views. You've learnt how to set up the UITabBarController, how to badge UITabBarItems and what happens when you need to add more views than can fit in a UITabBar. To wrap this tutorial up here's some tips/rules on using UITabBarController.

## Tips

- Don't subclass UITabBarController. 
- Don't directly access the `tabBar` property of a UITabBar. Access it in your view controllers, as we did in the sample application when badging other tabs. 
- Don't include an essay in UITabBarItem badges. Limit the text to a number or 2-3 characters. Anything else looks out of place.  
- Don't use UITabBarController to manage 10+ views. It gets *really* annoying scrolling through a list of sections under the more tab. Try alternative user interfaces if you need that many views.

Follow the author of this post, [@alexjohnj](http://twitter.com/alexjohnj).
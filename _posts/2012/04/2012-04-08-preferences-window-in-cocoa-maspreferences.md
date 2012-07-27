---
title: "Building a Preferences Window in Cocoa - MASPreferences"
layout: post
excerpt: "A common question that beginner Cocoa developers ask is how to build a preferences window for their application like the ones Apple uses (and seemingly every other Mac application). Given the number of ready built classes that Apple provides and the abundance of one style of preference window, one would assume that Apple provides a class for building preferences windows but, amazingly, they don't. There's no pre-built preferences window class for building automatically resizing, tab based preference windows. Instead, it's down to you to build your own, sort of. A bit of Googling around reveals several third party classes that handle these automatically resizing preferences windows perfectly. It's a reasonable bet that the majority of preferences windows in the 3<sup>rd</sup> party application you have on your Mac use one of these frameworks in fact."
---

A common question that beginner Cocoa developers ask is how to build a preferences window for their application like the ones Apple uses (and seemingly every other Mac application). Given the number of ready built classes that Apple provides and the abundance of one style of preference window, one would assume that Apple provides a class for building preferences windows but, amazingly, they don't. There's no pre-built preferences window class for building automatically resizing, tab based preference windows. Instead, it's down to you to build your own, sort of. A bit of Googling around reveals several third party classes that handle these automatically resizing preferences windows perfectly. It's a reasonable bet that the majority of preferences windows in the 3<sup>rd</sup> party application you have on your Mac use one of these frameworks in fact. 

<!-- more -->

## The Options

There's three main frameworks when it comes to making preferences windows; Selectable Toolbar (part of the [BWToolkit](http://brandonwalkin.com/bwtoolkit/) by Brandon Walkin), [SS_PrefsController](http://mattgemmell.com/source/) by Matt Gemmell and [MASPreferences](https://github.com/shpakovski/MASPreferences) by [Vadim Shpakovski](http://www.shpakovski.com/). They all differ in their implementation and difficulty. The selectable toolbar requires relatively little code and is actually an Interface Builder control, however as it is part of an Interface Builder plugin, it won't work in the most recent versions of Xcode, making developing with it a little bit of a pain. SS_PrefsController is very powerful but takes a fair bit of work to get going. MASPreferences is sort of in the middle. It's fairly simple to get up and running but doesn't have the simplicity of visually creating it in Interface Builder, requiring a small bit of code. It is, however, the best choice for 90% of applications that require nothing more than a preferences window. It's only problem is it's lack of documentation which makes an otherwise accessible framework inaccessible to beginners. This post aims to provide a guide on using MASPreferences in an application as simply as possible. It assumes some Cocoa knowledge like knowing how NSWindowController & NSViewController subclasses work and it also assumes you understand Objective-C but it should still be accessible to relatively new Cocoa programmers. 

Before we can begin creating a sample application with MASPreferences, you need to get the classes. These are available from its GitHub repository [here](https://github.com/shpakovski/MASPreferences). When you've got the files have a look at the demo project to see if you can understand it. If so, you probably don't need this guide and can go ahead and start using MASPreferences. If not though, then you'll probably want to follow along with this guide. 

## A Primer: How MASPreferences Works

MASPreferences works in a similar way to iOS' UITabBarController in that you provide an instance of a MASPreferencesWindowController (akin to a UITabBarController instance) with an array of NSViewController subclasses from which it will then create a tab for each subclass with the contents of its view in the tab. The UIViewController subclass must however conform to the MASPreferencesViewController protocol in order to be used which simply requires setting a few properties for each subclass that tells the MASPreferencesWindowController what icon, label and identifier to use for each tab. It's quite simple in implementation really. 

## The Example

For this example we're going to need to create a non-document based, non Core Data Cocoa application. When you've created the project in Xcode, you'll need to add some files to it. Below's a little shopping list:

- Add (at least) two NSViewController subclasses with corresponding XIBs. Ensure that the XIB's File's Owners have been set up correctly. The easiest option is to create a new NSViewController subclass and check the “With XIB” option. You may want to add a label to each of these views to differentiate them. 
- Add the MASPreferences class files to your project. This is a simple case of dragging the *MASPreferencesViewController.h*, *MASPreferencesWindow.xib*, *MASPreferencesWindowController.h* & *MASPreferencesWindowController.m* files into your Xcode project and choosing to copy the files to their needed directories and adding them to the build target. A small side note, if you're using automatic reference counting, you'll either need to convert these files to ARC (they convert without any problems) or disable ARC on the *MASPreferencesWindowController.m* by adding the `-fno-objc-arc` compiler flag to the class. 

Once all of these files have been added, we need to edit our *AppDelegate.h* file and import all of our view controllers and *MASPreferencesWindowController.h*. We also need to create a new instance of MASPreferencesWindow and create a method to load the preferences window. Edit your *AppDelegate.h* to look a bit like this: 

*NB - Normally you wouldn't put this sort of code in your AppDelegate, this is just to cut the length of the tutorial a bit.*

{% highlight objc %}
#import <Cocoa/Cocoa.h>

#import "MASPreferencesWindowController.h"
#import "GeneralPreferencesViewController.h"
#import "OtherPreferencesViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (IBAction)displayPreferences:(id)sender;

@property (strong) NSWindowController *preferencesWindow;
@property (assign) IBOutlet NSWindow *window;

@end
{% endhighlight %}

Remember to `@synthesize` the properties! We now need to edit the implementation of the `displayPreferences:` method. Edit it to look like this:

{% highlight objc %}
- (IBAction)displayPreferences:(id)sender {
    if(_preferencesWindow == nil){
        NSViewController *generalViewController = [[GeneralPreferencesViewController alloc] initWithNibName:@"GeneralViewController" bundle:[NSBundle mainBundle]];
        NSViewController *otherViewController = [[OtherPreferencesViewController alloc] initWithNibName:@"OtherPreferencesViewController" bundle:[NSBundle mainBundle]];
        NSArray *views = [NSArray arrayWithObjects:generalViewController, otherViewController, nil];
        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindow = [[MASPreferencesWindowController alloc] initWithViewControllers:views title:title];
    }
    [self.preferencesWindow showWindow:self];
}
{% endhighlight %}

The code above is quite simple. To begin, we check to see if we need to initialise a new instance of the preferences window. If so, we go ahead and initialise an instance of each view controller we want in our preferences window and then add them to an array. We then call `initWithViewControllers: title:` on our preferences window and pass a title (“Preferences”) and an array of view controllers to the preferences window. The order in which we add the view controllers to the array will dictate the order that they appear in the preferences window with the view controller at index 0 being the furthest left item. 

That's essentially all there is to MASPreferencesWindowController, however we're not quite ready to go yet. We still need to get our view controllers to conform to the MASPreferencesViewController protocol. Open your first view controller's header, in my case *GeneralPreferencesViewController.h* and import the *MASPreferencesViewController.h* class into it. Then, edit the header to declare that this subclass of NSViewController conforms to the MASPreferencesViewController protocol like so:

{% highlight objc %}
@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController>
{% endhighlight %}

With that declared, we now need to actually implement the required protocol methods for MASPreferencesViewController. In your view controller's implementation file, add the following methods:

{% highlight objc %}
 -(NSString *)identifier{
    return @"General";
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

-(NSString *)toolbarItemLabel{
    return @"General";
}
{% endhighlight %}

These are some quite simple methods and they simply define a couple of properties of the view controller for MASPreferencesWindowController. The first method `identifier:` gives your view controller a unique identifier which MASPreferencesWindowController can identify the subclass by. The identifier doesn't have to be the same as the label you want the user to see but it does have to be unique, no other view controller that MASPreferencesWindowController manages can have the same one. The method `toolbarItemImage:` simply provides an icon for your view in the preferences toolbar. When the user clicks on the icon, they'll load that section of the preferences window and your view too. Here I've used one of the system icons but you can use your own icon if you wish. The final method, `toolBarItemLabel:` is the name of your preferences section as it appear to the user in the toolbar. This doesn't have to be unique, but it really should be otherwise things will get confusing. 

You'll need to declare the second view controller in your preferences window (and any others that your preferences window uses) as conforming to the MASPreferencesViewController protocol and you'll need to implement these methods in them too for them to work with MASPreferencesWindowController. Once you've done that though, and connected the `displayPreferences:` action to a button, you're done. If you build and run the application you'll find that the preferences window is fully functioning. It switches between views and resizes according to their size. 

## Conclusion

So, as you should be able to see, MASPreferences is really easy to setup and use. It's a well designed class that works in a way that should be familiar to most Cocoa developers, especially those from iOS and it has a reasonably low learning curve, which is always a good thing. To summarise, here's the steps to set up a MASPreferencesWindowController. 

1. Add the required MASPreferences files to your application. 
2. Create view controllers and views for all the sections of your preferences window. Edit the NSViewController subclasses so that they conform to the MASPreferencesViewController protocol. 
3. When the MASPreferencesWindow needs to be loaded, create an instance of MASPreferencesWindowController and supply it with an array of all the NSViewController subclasses that manage the sections of your preferences window. 
4. Show the MASPreferences window. 

As always, I've added a sample project using MASPreferences to the [SimpleCode GitHub repository](https://github.com/alexjohnj/simplecode-sample-source) even though there's already an example included with MASPreferences' source code. If you're interested in seeing a real world example, I've used MASPreferences in my open source Cocoa application [SymSteam](http://alexjohnj.github.com/symsteam/).

## Observations Using MASPreferences

There's a few things I noticed when playing around with MASPreferences. The MASPreferencesWindowController expects its XIB to be called *MASPreferencesWindow.xib* which could cause problems if you want to rename it. This is easy to fix though. In *MASPreferencesWindowController.m*, add a new parameter to the `initWithViewControllers: title:` method so that it becomes this:

{% highlight objc %}
- (id)initWithViewControllers:(NSArray *)viewControllers title:(NSString *)title windowNibName:(NSString *)nibName{
	// method body
}
{% endhighlight %}

Then just edit the `if(self)` statement so that `[super initWithWindowNibName@"MASPreferencesWindow"]` becomes `[super initWithWindowNibName:nibName]`;

Another thing I noticed is that MASPreferencesWindowController actually stores which section of the preferences window you had open last between launches of your application. I was a bit confused as to why it did this at first until I realised that this is what Apple does but not most 3<sup>rd</sup> party preferences frameworks. Personally I don't think this is how preference windows should work, despite Apple's design choice so, in order to disable this in MASPreferencesWindowController, you need to edit the `windowDidLoad:` method in *MASPreferencesWindow.m* to remove the call to NSUserDefaults so that the `viewControllerForIdentifier:` method is only accessing the view controller at index 0 of the view controllers array. This way MASPreferences wont reload on the last opened preferences section on a fresh launch but will preserve the last section while the application (or at least the instance of MASPreferencesWindowController) is still alive.  

## Links

- [MASPreferences (GitHub)](https://github.com/shpakovski/MASPreferences)
- [Original Announcement](http://blog.shpakovski.com/2011/04/preferences-windows-in-cocoa.html)
- [Vadim Shpakovski's Website](http://www.shpakovski.com/)
- [BWToolkit](http://brandonwalkin.com/bwtoolkit/)
- [SS_PrefsController](http://mattgemmell.com/source/)
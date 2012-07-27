---
layout: post
title: "A Cocoa Bindings Example: Creating A Preferences Window"
description: "Outlining a pratical use of bindings by creating a simple, reusable, preferences window" 
keywords: "cocoa, bindings, KVC, key value coding, preferences, preferences window, mac os x, NSUserDefaults, NSUserDefaultsController"
excerpt: "A few weeks ago, I wrote a post introducing you to the basics of bindings. In it, I was keen to stress how useful bindings are yet the example used was pretty pathetic with little practical use. In this tutorial however, you'll create a useful application which has applications in 90% of cocoa applications. I'm going to show you how to create a preferences window that uses bindings to handle saving the users preferences and altering the UI of the application according to said preferences."
---

A few weeks ago, I wrote a post introducing you to the basics of bindings. In it, I was keen to stress how useful bindings are yet the example used was pretty pathetic with little practical use. In this tutorial however, you'll create a useful application which has applications in 90% of cocoa applications. I'm going to show you how to create a preferences window that uses bindings to handle saving the users preferences and altering the UI of the application according to said preferences. 

<!--more-->

## Prior Reading

If you haven't already, reading my [previous](/2011/04/09/introduction-to-cocoa-bindings/) post on bindings will give you all the background information you need to get started with this tutorial & it will help you understand *how* bindings work.  This tutorial assumes you know your way around Xcode (4) and also assumes you know the basics of Objective-C.

## Creating the Application

Create a new, non-document based Cocoa project, without Core Data and name it whatever you want. Open up the *MainMenu.xib* file and add a multi-line label to the main window. Resize it so it fills the entire window. Next, create a new Objective-C class (that's a subclass of NSObject) and name it AppController. Then create another new Objective-C class, this time making it a subclass of NSWindowController. Name it *PreferencesController*. Finally, create a new window file and name it *Preferences*

<img title="creating_window_xib.png" src="/images/posts/2011/05/aCocoaBindingsExampleCreatingAPreferencesWindow/creating_window_xib.png" alt="Creating window xib"/> Creating a Window file.

## Create The Preferences UI

We now need to create a user interface for our preferences window. Open *Preferences.xib* and drag out two check boxes, a NSLabel and a NSSlider. Resize the window so that it fits the user interface controls. The window should end up looking like this:

<img title="preferences_ui.png" src="/images/posts/2011/05/aCocoaBindingsExampleCreatingAPreferencesWindow/preferences_ui.png" alt="The Preferences Window"  />

Open the attributes inspector for the NSSlider and set the slider to “continuous”. Still in the attributes inspector, set the minimum value of the slider to 1 and the maximum value to 100. We now need to configure *Preferences.xib* so that it recognises the *PreferencesController* class as its owner. Keeping the *Preferences.xib* file open, select the nib's “Files Owner” instance and, under the identity inspector, set the custom class for Files Owner to *PreferencesController*. Now, control drag from the Files Owner instance to the preferences window and choose the window outlet. *Preferences.xib* now knows that *PreferencesController* is its owner and *PreferencesController* now knows what the window it needs to load is. 

## Binding the Preferences Window

Once we've created the user interface and configured *Preferences.xib* to recognise its owner, we need to bind all of the UI controls in the preferences window to NSUserDefaultsController. NSUserDefaultsController is a special class which will take any bound values and write them out to a preferences file (a plist file) so they can be remembered by the application and reloaded when the application launches. Binding the application is relatively easy to do. Open the bindings inspector and bind the Is Bold check box to shared user defaults controller with a model key path of isBold for its value. Do the same for the Is Editable check box but with the modal key path of isEditable instead. Finally, bind the value of the slider to the shared user defaults controller with the model key path of fontSize. 

## Binding the Main Window

Once we've bound the preferences window, we need to set up bindings for the main window so that the preferences actually have an effect. NSUserDefaultsController isn't just for storing preferences, it's also for conveniently accessing user preferences so that you can adjust the application accordingly. If the preference alters the state of the user interface in some way, you can generally let bindings take care of altering the user interface for the preference. In our example, we're going to bind a couple of aspects of the multi-line label so that when the preferences change, the properties of the text in the label change too. Select the label and open up the bindings inspector. First, bind the “Font Bold” property to the shared user defaults controller, with the modal key path of isBold. Do the same for “font size” but this time with the modal key path fontSize. Finally bind the “Editable” property to the shared user defaults controller with the modal key path of isEditable. Our application is now going to alter the size of the text in the label as well as if it's in bold or if it's editable whenever we change our preferences now by using key-value-observing. 

The application is almost complete now. The preferences system is fully set up and working, all we need to do now is configure the *PreferencesController* class so that it will load the preferences window. Before doing that though, I want to show you how to access and alter NSUserDefaults programmatically for those times when bindings won't work in your situation. 

## Programmatically Changing the Value of User Defaults

Open up *AppDelegate.m* and create a new `init:` method. Edit the method to look like this:

{% highlight objc %}
-(id)init{
	self = [super init];
	if (self){
		[[NSUserDefaults standardUserDefaults] setFloat:100 forKey:@"fontSize"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isBold"];
	}	
	return self;
}
{% endhighlight %}

Build & run the application and you'll find that the label is now in bold and the font is much larger. When it's not possible to use bindings and NSUserDefaultsController to set the values of the user defaults, you can use the standard NSUserDefaults class to edit the defaults. Even if the values aren't changed through bindings, any controls which are bound to the default will update, even if NSUserDefaults is used since all that bindings are doing are watching the defaults for any changes to their values and altering the user interface controls accordingly. 

The inverse of this is true for reading defaults. If a default is altered through bindings, but its value is only accessed programatically, then using NSUserDefaults will again be sufficient to read the value of the default.

### Loading the Preferences Window

As the code above demonstrates, our application's preferences system works. Currently though, there's no way to change the preferences (except through code)  since we can't load the preferences window. Before proceeding, you may want to remove the init method from your *AppDelegate.m* file, since it was only for testing.

Now, open *AppController.h* and add two instance variables and one method to the header. You also need to import the *PreferencesController.h* header, like so: 

{% highlight objc %}
#import <Foundation/Foundation.h>
#import "PreferencesController.h"

@interface AppController : NSObject 

@property (assign) IBOutlet NSWindow *mainWindow;
@property (retain) PreferencesController *preferencesController;

-(IBAction)showPreferences:(id)sender; 

@end
{% endhighlight %}

Now, open the implementation file and edit it to look like this:

{% highlight objc %}
#import "AppController.h"

@implementation AppController
@synthesize mainWindow, preferencesController;

-(IBAction)showPreferences:(id)sender{
	if(!self.preferencesController)
		self.preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];

	[self.preferencesController showWindow:self];
}

- (void)dealloc {
	[preferencesController release];
	[super dealloc];
}
@end
{% endhighlight %}

Open the *MainMenu.xib* file and create a new instance of NSObject, setting its class to *AppController*. Control drag from the preferences menu item to the instance of AppController and select the showPreferences: method. Then, control drag from the AppController instance to the main window and choose the mainWindow outlet. Finally, edit the *PreferencesController.m* file to look like this:

{% highlight objc %}
#import "PreferencesController.h"

@implementation PreferencesController

-(id)init{
	if (![super initWithWindowNibName:@"Preferences"])
	    return nil;
	    
	return self;
}

- (void)windowDidLoad {
	[super windowDidLoad];
}

@end
{% endhighlight %}

Build & run the application and open the preferences window. Toggling the check boxes and moving the font slider will update the label accordingly. Furthermore, if you quit and relaunch the application, you'll find that all of the preferences are kept intact, as would be expected. 

## Conclusion

If you've ever tried to create a preferences window without bindings, you'll be able to tell that using bindings is substantially easier, faster and requires far fewer lines of code. The reduction in “glue code” will make your projects much easier to maintain *and* may help to reduce the number of bugs in your application, since there's less opportunity for error. Creating a preferences window is the most common use of bindings but there are various other applications for bindings too, such as [setting up tables](/2011/07/14/nstableviews-nsarraycontrollers-and-more-bindings/) in a relatively short amount of time. Just remember, bindings aren't magical! Take some time to learn how they work, it'll save you a lot of pain later on. 

Follow the author of this post, [@alexjohnj](http://twitter.com/alexjohnj).
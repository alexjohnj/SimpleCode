---
layout: post
title: "Using Growl In Cocoa Applications"
description: "Outlines how to quickly start using Growl in your Cocoa applications to post notifications and receive click backs."
keywords: "cocoa, objective-c, using growl in cocoa, growl notifications, notifications in 10.7 cocoa, easy growl guide, growl quick start guide"
---

Until Mac OS 10.8, Apple has failed to provide a good method for Cocoa applications (and other types of Mac OS X applications) to display notifications. As a solution to this problem, a third party open source project known as Growl exists to provide a notification framework for Mac OS X applications that is easy and convenient to use. The Growl framework is really easy to use and has a great, detailed [documentation set](http://growl.info/documentation/developer/implementing-growl.php) available to developers, however the documentation seems to lack a quick start guide to get people up and running with Growl quickly. The documentation spends a lot of time explaining the ins and outs of Growl so this post aims to be a quick and concise guide to setting up Growl in your Cocoa application, showing you how to post a notification and receive a callback when a notification is clicked, the two most common Growl tasks. 

<!-- more -->

A small side note, unlike my usual tutorials, we won't be building a sample application in this tutorial, I'll assume you already have an application and know where you want to put your Growl notifications. I will, however, leave a sample application in the [SimpleCode GitHub repository](https://github.com/alexjohnj/simplecode-sample-source) to aid you if you get stuck. 

## 1. Adding the Growl Framework

The first step to using Growl in your application is to import the framework into your program. This is quite simple. First, download the Growl SDK from the [Growl website](http://growl.info/downloads). Then, drag the *Growl.framework* folder into your Xcode project via Xcode. In the sheet that appears, ensure that “Copy items into destination group's folder...” is selected. Upon finishing, open up your products build phases and drag the *Growl.framework* item from the Xcode navigator to the copy files section of your build phases. Ensure that the destination is *Frameworks*. Here's a nice diagram to sum that up. 

<img src="/images/posts/2012/04/usingGrowlInCocoa/growlFrameworkImport1.png" width="75%" alt="Step 1 of importing a framework to Xcode"/>

<img src="/images/posts/2012/04/usingGrowlInCocoa/growlFrameworkImport2.png" width="75%" alt="Step 2 of importing a framework to Xcode"/>

<img src="/images/posts/2012/04/usingGrowlInCocoa/growlFrameworkImport3.png" width="75%" alt="Step 3 of importing a framework to Xcode"/>

## 2. Create a Notification Dictionary

When using Growl with your application it's important to remember to create a file called *Growl Registration Ticket.growlRegDict*. This is a simple plist file that contains an array of keys for all the notifications you will be displaying. To create one, simply create a new property list file in Xcode called *Growl Registration Ticket.growlRegDict*. Then, edit it based around this template:

{% highlight lang:xml %}

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Ticket Version</key>
		<integer>1</integer>
		<key>AllNotifications</key>
		<array>
			<string>growlNotificationKey</string>
			<string>anotherGrowlNotificationKey</string>
			<string>andAnother</string>
		</array>
	</dict>
</plist>

{% endhighlight %}


## 3. Posting A Growl Notification

Posting a notification in growl is really easy. It simply requires you to import a framework into the class you want to use Growl in and then calling a simple method on a shared object known as the GrowlApplicationBridge. To begin, add the following to the top of the header file of the class you want to use Growl in. 

{% highlight lang:objc %}
#import <Growl/Growl.h>
{% endhighlight %}

Simple enough. Next, when you want to post a notification, simply call the following method:

{% highlight lang:objc %}
- (void)someMethod{
	    [GrowlApplicationBridge notifyWithTitle:@"A notification"
                                description:@"A short description of the notification"
                           notificationName:@"aNotification"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}
{% endhighlight %}

This will create a notification with the specified details and display it to the user. Most of the method's arguments are self-explanatory but just to make it clear:

- `title:` - The title of the notification displayed to the user.
- `description:` - A **short** description. Long descriptions can be truncated depending on the user's notification style. 
- `notificationName:` - This is the name of the notification as specified in your *Growl Registration Ticket.growlRegDict*. 
- `iconData:` - An icon to be displayed with the notification, of type NSData. Nil will display your application's icon. An empty NSData object will display no icon.
- `priority:` - A number from -2 (low) to +2 (high) indicating the importance of the notification. If the notification style the user uses supports it, a different style notification will be displayed based on priority. 0 is neutral. 
- `isStick:` - Sticky notifications stick around until closed manually by the user, rather than dismissing themselves. 
- `clickContext` - Normally a string indicating what to do when the notification is clicked. More on this below. 

That's all if all you want to do is display a notification. Growl notifications, however, offer the ability to give callbacks when clicked on, opening up some new possibilities. 

##  Bonus - Callbacks

Implementing callbacks into your application requires the use of a delegate to tell inform you when a notification is clicked and what to do. Using it is quite simple. The first thing to do is to register a Growl delegate. In your Growl delegate's class, you need to specify that it conforms to the `GrowlApplicationBridgeDelegate` protocol. Edit the `@interface` section of the class' delegate to look like this:

{% highlight lang:objc %}
@interface GrowlDelegate : NSObject <GrowlApplicationBridgeDelegate>
{% endhighlight %}

Then you need to inform Growl that you'll be using this object as a delegate. You can do so using the following method:

{% highlight lang:objc %}
[GrowlApplicationBridge setGrowlDelegate:myGrowlDelegate];
{% endhighlight %}

You may want to put that method in your AppDelegate's `didFinishLaunching:` method. 

Now, in order to receive callbacks, you need to include the following method in your delegate's implementation file. 

{% highlight lang:objc %}
-(void)growlNotificationWasClicked:(id)clickContext{
	// code to execute when notification clicked
}
{% endhighlight %}

This will get executed when a notification is clicked however we need to provide a contextInfo argument in order to make use of this. When creating a Growl notification, we can now provide an argument to the contextInfo parameter in order to do something with this method. As mentioned above, we normally pass a string as an argument and then identify the argument and execute a method accordingly, like this:

{% highlight lang:objc %}
- (void)someMethod{
	    [GrowlApplicationBridge notifyWithTitle:@"A notification"
                                description:@"A short description of the notification"
                           notificationName:@"aNotification"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@"someNotificationClick"];
}

-(void)growlNotificationWasClicked:(id)clickContext{
	if([clickContext isEqualToString:@"someNotificationClick"]){
		[self doSomething];
	}
}
{% endhighlight %}

Now, when a notification with a clickContext with a value of "someNotificationClick" is clicked, it'll execute the `doSomething:` method. You can repeat this technique of using strings for callbacks for multiple click callbacks. 

## Wrap-up 

That's the basics of using Growl for it's two most common functions, notifying the user and doing something when a notification is clicked. There are numerous other methods at Growl's disposal and instructions on their usage are available in detail on the Growl developer's documentation page [here](http://growl.info/documentation/developer/implementing-growl.php). It's a good, albeit lengthy read but it contains a lot of information on using the Growl delegate, something we only touched upon. 

If you're having problems with using Growl, I've made a small example application demonstrating how to post notifications and receive callbacks on the [SimpleCode GitHub repository](https://github.com/alexjohnj/simplecode-sample-source), if you're interested in seeing it. 

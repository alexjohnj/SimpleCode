---
layout: post
title: "NSTableViews, NSArrayControllers and More Bindings"
description: "Outlines another practical use of bindings and KVC, easily setting up a table using bindings to control the data source and delegate."
keywords: "cocoa, kvc, key value coding, programming, mac os x, NSTableView, NSArrayController, bindings"
---

One of the most frequently used controls in Cocoa applications (next to NSButtons and NSTextFields) are NSTableViews. NSTableViews are fantastically useful controls and they have a wide variety of uses. Presenting a list of data sources, organising data, the list goes on. Table views are also one of the controls that benefits the most from bindings. Typically, tables require a large amount of glue code, they need data source methods, (generally) delegate methods and every time you want to reload the data in a table, you have to call the <code>reloadData:</code> method on the table. It becomes tedious and with so many methods to call, it's easy for silly bugs to be introduced. Using a combination of bindings and a special class called NSArrayController, however, it's easy to set up a table with multiple columns, quickly and without bugs.

<!--more-->

## Background

Contrary to popular belief, bindings is **not** an easy topic for new Cocoa developers. Whilst it greatly simplifies development, it's still critical that you have a decent understanding of many of the fundamentals of Cocoa and Objective C. If you need something of a primer on bindings, check out my previous posts [An Introduction to Bindings & KVC](/2011/04/09/introduction-to-cocoa-bindings/) and [A Cocoa Bindings Example: Creating a Preferences Window](/2011/05/15/creating-a-preferences-window-in-cocoa-using-bindings/). Assuming you have an understanding of the basics of bindings, and also understand a respectable amount of Objective C, let's begin.

## The Example

For this example we're going to build a small task manager. We won't be able to save the tasks (since that would cover a different topic on archiving) but the user will be able to add and remove tasks, as well as set a due date for their tasks. It should end up looking something like this:

<img title="QuickTask_example_screen.png" src="/images/posts/2011/07/NSTableViewsNSArrayControllersandMoreBindings/quicktask_example_screen.png" alt="QuickTask"/>

By using bindings, this application will not take long to make since we won't need to write lots of glue code to set up the table view. In fact, all we really need to write is a model for our data. Mostly, we'll be spending our time in interface builder preparing a NSArrayController.

## Getting Started

Create a new Xcode project (non core data and non document based) and give it a suitable name. Next go ahead and create two classes. One called TaskModel and another called AppController. Make sure they're a subclass of NSObject. As we're dealing with table views here, it really helps to abide to the MVC design pattern, so we're creating a model and a controller for our application. Open up the TaskModel header file and edit the file to resemble this:

{% highlight objc %}
#import <Foundation/Foundation.h>
@interface TaskModel : NSObject {
	NSString *taskName;
	NSDate *taskDueDate;
}
@property (retain) NSDate *taskDueDate;
@property (copy) NSString *taskName;
@end
{% endhighlight %}

We declare two instance variables, a due date and a task name and then add some properties for them. We don't have to add the properties, we could write some setters and getters like this:

{% highlight objc %}
-(void)setTaskName:(NSString *)tName;
-(NSString *)taskName;
-(void)setTaskDueDate:(NSDate *)tDate;
-(NSDate *)taskDueDate;
{% endhighlight %}

But why bother when we can just use properties? Whichever method you choose, you must choose one otherwise bindings will be unable to function (and if you do choose to write the getters &amp; setters, those method names must be exact for bindings to work, so just use properties, OK?). I'm going to assume you where sensible and chose to use properties. Assuming this, open the TaskModel implementation file and edit it to look like this:

{% highlight objc %}
#import "TaskModel.h"
@implementation TaskModel
@synthesize taskName, taskDueDate;
- (id)init {
	self = [super init];
	if (self) {
		taskName = [[NSString alloc] init];
		taskDueDate = [[NSDate alloc] init];
	}
return self;
}
- (void)dealloc {
	[taskName release];
	[taskDueDate release];
	[super dealloc];
}
@end
{% endhighlight %}

All we've done here is synthesise our setters &amp; getters, written an `init:` method to initialise our instance variables and written a `dealloc:` method to clean up after ourselves. All fairly standard stuff. Now we need to move over to our AppController class. Open AppController.h and edit the header file to look like this:

{% highlight objc %}
#import <Foundation/Foundation.h>
@interface AppController : NSObject {
	NSMutableArray *tasksArray;
}
@property (copy) NSMutableArray *tasksArray;
@end
{% endhighlight %}

This array will be the contents array for our ArrayController. This will make more sense in a minute but essentially, we're going to populate the mutable array with a load of TaskModel objects and then use the array controller to access the objects in the array, and update the table view (which we'll make in a minute) with the objects in the array. The array controller will also update the mutable array when the the user chooses to add and remove tasks from the table. When you see it in action, things will make a lot more sense. Open the AppController.m file and edit it to look like this:

{% highlight objc %}
#import "AppController.h"

@implementation AppController
@synthesize tasksArray;

- (id)init {
	self = [super init];
	if (self) {
		tasksArray = [[NSMutableArray alloc] init];
	}
	return self;
}
- (void)dealloc {
	[tasksArray release];
	[super dealloc];
}
@end
{% endhighlight %}

Nothing too crazy right? Again, we're initialising the array in the init method and then cleaning up afterwards. Now, here comes the interesting stuff. Open up MainMenu.xib and drag out a NSTableView and two NSButtons (titled add and remove) onto the main window from the object library. Also drag out a date formatter onto the second column of the table. Set the date style to short style (under the attributes inspector). You may also want to name the columns of the table "Task" &amp; "Due Date Try and arrange the controls to appear similarly to the image at the start of this post. Next, drag out an instance of NSObject from the object library, and set the class (under the identity inspector) to AppController. Then, drag out an NSArrayController from the object library. We're going to use this object to manage the tasksArray and keep it in sync with the UI (and the UI with it). With the array controller selected, under the attributes inspector, change the class name to TaskModel and add two keys: *taskName* and *taskDueDate*. Also make sure that Editable is checked. What we've done here is told the array controller that it will be managing an array of TaskModel objects and that it will be working with two keys, *taskName* and *taskDueDate* which also happen to be the names and keys of the instance variables we added to the TaskModel class (Don't understand? Read up on a topic called Key Value Coding). When you finish editing the attributes inspector, it should end up looking like this:

<img title="Screen shot 2011-07-13 at 19.46.37.png" src="/images/posts/2011/07/NSTableViewsNSArrayControllersandMoreBindings/screen-shot-2011-07-13-at-19-46-37.png" alt="Configuring an NSArrayController to hold instances of a TaskModel class." />

Next, move over to the bindings inspector for the array controller. Expand the content array bindings and choose to bind it to App Controller with the modal key path of tasksArray. What we've done here is bound the tasksArray to the array controller so that, when the application is launched, the array controller will be populated with the contents of the tasksArray, which should be a series of TaskModel objects. The content array binding for your  array controller should look something like this:

<img title="Screen shot 2011-07-13 at 19.49.45.png" src="/images/posts/2011/07/NSTableViewsNSArrayControllersandMoreBindings/screen-shot-2011-07-13-at-19-49-45.png" alt="Binding an array to an NSArrayController." />

We're nearly finished now, all we need to do is tell the columns of the table view what they're going to be populated with. Click on the first column of the table view three times in order to select the first column (alternatively, click on the table view and use the Xcode jump-bar to choose the first column. Under the bindings inspector, expand the value binding and bind it to the array controller, then set the modal key path to taskName. Do the same for the second column however this time set the modal key path to taskDueDate. The value bindings for both of these columns should end up looking like this:

<img title="Screen shot 2011-07-13 at 19.55.33.png" src="/images/posts/2011/07/NSTableViewsNSArrayControllersandMoreBindings/screen-shot-2011-07-13-at-19-55-33.png" alt="Binding the first column of a table to an NSArrayController."/>

<img title="Screen shot 2011-07-13 at 19.56.30.png" src="/images/posts/2011/07/NSTableViewsNSArrayControllersandMoreBindings/screen-shot-2011-07-13-at-19-56-30.png" alt="Binding the second column of a table to an NSArrayController." />

Note that for the first column, under the value binding you may want to set the null placeholder to something like “Walk the dog” so when the user creates a new task, they aren't presented with a blank row in the table which they mightn't see. Finally, control drag from the add button to the array controller and choose the method `add:` . Do the same for the remove button but choose the method `remove:`. Now build and run the application and everything should work according to plan. If not, check the console for any errors. If you see something like `valueForUndefinedKey: This class is not key value coding-compliant for the key .....` then you've probably gone and spelt something wrong when setting up your bindings. Go and check your spelling. Assuming you can smell, sorry spell, you should find that your application works like a charm, you can add, remove and edit tasks and dates. You should also be able to sort your columns alphabetically as the array controller takes care of some basic sorting of objects by name, length, etc.

## Wrap-up

We managed to write that application in around 90 lines of code. For comparison, writing the same application without bindings took me nearly 140 lines of code, with certain features not implemented such as the sorting of rows. As I'm sure you can tell, this is a massive improvement and, as I say, table views are one of the aspects of Cocoa which gain the biggest benefit from bindings. There are times however when you may need to set up a table without bindings, perhaps when using a set of objects which aren't suitable for use with bindings since they aren't key value coding compliant. Never fear though! Next time, I'll show you how to set up table views without bindings for those times when bindings just aren't practical.

Follow the author of this post, [@alexjohnj](http://twitter.com/alexjohnj).
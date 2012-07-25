---
layout: post
title: "An Introduction To Bindings & KVC"
description: "An introduction to bindings & key value coding, two methods for simplifying the development of Cocoa applications."
keywords: "cocoa, objective-c, kvc, key value coding, bindings"
---

Bindings are an incredibly useful feature of Cocoa. Introduced in Mac OS 10.3 bindings allow developers to create incredibly complex applications in very few lines of code and, as a result, eliminate many bugs from their software that would normally arise from the sheer mass of code a developer would normally have to write. Whilst learning Cocoa, bindings aren’t a necessary thing to learn about and many budding developers will skip over bindings due to the sheer complexity of them. That’s OK but it is strongly recommended that you do learn how to use bindings since they will make you a better developer and allow you to eliminate much of the glue code that you would have to use without them.

<!--more-->

In this post, I’m going to show you how to create a very basic application (with limited real world use) that makes use of bindings. Keep in mind that bindings is a very deep and complex topic and this tutorial hardly scratches the surface of the topic. Non-the-less, this tutorial will prove useful for people looking to make their first steps into bindings.

A Primer On Bindings
--------------------

Bindings make use of a technology called Key Value Coding (KVC) which is simply a method that allows you to get & set values of variables by their names. Their names are simply a string and are referred to as keys. A simple example is below:

{% highlight objc %}
@interface Dog:NSObject{
	NSString *name;
}
//rest of interface code here	
{% endhighlight %}

To set the value of the variable `rex` using KVC we can do the following:

{% highlight objc %}
-(void)someMethod{
	Dog *rexy = [[Dog alloc] init];
	[rexy setValue:@"Rex" forKey:@"name"];
}
{% endhighlight %}

Now the interesting line of code here is this: `[rexy setValue:@"Rex" forKey:@"name"];`. This is relatively simple to understand but let's just break it down. First we have the name of the object we're sending the method to. Next we have the method `setValue:@"…"`. This is essentially the same as writing =. If you want to set the value to a number you can do the following: `[setValue:[NSNumber numberWithInt:30]];` The important thing to remember is that the argument to this method must be an object and not a generic C type. The final method we have is `forKey:@"…"`. This takes the argument of a NSString and said NSString is simply the name of the variable you want to change. Quite simple to understand really. To read the value of a variable using KVC do the following:

{% highlight objc %}
-(void)someMethod{
	NSString *anotherString = [rexy valueForKey:@"name"];
}
{% endhighlight %}

The syntax of this is, again, fairly simple to understand. We have our object rexy and then our method. The method `valueForKey:@"..."` always takes an argument of a NSString and that NSString is the name of the variable you want to change.

How Does This Fit Into Bindings?
--------------------------------

Bindings work off of the KVC system. In the following example, it’s possible to write a basic application using bindings in just a few lines of code. Using KVC, Cocoa is able to keep track of a variable and update a label to display it as the value changes. Let's demonstrate.

---

The Example
-----------

The first thing you need to do is create a new Xcode project (standard cocoa application, not document based or core data) and call it whatever you want. Inside of xcode, create a new Objective C class file that is a subclass of NSObject called AppController. Open _AppController.h_ and edit it to look like this:

{% highlight objc %}
#import <Foundation/Foundation.h>

@interface AppController : NSObject {
@private
    float foo;
}

@property (assign) float foo;

@end
{% endhighlight %}

Now open _AppController.m_ and edit it to look like this:

{% highlight objc %}
#import "AppController.h"

@implementation AppController
@synthesize foo;
- (id)init
{
	self = [super init];
    if (self) {
     [self setValue:[NSNumber numberWithFloat:50] forKey:@"foo"];
    }

    return self;
}

- (void)dealloc
{
	[super dealloc];
}
@end
{% endhighlight %}

A quick run-through of the code shows that we’re creating a variable called `foo`, creating synthesised accessor methods for it and then in the `init` method we’re setting the value to be 50 using KVC. Note that instead of creating the synthesised accessor methods we could have written our own getter & setter methods however they must be written as follows: `(float)foo` and `(void)setfoo:(float)x`. If you’ve created your own variable then it must follow that naming patter for your getter & setter methods or else the KVC and therefore bindings for that value won’t work.

The next step in our bindings example is to edit our _MainMenu.xib_ file. Create a UI similar to what I’ve done using a NSSlider and a label:

![The UI for our application featuring a label & a slider.](/images/posts/2011/04/introToBindingsAndKVC/screen-shot-2011-04-29-at-19-27-41.png)

Under the attributes inspector, set the slider to continuous. 

Now we are going to bind our user interface. Drag out a NSObject from the library in interface builder and set its class to AppController. Now, select the NSSlider and enter the bindings inspector for it (CMD+Alt+7). Expand the value menu and bind the the slider to AppController with a modal key path of foo like so:

![How to bind foo to a slider.](/images/posts/2011/04/introToBindingsAndKVC/bindingfootolabel.png)

Likewise, select the label and edit its value binding to look the same (bound to AppController with a modal key path of foo). Now, go ahead and build and run your application and you should find that as you move the slider the label updates with the value of the slider. You should also find that when you start the application, the label is 50 and the slider is centred. You’ve just created an application using bindings in far fewer lines of code than it would have taken with bindings. When I say far fewer I really mean about 10 but still, imagine having multiple sliders and text fields, then that 10 lines could grow quickly into 100! Bindings are especially useful when creating NSTableVeiws as they normally require a particularly large amount of glue code in order to make them work but this can be eliminated with bindings. The difficulty level of this however far exceeds the expectations of this tutorial and so shan’t be discussed.

![The finished application showing the label changing as the slider moves.](/images/posts/2011/04/introToBindingsAndKVC/screen-shot-2011-04-29-at-20-14-37.png) The finished application

What Have We Done?
------------------

Bindings can seem pretty magical at first however it's important that you know how bindings work. After all, isn’t magic really just a load of tricks? Essentially, when you move the NSSlider, the method called setValue:forKey is called to change the value of the variable `foo` as the slider moves. The NSSlider will either use synthesised accessors or manually created getter and setter methods depending on the availability (this is why naming of getter & setter methods is important, the wrong name and Cocoa won’t recognise them). How does it know to change the value `foo?` Well, when we bound the NSSlider to AppController, we set the modal key path to floatyNumber essentially telling the NSSlider that this is the variable to change & read from.

How Does The Label Update?
--------------------------

To get the label to update we use something called Key-Value-Observing (KVO). I haven’t really explained this but what happens is that when we bind the label to AppController and set the model key path to `foo` we register the label as an observer. Now, whenever the NSSlider moves & foo updates, the instance variable setter method for `foo` is called. When called, the label is notified that `foo` has been changed and so uses the method `valueForKey:` to get and display the new value. As a result of this our instance variable getter is again called, to return the value of `foo`.

Disadvantages Of Bindings
-------------------------

By now you're hopefully thinking that bindings are the best things since sliced bread (if not, please let me know why) however they do have a few small disadvantages. The first would be that Cocoa bindings is such a far-reaching and deep topic it will take you a long time to learn how to use bindings in more useful situations than the one featured. It will probably be frustrating but the end result will be that you’re a better programmer and you can create better, more complex applications easily. Put the time aside and practice, you’ll learn new things as you experiment.

The other, more serious problem would be that using bindings introduces a, albeit small, overhead on your applications. It can slow down your applications and will use slightly more memory than writing out all of that glue code. The impact is minimal but it’s important to way up the opportunity cost of using bindings in more complex projects. If you are using lots of bindings, you’re going to have a large overhead. Would it not be easier to perhaps remove some of them to improve performance slightly? Or would this require lots of glue code that could increase the cost of development a lot. This is something you will have to consider when making use of bindings.

Further Reading
---------------

As bindings is such a large topic it really is worth looking into some other sources to help further your knowledge. If you want you could look at the Apple documentation on [bindings](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CocoaBindings/CocoaBindings.html#//apple_ref/doc/uid/10000167i) & [KVC](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html#//apple_ref/doc/uid/10000107i) but, personally, I feel that the documentation isn’t written well for novices.

Another good source would be [this article](http://cocoadevcentral.com/articles/000080.php) from CocoaDevCentral. It provides some really good coverage on porting an existing application to bindings and includes a very useful example. The only problem would be that the information hasn’t been updated in some time and the UI for editing bindings has altered slightly in Xcode 3 and 4. You should, however, be able to figure out where all the buttons are fairly easily after some time mucking around.

The final source I recommend is a fantastic book by Aaron Hillegass, Cocoa Programming For Mac OS X. Not only is it THE definitive book on Cocoa Programming but one of the main projects in the book makes extensive usage of bindings. Be sure to pick up the [3rd edition](http://www.amazon.co.uk/Cocoa-Programming-Mac-OS-X/dp/0321503619/ref=sr_1_1?ie=UTF8&qid=1304104154&sr=8-1) (or [2nd](http://www.amazon.co.uk/Cocoa-Programming-OS-Aaron-Hillegass/dp/0321213149/ref=sr_1_1?ie=UTF8&s=books&qid=1304104161&sr=8-1) if you feeling cheap like me) as the first edition was written before bindings was introduced (and therefore has no information on them).

***Update 15/5/11*** Another resource I’d recommend is one I just wrote. [A Cocoa Bindings Example: Creating A Preferences Window](/2011/05/15/creating-a-preferences-window-in-cocoa-using-bindings/) walks you through the basics of applying the use of bindings by creating a fully functioning preferences window in under 50 lines of code using bindings.

Hopefully this post (and the links above) have been helpful for you and, as always, happy coding!

Follow the author of this post, [@alexjohnj](http://twitter.com/alexjohnj). 

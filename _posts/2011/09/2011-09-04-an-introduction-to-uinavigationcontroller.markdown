---
layout: post
title: "An Introduction To UINavigationController"
description: "Outlines how to use UINavigationController to manage a hierarchy of views in an iOS application."
keywords: "objective-c, cocoa touch, UINavigationController, UIViewController, UIView, iOS, multi-view app"
---

UINavigationController is  a class provided by Apple for managing multiple views of data in a hierarchy. I can guarantee that if you have used iOS you have used a navigation controller. It wouldn't be unfair to say that 90% of applications on iOS make use of a navigation controller at some stage. The reason is simple, navigation controllers are crazy easy to use and crazy powerful in terms of functionality. They're also really easy for your users to understand too since they're a common system UI element.

<!--more-->

*NB - This post assumes you've got the basics of iOS programming under your belt. You know what a view controller is, you know your way around Xcode and you've got a good grasp on the Objective C language.*

## UINavigationController Concepts

Before we dive into a sample program we'll take a look at the basics of how a UINavigationController works. As mentioned above, a navigation controller manages a hierarchy of views. This hierarchy of views is represented on a stack. At the bottom of the stack is your root view. This is the initial view which is presented to the user. From the root view, subviews are pushed onto the stack, with the current view visible to the user being at the top of the stack. (Generally) All the views which are on the navigation controller's stack have an instance of a UINavigationBar, this thing:

![A UINavigationBar in iOS.](/images/posts/2011/09/introductionToUINavigationController/uinavigationbarexample.png)

This is used to present a user interface to your users to navigate the navigation controllers stack. On all views except for the root view, the UINavigationBar will have a back button on the left hand side. The back button will have the title of the previous view in the stack. The right hand side of the navigation bar can house an additional button and it's possible to add a description to the navigation bar too by using some methods on the UINavigationBar. When navigating between views on the navigation stack, there are two methods you'll use frequently:

{% highlight objc %}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
{% endhighlight %}
 
&
{% highlight objc %}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
{% endhighlight %}

The first method is used to push a view onto the stack and the second method is used to return to the previous view on the stack. The animated boolean simply checks to see if you want to see the slide transition used when moving between views. In 99% of cases, you want to pass YES/TRUE to this argument. You'll actually rarely call popViewController: manually since the back button on a UINavigationBar is set up to automatically call it for you so in most cases you'll only be pushing view controllers. Below is a simple diagram demonstrating the use of these two methods and a navigation controller:

![A diagram showing the methods called when views are pushed and poped from the navigation stack.](/images/posts/2011/09/introductionToUINavigationController/viewheirarchyexample.jpg)

The concept of navigation controllers is relatively simple, and implementing them is really simple too. Here's a brief summary of what happens when setting up a navigation controller:

1.	Initialise a UINavigationController with a custom UIViewController as a root view.
2.	Set the UINavigationController as the root view of our applications window.
3.	Code the RootViewController so that when a button is pressed, a second view controller  is pushed to the navigation stack and a second view is loaded.
4.	Code the second view controller so that when a button is pressed, a third view controller is pushed to the navigation stack and a third view is loaded.
5.	Rinse and repeat for every view you want to add to the navigation controllers stack.

Along the way, I'm also going to show you how to add buttons to the UINavigationBar, since this is something you'll probably want to do very frequently when using a navigation bar. Notice how I didn't mention that we're going to set up a button to navigate back in the navigation stack. Well, that's because we aren't going to do that since the UINavigationController class handles all of this for us. Ready to dive into the example? Here we go…

## The UINavigationController Example

To begin, create a new iOS window-based application. Yes, a template exists for a pre made navigation-based application but if you used that, then you're not really learning anything. Plus, it's always better to start off with a blank slate, that way you know _exactly_ what's going on with your application. When creating the project, set the "Device Family" of your application to iPhone (by default it's a universal application). In addition, there's no need to use Core Data in this application, so go ahead and disable that option too. Now that we've created the project, we've got a choice to make. When using a UINavigationController, there's two ways to implement it in your application. The first is to create and manage the UINavigationController programmatically (easy, powerful and fast). The other way is to manage the UINavigationController through interface builder which is also easy but (in my opinion) very unintuitive and slow (in terms of development). Given that the programmatic way is just _better_ than the interface builder way, I'm going to show you how to use a navigation controller programatically but if you want to, you can probably figure out how to use the interface builder navigation controller with ease. 

The first thing we need to do (assuming you're creating the navigation controller programatically) is to add three new UIViewController subclasses to your project. When creating the subclasses, ensure to check the "With XIB for user interface" box, in order to make your life a little bit easier. In addition, in order to aid the readability of the code, you'll probably want to name your view controllers as follows:

- RootViewController
- SecondViewController
- ThirdViewController

Doing this will make the tutorial easier to follow since both of us will have the same named class files. With the view controllers created, we need to go ahead and actually set up our navigation controller. We need to declare a UINavigationController instance in our app delegate, import the root view controller to our app delegate and then initialise the navigation controller with the root view controller as its root view. First, add the navigation controller instance variable into your AppDelegate.h file and import the root view controller class:

{% highlight objc %}
#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface YourAppDelegateFileName : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;

@end
{% endhighlight %}

Remember to synthesise the navController instance variable in your app delegates implementation file. Now, in the implementation file, edit the `applicationDidFinishLaunching` method to look like this:

{% highlight objc %}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:	(NSDictionary *)launchOptions
{
    UIViewController *rootView = [[RootViewController alloc]
											initWithNibName:@"RootViewController" 
											bundle:nil];
    self.navController = [[UINavigationController alloc] initWithRootViewController:rootView];
    [[self window] setRootViewController:navController];

	//template code
    [self.window makeKeyAndVisible];
    [rootView release];
    return YES;
}
{% endhighlight %}

Here, we are initialising the instance of the navigation controller with the root view being the view controller. We're then setting the windows root view to be the navigation controller. Finally, we release the root view in order to prevent a leak. You should also release the navController in your app delegates `dealloc` method, in order to prevent another leak. 

Now, if you build and run the app, you'll find that you get a blank screen with a navigation bar across the top. This means that your navigation controller is working, so now all that's really left is to build the UI and write a couple of line soy code. Open the _RootViewController.xib_ file and edit the UI to however you feel, just make sure you feature at least one button in the view in order to allow you to progress to the next view. One thing to note, when editing a view that has a navigation bar across the top, Interface Builder doesn't actually present the location of the navigation bar to you. As a result, you have to plan your UI with the location of the navigation bar in mind. Fortunately, Interface Builder provides a really easy way to do this, select your view and open up the attributes inspector. Under the collapsible menu entitled "Simulated Metrics" select the "Top Bar" drop down menu and choose "Navigation Bar". Now you have a navigation bar placed at the top of the view which allows you to lay out your view whilst taking the navigation bar into consideration.

![Simulating a navigtaion bar in Interface Builder.](/images/posts/2011/09/introductionToUINavigationController/enablingsimulatednavigationbar.png)

Whilst you're in Interface Builder, you may as well go and design the other two views too. Again, on the second view, remember to include a button to progress to the third view (this isn't necessary on the third view). In addition, on the third view, include a blank label in the centre of the screen. This will come in handy later on. Once you've designed all three views, continue onwards.

## Push'n Views

Now that all of our views have been crafted, it's time to push them onto the navigation stack. In the RootViewController.h file, import the SecondViewController.h file. In addition, declare a method called `-(IBAction)continueToNextView:(id)sender;`. In the implementation of this method edit it to look like this:

{% highlight objc %}
-(IBAction)continueToNextView:(id)sender{
    UIViewController *secondView = [[SecondViewController alloc] 
                                initWithNibName:@"SecondViewController" 
                                bundle:nil];
    [[self navigationController] pushViewController:secondView animated:YES];
    [secondView release];
}
{% endhighlight %}

There's that magical `pushViewController` method I told you about before. All we're doing here is pushing the second view controller onto the top of the navigation stack and, in the process, loading the second view. Open up the RootViewController.xib file and control-drag from the button you created earlier to the files owner and choose the continueToNextView: method. Now, build and run your application and click your button and, voila! The second view loads. In addition, a back button appears in the navigation bar and if you tap it, voila!(again) The first view loads! Really, all you need to do is copy this method into the second view controller class file, replacing SecondViewController with ThirdViewController and then you've got yourself an app that navigates between three views! Before you do that though, I want to show you a few other things.

## Improving The User Experience With A Title

One thing to note is that the navigation bar looks a little sparse. It's just a blue bar. Normally there's a title in that blue bar because it makes it easier for the user to tell, at a glance, where they are in your application. So, adding a title to your navigation bar is very important. It's also very easy too. There's one method to call. In the RootViewControllers `viewDidLoad` method, edit it to include this one extra line of code:

{% highlight objc %}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"RootView"];
}
{% endhighlight %}

This line of code sets the title of your view. Now, when your application loads, the navigation bar will have the title "RootView". But wait, it gets better. If you navigate to the second view in your application you'll find that the back buttons title is no longer "Back" but now it's "RootView". One of the awesome things about the UINavigationController class is how many little details it takes care of for you. This is one such little detail as it makes it easier for the user to know where they are in your application and also where they're going should they decide to head back. You should always provide a title for your view controllers because it makes your application that much easier to use. Go ahead and give your second view controller a title too using the same method. 

## Finishing Up With The Third View

Our application is close to completion. We just need to set up the second view controller to push the third view onto the navigation stack. In the SecondViewController.h file, declare a method called `-(IBAction)continueToNextView:(id)sender;` (yes it's the same as the previous one). In addition, import the ThirdViewController.h file. Now, in the `continueToNextView:` methods implementation, edit it to look like this:

{% highlight objc %}
-(IBAction)continueToNextView:(id)sender{
    UIViewController *thirdView = [[ThirdViewController alloc] 
                                initWithNibName:@"ThirdViewController" 
                                bundle:nil];
    [[self navigationController] pushViewController:thirdView animated:YES];
    [thirdView release];
}
{% endhighlight %}

Pretty much exactly the same as the RootViewControllers method. Open up the SecondViewController.xib file and control drag from the button you placed earlier to files owner and select the `continueToNextView` method. Now, build and run your app and again, everything should work fine and you should be able to navigate between the three views perfectly. And that is, essentially, an introduction on how to use UINavigationControllers. You just push views onto a stack and let Cocoa Touch handle taking them off the stack. There's just one more thing I want to show you that you'll probably end up using frequently. 

## Adding Buttons To the Navigation Bar

One thing developers _love_ to do is add buttons to the navigation bar. Hey, why waste space? If we had built our navigation controller in Interface Builder, adding a button to the navigation bar would be as easy as dragging one onto it. Instead though, we built our navigation controller programmatically and so, now we must build our button programmatically too. It's really easy though. In the ThirdViewController.h file edit it to look like this:

{% highlight objc %}
#import <UIKit/UIKit.h>

@interface ThirdViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *label;

-(void)menuButtonPressed;

@end
{% endhighlight %}

All we've done is declare a method and an outlet to a label. Remember, synthesise the outlet in your implementation file. Now, in the ThirdViewController.xib file, hook the label outlet up to the blank label I told you to create earlier (if you didn't, create one now). Now edit the implementation of the `menuButtonPressed` method to look like this:

{% highlight objc %}
-(void)menuButtonPressed{
    [label setText:@"COOL!"];
}
{% endhighlight %}

Very simple. The `menuButtonPressed` method is going to act as a selector for our navigation bar button when it's pressed, if you were wondering. Now we want to go ahead and edit the `viewDidLoad` method to create our navigation bar button and add it to the navigation bar. In the ThirdViewController.m file, edit the `viewDidLoad` method to look like this:

{% highlight objc %}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] 
                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                              target:self 
                              action:@selector(menuButtonPressed)];

    [[self navigationItem] setRightBarButtonItem:barButton];
    [barButton release];
}
{% endhighlight %}

Here, we are creating a UIBarButtonItem. This is a special item that can be placed in UINavigationBars and UIToolbars. UIBarButtonItems are a separate topic on their own but essentially, you can initialise them with a certain style (amongst things) which is provided by Apple. We chose the generic `UIBarButtonSystemItemAction` but there's plenty of others for you to choose from, or you could make your own. You also provide a target (the object which contains the selector) and a selector to be performed when the button is pressed. Now, if we build & run the application and navigate to the third view, you'll find a button in the navigation bar and, if you press it, your blank label should now have text in it. Adding a button to your navigation bar is as simple as pushing views onto a stack. 

## Wrap-Up

As you can hopefully see, it's really easy to set up and use a UINavigationController in your application which is good since you'll probably be using them a lot. To conclude, here's a few things to remember when using navigation controllers:

- Navigation controllers have a stack, the current view visible to the user is at the top of the stack. 
- When you want to load a new view you push its view controller to the top of the stack using the `pushViewController: animated:` method
- In 99% of cases you want to pass YES/TRUE to the `pushViewController: animated:` method in order to make it clear to the user that something has changed on screen.
- You can remove view controllers from the stack using the `popViewControllerAnimated:` method but you'll rarely call it since the UINavigationBar handles this for you. 
- When you add a UIViewController to the navigation controllers stack **remember** to release the view controller after pushing the view controller onto the stack (unless you're using ARC), otherwise you've got a big memory leak on your hands. 
- **Never** subclass UINavigationController. It hurts. 

Follow the author of this post, [@alexjohnj](http://twitter.com/alexjohnj).
---
title: Using Sheets in Cocoa
layout: post
---

Sheets are one of the premier features of Cocoa and the Aqua user interface. Sheets are used extensively throughout Mac applications and offer a convenient way to display a dialogue that is attached to a parent window. This makes using sheets desirable as it means that it's not possible to easily lose the modal dialogue behind other windows and it also makes it obvious that what programme or window the dialogue belongs to since the dialogue is attached to it. 

<!-- more -->

In this tutorial, I'm going to show you how to create and use three different kinds of sheets: alert sheets, file handling (open/save) sheets & custom sheets. They all work in similar ways but there's a few little differences between the implementation of these three types of sheets. Before beginning this tutorial, it's important to understand that this tutorial assumes quite a bit of prior knowledge. It assumes you have a firm grasp on Objective-C, have used Cocoa & Xcode before, understand window programming in Cocoa and, the one that'll catch a fair few people out, can use blocks. Blocks are an Objective-C (actually a C) language feature and are _very_ handy when using sheets. They're not too hard to pick up and understand, and it's quite possible that you'll pick up their syntax by reading the code examples in this tutorial but, I'd still recommend you do a little bit of background reading on blocks (they're very useful, honest!). 

## Sheet Concepts

The most important thing to understand about sheets is that **there is no NSSheet class**. No such thing whatsoever. Sheets aren't special objects, they're simply windows that are attached to a parent window and are presented modally to the user so that he/she can't interact with the parent window while the sheet is being displayed. I'm sure you've seen a sheet before, but here's a diagram showing what I just said: 

![]({{ site.baseurl }}/images/drafts/2012/06/sheetsInCocoa/sheetDiagram.png)

Now that we've dispelled the myth of NSSheet, you're possibly wondering what class does handle sheet presentation. It's quite possible that you're thinking that NSWindow handles it. After all, if sheets are just windows, it's logical to think that NSWindow handles sheet presentation. Surprisingly, sheet presentation is not handled by NSWindow but instead by NSApplication. It's a bit odd I know (it has something to do with sheets not being part of the original OpenStep specification) but if you look at the header file (or even the documentation) for NSApplication you'll find the methods used for presenting & dismissing sheets in there.

---

Aside from understanding that there is no NSSheet class, the other key concept that you need to understand is that sheets are document-modal. This means that while execution of your application continues when the sheet is presented, the user can't interact with any part of the application (or document, if your application is document based) other than the sheet. You probably already knew that the user couldn't interact with any other part of the application from experience but you may not have known that the execution of your code continues after the sheet has been displayed, even if the user hasn't interacted with the sheet. What this means is that any code after the method used to present your sheet gets executed immediately after the sheet is presented to the user. 

``` objc
- (void)showMeASheet{
	[self doSomeStuff];
	[self showSheet]; // NOT, the actual method for showing a sheet
	[self doSomeMoreStuff]; // called immediately after the sheet is shown
}
```

This is a small problem since if we need to do something with the result of the user's interaction with the sheet, we'll need to be notified of when they finish with the sheet, what they did with the sheet and then we'll need to do something with that information. Oh, and we can't do that in the same method that we called the sheet in. The solution is to use a completion handler. A completion handler is either a block or a method (called via a selector) that gets executed when our sheet is dismissed by the user (but not actually removed from the screen) allowing us to use the information gathered from the sheet to carry out further instructions. Completion handlers are pretty easy to use once you adapt your code for them but they create a lot of spaghetti code, especially if you're not using block based completion handlers. 

## Getting Started

For this example, we need to make a new Cocoa application, that isn't document based and doesn't use core data. The code in this example will be written assuming you're using automatic reference counting, so I'd advise you turn that on as well when making the new Xcode project.

Once you've created the new project in Xcode, we need to create some new files. Create the following files:

- A class called *AppController* that is a subclass of NSObject
- A class called *CustomSheetWindowController* that is a subclass of NSWindowController. Make sure that “With XIB for User Interface” is enabled. Rename the *CustomSheetWindowController.xib* file to *CustomSheet.xib* too. 

With these files created, open *MainMenu.xib* and drag out three buttons onto the main window. Also drag out a label and arrange the controls as you see fit. Next, open *AppController.h* and edit it to look like this:

``` Objc
#import <Foundation/Foundation.h>

@interface AppController : NSObject

@property (weak) IBOutlet NSTextField *outputLabel;

- (IBAction)displayAlertSheet:(id)sender;
- (IBAction)displayOpenPanelSheet:(id)sender;
- (IBAction)displayCustomSheet:(id)sender;

- (void)sheetDidEnd:(NSWindow *)sheet resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo;

@end
``` 

Back in *MainMenu.xib*, drag out a new object and make it a subclass of *AppController*. Then, connect the `outputLabel` outlet to the label you added to the window earlier. Also, connect the three actions to the three buttons you just added and title the buttons according to which action they're linked to. Remember to @synthesize the `outputLabel` property in *AppController.m*. Now that we've setup our project, we can start playing with the first type of sheet.

## Alert Sheets

Alert sheets are among the most common types of sheets used in Mac OS X, being used to display errors and warnings. Alert sheets are somewhat simple to create making use of a simple to understand method in NSAlert. Alert sheets are not, however, particularly elegant to code. The APIs Apple provides for alert sheets use the old callback method for completion handlers rather than the far more streamlined block based completion handlers found in modern APIs. The example code will show you what I mean by the lack of elegance but essentially, you're going to end up with code all over your classes if you need to get any sort of information back from an alert sheet. 

Creating an alert sheet is incredibly simple. Simply create a standard NSAlert object and then, instead of calling `runModal:` to display the alert, call `beginSheetModalForWindow:modalDelegate:didEndSelector:contextInfo:`. To see an example, implement the `displayAlertSheet:` method in your *AppController.m* file. 

``` objc
- (IBAction)displayAlertSheet:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"An Alert Sheet"
                                     defaultButton:@"OK"
                                   alternateButton:@"Other"
                                       otherButton:nil
                         informativeTextWithFormat:@"This is a standard NSAlert displayed as a modal sheet. Click a button and have a look at the output."];
    [alert beginSheetModalForWindow:[[NSApp delegate] window]
                      modalDelegate:self
                     didEndSelector:@selector(sheetDidEnd:resultCode:contextInfo:)
                        contextInfo:NULL];
}
```

The first line of code should be pretty familiar to you, it's just creating a normal NSAlert object. The second line uses the new `beginSheetModalForWindow:modalDelegate:didEndSelector:contextInfo:` method however. The method takes 4 arguments, only one of them is actually required however. 

The first argument is an NSWindow, more specifically the parent window to which the sheet will be attached to. This argument is required since a sheet must be attached to a parent window, otherwise the sheet would just be a window. 

The second argument is the modal delegate. The modal delegate is the object were the method for your completion handler can be found. If you don't need a completion handler (i.e. if you don't need to get any information about how the user interacted with the sheet) then you can pass `nil` as an argument for your modal delegate. 

The third argument is the did end selector, a.k.a the completion handler. Here, you pass a selector that performs the method that is your completion handler. For this sheet (and for most sheets), the completion handler will take the form `sheetDidEnd:resultCode:contextInfo:`. We'll look at that method in more detail later. Again, this argument can be `nil` if you don't need a completion handler but chances are you will need one. 

The final argument is the context info. You can pass anything as a context info argument, a string, an array, a dictionary, anything you want. The data provided by the context info gets passed to the completion handler and can be used to determine what sheet called the completion handler or can provide an object which can be modified with the result of the alert sheet. Again, completion handlers aren't mandatory and there's a good chance you mightn't need to use one. In the event that you don't need a completion handler pass `NULL` (not `nil`) as an argument. 

### The Completion Handler

In order to get any sort of feedback from the alert sheet, we need to write a completion handler. As explained above, the completion handler is a method that gets called when the sheet is about to be closed. It allows us to get feedback regarding what button was pressed on the alert sheet. Completion handlers can take any form really, but the most common is this:

``` objc

- (void)sheetDidEnd:(NSWindow *)sheet resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo;

```

This method has three arguments, a window, result code and a context info. The window simply indicates which sheet is calling the completion handler and will be useful later on when working with custom sheets. The result code indicates the return code, an integer that is returned by the sheet when it is told to end. For now you don't have to worry about specifying a return code, you just need to know how to use the resultCode. When we work with custom sheets however, then you'll learn how to specify a return code for a sheet. 

We need to implement a completion handler for our alert sheet. To do this, implement the following method in *AppController.m*. 

``` objc
- (void)sheetDidEnd:(NSWindow *)sheet resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo{
	switch (resultCode) {
		case NSAlertDefaultReturn:
			self.outputLabel.stringValue = @"OK Button pressed.";
			break;
			
		case NSAlertAlternateReturn:
			self.outputLabel.stringValue = @"Other button pressed.";
			break;
			
		default:
			self.outputLabel.stringValue = @"Something else was pressed, or something went wrong.";
			break;
	}
}
```

The implementation of this method is fairly simple. We're just running a comparison of the resultCode against a series of constants to determine what button was pressed by the user. `NSAlertDefaultReturn` & `NSAlertAlternateReturn` are just a set of constants defined in NSPanel.h. They have the values of 1 and 0 respectively since when the user presses the default button in the alert sheet, the sheet returns a value of 1. Likewise, when the user presses the alternative button, the sheet returns a value of 0. 

If we build and run the example application now and click on the alert sheet button then you should get a sheet that appears with two buttons on it. Clicking the OK button will set the output label's text to "OK button pressed" and pressing the cancel button will set the output label's text to "Other button pressed". 

So that's how we create an alert sheet. It's not too hard, it just uses a special method and a completion handler to work its magic (which will be revealed when we work with custom sheets). The problem with alert sheets is that they're not particularly streamlined. You have to implement a special method to act as a completion handler which can make things really messy. The next type of sheet we're going to work with though is much neater and doesn't require the implementation of seperate methods to act as a completion handler. Instead, it uses blocks. 

## File Handling Sheets + Blocks = ♥♥♥

File handling sheets are a joy to use. The new APIs Apple introduced in OS 10.6 for file handling windows means it's *super* easy to use them since all the completion handlers for file handling sheets are completely block based. File handling sheets work the same way as alert sheets *in principle*, but the way they're implemented is different. File handling sheets still have to attach themselves to a parent window, and they still need a completion handler that is called when the sheet is dismissed. The completion handler still takes a parameter with the same function as (but a different name to) the `returnCode` that indicates what button was pressed. However, file handling sheets don't require a modal delegate though and they don't have any sort of context info parameter. They also don't need to provide a selector to function as the completion handler since the completion handler is simply a block. This makes the method called to create a file handling sheet far nicer than that called for creating an alert sheet. 

This is the traditional way of creating a file handling sheet, using the old, non block based method pre Mac OS 10.6:

``` objc
- (void)beginSheetForDirectory:(NSString *)path file:(NSString *)name modalForWindow:(NSWindow *)docWindow modalDelegate:(id)modalDelegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo;
```

Here's the new way:

``` objc
- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger result))handler;
```

It's a lot shorter, easier to understand and cleaner. It's so much better that Apple's actually deprecated the traditional way in favour of the block based method. It takes two arguments. The parent window which it is to attach itself to and the completion handler, which serves the same purpose as the didEnd selector in the traditional method. 

Let's have a look at implementing this method in our example application using a NSOpenPanel file handling sheet. Open up *AppController.m* and edit the body of the `displayOpenPanelSheet:` to look like this:

``` objc
- (IBAction)displayOpenPanelSheet:(id)sender {
	NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
	oPanel.canChooseDirectories = YES;

	[oPanel beginSheetModalForWindow:[[NSApp delegate] window]
				   completionHandler:^(NSInteger result) {
					   switch (result) {
						   case NSFileHandlingPanelOKButton:
							   self.outputLabel.stringValue = oPanel.URL.path;
							   break;

						   case NSFileHandlingPanelCancelButton:
							   self.outputLabel.stringValue = @"You cancelled the open panel.";
							   break;

						   default:
							   self.outputLabel.stringValue = @"You did something with that open panel, don't know what.";
							   break;
					   } 
				   }];
}
```

Let's step through this body of code. First of all we create an instance of NSOpenPanel and configure it so that it can choose directories. We then call the `beginSheetModalForWindow: completionHandler:` method and pass two arguments, the parent window to attach the sheet to and a block which is used as a completion handler just before the sheet is closed. The block itself takes one argument, the result. This is exactly the same as the resultCode used in the previous alert sheets. We, again, run a comparison on the paramater and compare it to two constants,` NSFileHandlingPanelOKBUtton` & `NSFileHandlingPanelCancelButton`. These constants have the same value as the `NSAlertDefaultReturn` and `NSAlertAlternateReturn` constants. Once we've determined what button was pressed, we set the output label to a corresponding string. 

If we build and run the application now and click on the open panel sheet, we'll see an open panel appear and choosing a directory or cancelling the sheet will change the string in the output label. 

That's all there is to file handling sheets. They're very easy to implement and very nice to work with since you don't have to have lots of callback methods all over your classes. One thing to noet, implementing an NSSavePanel sheet is exactly the same as implementing an NSOpenPanel sheet. 

## When the Defaults Don't Cut it: Custom Sheets

Building custom sheets in Cocoa is a very easy process. Since a sheet is just a window attached to another window, creating a custom sheet simply involves creating a new window (either programmatically or via Interface Builder) and using a special method (that's very similar to the one used to display alert sheets) to display the window as a sheet. 

When designing sheets in Interface Builder, the process is nearly identical to designing new windows. There is but one difference, you must remember to specify that the sheet should **not** be visible at launch. If you don't do this, you'll end up with lots of weird graphical glitches when displaying your sheet and it won't actually end up looking like a sheet. 

In our example application, we need to first design our custom sheet. Open _CustomSheet.xib_ and add two buttons to the window. Name them "Done 1" & "Done 2". In addition, select the window and open its attributes inspector. Under “Behaviour” **uncheck** the option labelled “Visible at Launch”. Now open up _CustomSheetWindowController.h_ and declare the following methods:

``` objc
#import <Cocoa/Cocoa.h>

@interface CustomSheetWindowController : NSWindowController

- (IBAction)dismissCustomSheetButton1:(id)sender;
- (IBAction)dismissCustomSheetButton2:(id)sender;

@end
```

Then, open up _CustomSheetWindowController.m_ and implement the two method we just declared like this:

``` objc
- (IBAction)dismissCustomSheetButton1:(id)sender {
    [NSApp endSheet:self.window returnCode:0];
}

- (IBAction)dismissCustomSheetButton2:(id)sender{
    [NSApp endSheet:self.window returnCode:1];
}
```

Re-open _CustomSheet.xib_ and connect the two buttons we made earlier to these two methods via the _File's Owner_ instance. 

We've done things in reverse order here and written the code to close the sheet before we've written the code to open the sheet. The method `endSheet: returnCode:` doesn't actually close the sheet, it simply calls the sheet's completion handler which will then handle closing the sheet. The `returnCode` parameter is an integer (similar to `NSAlertDefaultReturn`) which you can use in the completion handler to figure out what button was pressed to close the sheet. 

Now that we've implemented closing the sheet, let's actually display it. Open _AppController.h_ and import the _CustomSheetWindowController.h_ class. Then declare one instance variable called customSheetController like this:

`@property (strong) CustomSheetWindowController *customSheetController;`

Remember to `@synthesize` it. Next, open _AppController.m_ and implement the `displayCustomSheet:` method. Edit it to look like this:

``` objc
- (IBAction)displayCustomSheet:(id)sender {
    if(!_customSheetController){
        _customSheetController = [[CustomSheetWindowController alloc] initWithWindowNibName:@"CustomSheet"];
    }
    [NSApp beginSheet:self.customSheetController.window
       modalForWindow:[[NSApp delegate] window]
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:resultCode:contextInfo:)
          contextInfo:NULL];
}
```

In the first line of this method we check to see if the `cusotmSheetController` instance variable has been initalised. If it hasn't, we initialise it. As you can see, the method for initalisign the sheet's controller is exactly the same as initialising a window controller since it is a window controller. After initialising the sheet's controller, we display the sheet using the method `beginSheet: modalForWindow: modalDelegate: didEndSelector: contextInfo:`. Seem familiar? The method is nearly identical to the method used to display an alert sheet with just one extra argument, the sheet which you want to display. Simply pass the window (not the window controller) that you want to use as a sheet. The remaining arguments work in exactly the same way as the arguments in the alert sheet's method. 

The final step in implementing our custom sheet is to write the completion handler. In the body of code above, note that we've used the same completion handler as the one we used for the alert sheet previously. More than one sheet can share the same completion handler but you'll have to include some extra logic in the completion handler to work out which sheet is calling it. In our completion handler (`sheetDidEnd: resultCode: contextInfo:`), edit it to look like this:

``` objc
- (void)sheetDidEnd:(NSWindow *)sheet resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo {
    
    if(sheet == self.customSheetController.window){
        switch (resultCode) {
            case 0:
                self.outputLabel.stringValue = @"Custom sheet button 1 pressed.";
                break;
                
            case 1:
                self.outputLabel.stringValue = @"Custom sheet button 2 pressed.";
                break;
        }
        
        [self.customSheetController.window orderOut:self];
    }
    
    else{
        switch (resultCode) {
            case NSAlertDefaultReturn:
                self.outputLabel.stringValue = @"OK Button pressed.";
                break;
                
            case NSAlertAlternateReturn:
                self.outputLabel.stringValue = @"Other button pressed.";
                break;
                
            default:
                self.outputLabel.stringValue = @"Something else was pressed, or something went wrong.";
                break;
        }
    }
}
```

We've added some extra logic to this completion handler to determine if the sheet calling it was the alert sheet or the custom sheet. Here, we're checking to see if the sheet passed as an argument to the completion handler is the same as `customSheetController.window` instance variable. Alternatively, we could have passed a unique NSString to the `contextInfo` parameter when displaying both sheets and then used the `contextInfo` parameter in the completion handler to determine which sheet is calling the completion handler. 

Within the first if statement, we're using a simple switch statement to determine which button was pressed (again, using the `resultCode` argument) and then displaying a string accordingly. One thing to note is the `orderOut:` method. This method closes the window (but doesn't release it) and then makes the window beneath it the key window. You call this method on the sheet you want to close and the argument passed is the sender, normally `self`. You need to remember to call this method when using a custom sheet otherwise your sheet won't disappear. 

Now, build & run the application and test the custom sheet feature. Displaying the custom sheet should work and the output label should display a different string depending on what button is used to close the sheet. 

## Wrap Up

That's everything you need to know to start using sheets. You should now know how to use custom sheets, alert sheets and file handling sheets and you should also now know how to use completion handlers (a practice that can be used with things other than sheets). Just one or two things to note. When creating a custom sheet, if your sheet has no custom logic (for example, a sheet that simply displays a spinning activity indicator), you don't need to create a controller for it, you can jsut create a XIB file and initialise an instance of NSWindow with it via NSBundle. In addition, when creating custom sheets, some people prefer to use the NSPanel subclass of NSWindow, rather than an instance of NSWindow. Using an NSPanel for a custom  sheet instead of an NSWindow is identical in implementation. 

Finally, Apple currently does not provide any methods that use block based completion handlersr for alert sheets and custom sheets (here's hoping they're available in 10.8) but there are some Objective C categories floating around on the internet that try to provide a method of using blocks as a completion handler with NSAlert and custom sheets. 
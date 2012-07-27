---
layout: post
title: "Unarchiving a Zip File in Cocoa"
description: "Extracting a file in Cocoa isn't immediately obvious. This post outlines how to do so using NSTask."
keywords: "zip, unzip, unarchive, extract, unzip library cocoa, objective-c unzip, iOS unzip, mac app unzip, mac app extract, mac app unarchive"
excerpt: "It's reasonably common for an application to need to download a file from the internet nowadays. Quite often, these files come packaged as zip archives, which require extracting. When newish Cocoa developers encounter a zip file that they need to extract in their application, they'll often run to the Cocoa documentation to find a class and method that handles unarchiving a zip file. Apple doesn't provide a class for unarchiving files though. At least, not an immediately obvious one. When their searching of the docs fails, they'll turn to a 3<sup>rd</sup> party library to handle unarchiving. Plenty of these exist, but they're completely unnecessary. Apple provides an excellent tool for unarchiving files in Cocoa, people just don't realise they can use it. That tool, is **NSTask**."
---

It's reasonably common for an application to need to download a file from the internet nowadays. Quite often, these files come packaged as zip archives, which require extracting. When newish Cocoa developers encounter a zip file that they need to extract in their application, they'll often run to the Cocoa documentation to find a class and method that handles unarchiving a zip file. Apple doesn't provide a class for unarchiving files though. At least, not an immediately obvious one. When their searching of the docs fails, they'll turn to a 3<sup>rd</sup> party library to handle unarchiving. Plenty of these exist, but they're completely unnecessary. Apple provides an excellent tool for unarchiving files in Cocoa, people just don't realise they can use it. That tool, is **NSTask**. 

<!-- more -->

## NSTask

Those of you who've already used NSTask have probably figured out how to use it to extract a zip file now that I've mentioned it. “Oh yeah, OS X ships with a built in unzipping command (`unzip`). And I can use NSTask to execute subprocesses. So… create an NSTask instance that executes the `unzip` command! Brilliant! It's so obvious now! Thanks for the brainwave!” Those of you who haven't used NSTask will be thinking “How's that going to help? The docs don't mention any methods called `extractFileAtPath: toPath:`.” As mentioned above, NSTask can execute subprocesses from within your application. OS X has a built in command for unarchiving files (no, not Archive Utility, a command line tool). Go ahead and try it. Create a new zip file, start a terminal session and then cd into the directory that holds the zip file. Then run the following:

> $ `unzip fileName.zip`

You'll get some output from the command listing the files and folders in the archive as well as what the command is doing. We can use this command in a Cocoa application by using the NSTask class. If you've never used NSTask before, don't worry, I've got just the example to get you started. (If you have, you can probably guess where I'm going with this).

## Unzipper.app

Launch Xcode, create a new Cocoa application, non document based and without Core Data, unit tests or any of that fancy stuff, this is an incredibly simple application we're writing here. Make sure you've enabled automatic reference counting though. You'll want to create a new Objective-C class (File > New File > Cocoa > Objective-C class) that is a subclass of NSObject. Call it *AppController*. Open *AppController.h* and declare a NSString called `filePath` and two methods, `openFile:` & `unarchiveFile:` like this:

{% highlight objc %}

#import <Foundation/Foundation.h>

@interface AppController : NSObject

@property (strong) NSString *filePath;

-(IBAction)openFile:(id)sender;
-(IBAction)unarchiveFile:(id)sender;

@end

{% endhighlight %}

Remember, `@synthesize` the property in *AppController.m*. The first thing we'll do is write the `openFile:` method. In *AppController.m*, edit the body of the method to look like this:

{% highlight objc %}

-(IBAction)openFile:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    if(self.filePath != nil){
        self.filePath = nil; // nil the path in case the user is opening a second file.
    }
    
    self.filePath = [[NSString alloc] init];
    NSInteger choice = [oPanel runModal]; 
    if(choice == NSOKButton){
        self.filePath = [[oPanel URL] path];
    }
}

{% endhighlight %}

Nothing special here. If you haven't encountered [NSOpenPanel][NSOpenPanelDoc] before, it's pretty easy to understand the basics. You create an open panel and call `runModal:` to display it in a modal window. You'll normally call this whilst assigning an integer (or NSInteger in this case) a value, since the method returns a number, depending on if the user chooses cancel or OK. When the open panel is dismissed, you'll want to run a comparison on said integer. `NSOKButton` is just a constant for the number 1, which the open panel returns if the user presses OK. Assuming the integer equals 1, we set the `filePath` to the URL assigned to the open panel when the user presses OK (we convert the URL to a string first). The URL is just the path to the file the user chose. 

We now need to edit the `unarchiveFile:` method to actually unarchive the zip file. It's time to play with NSTask! Edit the method to look like this:

{% highlight objc %}

-(IBAction)unarchiveFile:(id)sender{
    if(self.filePath == nil){
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" 
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"You need to select a file path"];
        [alert runModal];  //Alert the user and backout of the method if the file path hasn't been
        return; 
    }
    
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init]; //this lets the user choose where to extract the file to. 
    [oPanel setCanChooseFiles:NO];
    [oPanel setCanChooseDirectories:YES]; 
    [oPanel setCanCreateDirectories:YES]; //May as well do this, UX and all.
    
    NSInteger choice = [oPanel runModal];
    if(choice == NSOKButton){
        NSString *extractPath = [[NSString alloc] initWithString: [[oPanel URL]path]]; 
        NSArray *arguments = [NSArray arrayWithObject:self.filePath]; 
        
        NSTask *unzipTask = [[NSTask alloc] init];
        [unzipTask setLaunchPath:@"/usr/bin/unzip"]; //this is where the unzip application is on the system.
        [unzipTask setCurrentDirectoryPath:extractPath]; //this means we only have to pass one argument, the path to the zip.
        [unzipTask setArguments:arguments];
        [unzipTask launch];
    }
}

{% endhighlight %}

There's a bit of code there. The first if statement is just some error checking, the comment explains why that is there. We create another open panel, this one's for the user to choose where the zip file is being unarchived to. We call some `setCanDoX:` methods on the open panel to make sure that the user doesn't try and extract the zip file to another file (which would just fail horribly). The open panel is displayed and the resulting path is assigned to a string as we did before. We then set up an array called arguments. These are the arguments we're going to pass to the unzip command. It takes quite a few but we're only interested in telling it where the zip file is. Note that even if there's only one argument being passed, it must be put into an array (I think this is due to the program name (unzip) also being an argument). The array must also be immutable. Next, we actually create our NSTask instance. We set the launch path to the path where the unzip application is (*/usr/bin/unzip*) and then call the method `setCurrentDirectory:`. We set this to the `extractPath`. This is like cd'ing into the extract directory. We could have, instead, put two arguments into the arguments array, the path to the zip and the path to extract it to (in that order). We next assign the arguments array to the NSTask instance and then we call `launch:`. This, unsurprisingly, launches the task. 

Before we test the application, open *MainMenu.xib* and drag out two buttons onto the main window. Also drag out a NSObject and set it's class to AppController. Label the buttons “Open” and “Extract” and connect them to the appropriate methods in the AppController instance. Now, build and run the application. If you haven't, create a zip file and, open it with the application and then extract it. Everything should work. Getting errors? Check Xcode's console for errors. Not getting errors? Check Xcode's console, you'll see a list of all the files being extracted just like you did in terminal.  

## Wrap Up

So that's extracting a file in Cocoa. It's really easy, just not very obvious. Before I end this post, there's a few things I want to say about NSTask. NSTask is a bit of a quirky class. Whilst the goal of this post wasn't to teach you how to use NSTask, if you've never used it before, you can probably figure out how to do a decent amount of stuff with it from what I've shown you. Therefore, I feel it's my responsibility to tell you about it's quirks. Well, one of them. **You can only use an instance of NSTask once.** Yeah. Once you've run your NSTask, you need to create a new one. You can't, say, have a NSTask that unarchives a file, then change it's launch path to the ls command, and then run it again. You'll have to create two separate instances of it. There's some more quirks too, and lots of stuff you can do with NSTask besides unarchiving a file. Read Apple's [documentation][NSTaskDoc] for more information.

One more thing. NSTask doesn't exist on iOS, so to unarchive a file on iOS, you'll need to use a 3<sup>rd</sup> party framework/class. [Here's a start][letmegooglethat]. 

If you're having issues with this example, the source code for the example is available on [SimpleCode's GitHub repository][GitHubRepo]. 

[NSOpenPanelDoc]: http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/ApplicationKit/Classes/NSOpenPanel_Class/Reference/Reference.html
[NSTaskDoc]: http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSTask_Class/Reference/Reference.html
[letmegooglethat]: http://www.google.com/search?btnG=1&pws=0&q=cocoa+touch+unzip+
[GitHubRepo]: https://github.com/alexjohnj/simplecode-sample-source/tree/master/2012/01/Unarchiving%20a%20Zip%20File%20In%20Cocoa
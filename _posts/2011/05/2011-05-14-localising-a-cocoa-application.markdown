---
layout: post
title: "Localising a Cocoa Application"
description: "Localising a Cocoa application becomes incredibly important as your application becomes popular. Fortunately, Apple makes it easy to localise applications into other languages"
keywords: "localise, localize, translate, cocoa, objective-c, cocoa touch, mac os x, iOS, spanish"
---
If your Cocoa application suddenly becomes a hit overnight it’s going to become highly likely that there will be people using it that don’t speak the language you wrote it in. When this becomes the case you’ll want to translate (also known as localise) your application for as many different languages as you can. In this tutorial, we’re going to work through translating a very simple application into Spanish (don’t worry, I’ll provide the Spanish). Once you’ve followed through this tutorial, you should be able to apply the knowledge you gained to translate your own applications with relative ease!

<!--more-->

Get The Example
---------------

Before we do anything you need to download the sample application that I’m using for this tutorial. The application is a simple hello world application that is currently written in English but has some Spanish users too. OK, enough role-play.

<del>[Download The Sample Application](http://cl.ly/2H2f240b471r0Q0k3Z1C)</del>

As part of the redesign of SimpleCode, the sample application has been made available via the SimpleCode GitHub repository. Simply clone the repository (or download a compressed copy of the repository) and navigate to the sample application (2011/05/Localising A Cocoa Application/LocaliseMe(Unlocalised)!). 

[SimpleCode GitHub repository](https://github.com/alexjohnj/simplecode-sample-source)

XIB Localisation
----------------

Localising your XIB file is a Easy-To-Understand/Can-Quickly-Turn-Nasty process. It’s a simple idea. A copy of your XIB file is created. You then translate that copy into your chosen language (in this case Spanish). Then, when your application launches, Mac OS X intelligently knows which XIB file to load based on the systems default language. If the application isn’t available in that language then OS X tries the next language in line (you can see this line by looking at the list of languages in the Language and Text part of System Preferences) until it finally reaches a language that is supported by the application. The Can-Quickly-Turn-Nasty part of XIB localisation is that once you create a copy of your existing application, the copy isn’t kept in sync with the original. So say you go ahead and completely re-design the UI of the application. You will have to do this twice (or more), once for the original and then multiple times for each copy of the original. Likewise, any bindings or connections you make in the original must be made in the copy too. Despite this problem, XIB localisation is still crazy fast and efficient compared to some other ways of localising applications.

The Example (In More Detail)
----------------------------

As I said, we’re going to localise the sample application I provided into Spanish. The first thing, therefore, that you want to do is open the sample application and see what it does. When you build and run it, you should see some thing like this:

![image](/images/posts/2011/05/localisingACocoaApplication/localiseme_main_window.png?w=139&h=194)

If you click on the button which says Push Me! you should see this:

![image](/images/posts/2011/05/localisingACocoaApplication/localiseme_panel_view.png?w=437&h=163)

Told you it was basic. It will soon become apparent though that localising this application presents a challenge. The panel’s content that appears when the button is pressed is controlled by code, not by a view. How do we localise code? All will be revealed shortly. For now lets focus on localising the main window.

The Tutorial
------------

The first thing you need to do is select the MainMenu.xib file and open up the file inspector (CMD + OPT + 1). Amongst the plethora of information you’ll be presented with you’ll see a (badly localised for us Brits) tab called Localization. Expanding the tab will reveal one entry in the table: English. Click the + button and, from the list, choose Spanish. You should notice that you now have two XIB files.

If you don’t see them, click on the small disclosure triangle next to MainMenu.xib. The two MainMenu.xib’s have either English or Spanish after their names. Open up the Spanish XIB and you’ll find an exact copy of the English MainMenu.xib. Edit the Spanish XIB file to look like this:

![image](/images/posts/2011/05/localisingACocoaApplication/localised_xib_file.png?w=195&h=248)

In a full-scale application, you’ll also need to translate the menu bar items but it isn’t necessary for this application.

Testing 
-------

To test the application, open up System Preferences & change your default language to Spanish (Español). Then, build and run your application and you’ll find that the UI is in Spanish. Quit and change your system language back to English (or to English). Run the application again, you’ll find that the UI loads in English! If you need to, change your system language back to your usual language now.

String Localisation
-------------------

As I mentioned before, the panel that appears when the button is clicked isn’t translated since it’s content is controlled by code. So how do we translate this (and any other text controlled by code)? We use a string table. A string table is simply a .strings file that contains a set of Key Value Pairs. We have a Key, something easy to remember like “Message”  and then a value assigned to the key, like “Hello World”. We will then create a string table for each language with the same keys but different values. We’ll then edit the code of the application so we load a key instead of a string. Then, based on the default language of the system, the correct value is loaded as a string when that key is called. All will become clear when you have a go at it.

String Tables
-------------

Open up the new file dialogue for Xcode (⌘+N) and, under Mac OS X, choose resource and then Strings File.

![image](/images/posts/2011/05/localisingACocoaApplication/creating_string_table.png?w=600&h=375)

Click next and then name the string file Localizable (the .strings is automatically appended). Now, open the .strings file and edit it to look like this:

	"Panel" = "Panel";

	"Message" = "Hello World";

	"OK" = "OK";

Note the semi-colons. They **are** necessary. Now open the file inspector for the strings file and create a new localisation in Spanish. Edit the Spanish .strings file to look like this:

	"Panel" = "Tablero";

	"Message" = "¡Hola Mundo!";

	"OK" = "¡Bueno!";

The Final step now is to edit our AppController.m file to implement the new string table. We’re going to make use of a method called `NSLocalizedString(NSString *key, NSString *comment)`. This method takes two arguments and return a NSString. The arguments are our key and a comment. The key is simply the key we created earlier in the string table. The comment is, as the name implies, a comment. It is ignored by the compiler and is there to make the code easier to read for the translator. The method returns the NSString that correlates to the key that is passed as a parameter based on the system language. Open up AppController.m and edit the pushMe method to look like this:

{% highlight objc %}
- (IBAction)pushMe:(id)sender{
	NSRunAlertPanel(NSLocalizedString(@"Panel", @"Panel Title"),  
					NSLocalizedString(@"Message", @"Hello World"), 
					NSLocalizedString(@"OK", @"OK"), 
					nil, 
					nil); 
}
{% endhighlight %}
Now, change your language to Spanish, build and run the application, click the button and the panel is now in Spanish! Change the language back to English and run the application and the panel is in English. Cool!

Wrap Up
-------

As you can (hopefully) see, localising an application is a simple process and something that is well worth investing your time in as it will massively improve the user experience for your users. Now, here’s a small challenge. Translate one of your own applications into a language of your choice. Translating something far more complex than this application will certainly help improve the speed at which you can localise an application in the future. If you don’t have an application to translate, find an open source one and translate that!

Follow the author of this post, [@alexjohnj](http://twitter.com/alexjohnj).
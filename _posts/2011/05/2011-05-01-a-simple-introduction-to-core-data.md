---
layout: post
title: "A Simple Introduction to Core Data"
description: "Core Data is a brilliant feature of Cocoa that makes managing persistent data easy. This post is a simple introduction to using the Core Data framework" 
keywords: "core data, cocoa, cocoa touch, objective-c, programming, simple"
excerpt: "Core data is _the_ feature of Cocoa that makes it the best tool for developing applications for the macintosh. It’s what makes Cocoa a better choice for developing full, feature rich applications than Java or Ruby (not that they’re bad languages) for the mac. The simple reason for this is it allows you to develop amazingly complicated applications in precisely **0** lines of code. Even then, you can add in your own code to make brilliantly complicated applications in far less code and time than it would take by writing them without core data. Core data is awesome. There’s no other word for it."
---

*Having problems with this tutorial? The source code for the example in this post is available [here](https://github.com/alexjohnj/simplecode-sample-source/tree/master/2011/05/A%20Simple%20Introduction%20to%20Core%20Data)*


Core data is _the_ feature of Cocoa that makes it the best tool for developing applications for the macintosh. It’s what makes Cocoa a better choice for developing full, feature rich applications than Java or Ruby (not that they’re bad languages) for the mac. The simple reason for this is it allows you to develop amazingly complicated applications in precisely **0** lines of code. Even then, you can add in your own code to make brilliantly complicated applications in far less code and time than it would take by writing them without core data. Core data is awesome. There’s no other word for it.

<!--more-->

This tutorial is going to walk you through creating a useful, real world application in core data. We’re going to create a book manager, that allows you to keep a record of all the books you own. It _should_ end up looking something like this:

![The application we're going to make.]({{ site.baseurl }}/images/posts/2011/05/aSimpleCoreDataIntroduction/screen-shot-2011-05-01-at-17-18-28.png)

Horrible user interface aside it will have the following features:

- Sorting of tables & columns.
- Ratings for Books
- Automatic saving of data.

All this in 0 lines of code. Seriously.

The Guide
---------

### Decisions ###

When making a core data application you have a choice. You can make a standard Cocoa application similar to a utility application or you can make a document based application, like TextEdit. There are a few differences. In a document based application you can have multiple instances of your window open. Document based applications also include support for undo out of the box. In addition, they allow your user to save their data in a file in a location of their choice, out of the box. When making an application with core data, consider whether your user needs these extra features and choose an appropriate cocoa project (keep in mind all these features can be added to a non document based application fairly easily). For the purpose of this application we will be using a non document based cocoa application however this can be made into a document based application with just a few adjustments.

### Creating The App ###

To begin, launch Xcode and create a new cocoa application. In the next window, give the application a name and check the box use core data. Also make sure that the box Create Document-Based Application is unchecked. The first thing we need to do is create the data model for our application. Core data strictly follows the MVC design pattern so our model will contain no information about our user interface (in fact it can’t). Open the *YourApplicationName.xcdatamodeld* and create an entity called Book (it must start with a capital letter). An entity is similar to an Object in that it will have instance variables (attributes). We need to create several attributes for our book managing application. These are:

|  Attribute  |      Type     |  
| :---------: | :-----------: |  
|   author    |     String    |  
|    isbn     |     String    |  
|   picture   | Transformable |  
|   rating    |   Integer 16  |  
| releaseDate |      Date     |  
|    title    |     String    |  

Go ahead and add these attributes. Once we’ve created the entity, we need to build the user interface for the application. Open up *MainMenu.xib* and craft together a UI similar to the one shown at the start of the tutorial. For the UI you will need:

- x2 Labels. One saying release date and the other saying rating
- x1 Table With three columns labeled Title, author & isbn
- x2 Buttons labeled + & – (or add and remove)
- x1 Date picker
- x1 Image well
- x1 Level Indicator. In the attributes inspector, change the style to rating and check the enabled box. Also, set the maximum value to 5.

Once the UI has been created we need to set up an ArrayController. Drag an ArrayController out of the objects library. Open the attributes inspector and change the object controller mode to Entity. Then, for the entity name, enter Book. Finally, check the box prepares content. It should look like the below image:

![Preparing an instance of NSArrayController.]({{ site.baseurl }}/images/posts/2011/05/aSimpleCoreDataIntroduction/setting-nsarraycontroller-entity.png)

Now, open the bindings inspector for the array controller and bind the managed object context to the App Delegate. Furthermore, set the model key path to managedObjectContext (For more information on bindings see this post). The bindings inspector for the array controller should look like this:

![Binding a Core Data managed object context to an array controller.]({{ site.baseurl }}/images/posts/2011/05/aSimpleCoreDataIntroduction/nsarraycontroller-bindings.png)

Now that we’ve set up the array controller, it’s time to bind the user interface. This is incredibly simple to do. First we need to bind the first column of the table to the title attribute. Select the first column and open up the bindings inspector. Bind the value of the first column to the Array Controller and set the model key path to title as below:

![Binding the first comlumn of a table to an instance of NSArrayController.]({{ site.baseurl }}/images/posts/2011/05/aSimpleCoreDataIntroduction/binding-value-to-array-controller.png)

Repeat for the following entities:

|    UI Control    | Modal Key Path |  Controller Key | Bind To |  
| :--------------: | :------------: | :-------------: | :-----: |  
| 2nd Table Column |     author     | arrangedObjects |  value  |  
| 3rd Table Column |      isbn      | arrangedObjects |  value  |  
|    Image Well    |     picture    |    selection    |  value* |  
| Level Indicator  |     rating     |    selection    |  value  |  
|   Date Picker    |   releaseDate  |    selection    |  value  |  

*Be sure to check the box "conditionally sets editable".

Next we need to connect the buttons so that they add and remove entries. Control drag from the add button to the Array Controller and choose the option add:. Likewise, control drag from the remove button and choose remove:. Furthermore, whilst having the remove button selected, open the bindings inspector and bind the enabled option to the array controller. Also, set the controller key to canRemove, as below:

![Binding the remove button so that it is only enabled when a book is selected.]({{ site.baseurl }}/images/posts/2011/05/aSimpleCoreDataIntroduction/binding-remove-enabled-to-array-controller.png)

Now, build and run the application. You’ll find that everything works, you can add & remove entries, drag and drop images to them & rate books. Furthermore, if you quit and reload the application, you’ll find that the data is saved and reloaded automatically. Pretty awesome! Despite the fact that you’ve written absolutely no code, you have a fully functioning cocoa app!

Wrap Up
-------

As you can see, core data is an incredibly simple, easy to use and powerful feature of Cocoa that makes buildings applications easier and faster. In next to no time, you should be able to start building very complex applications with almost zero effort. Hopefully this tutorial has been helpful to you. If you continue to experiment with core data, you will soon be able to build very powerful applications easily.

Follow the author of this post, [@alexjohnj](http://twitter.com/alexjohnj).
---
layout: post
title: "WTF is a #Pragma Mark?"
description: "Outlines what a #pragma mark is and how to use them in Xcode projects"
keywords: "xcode, IDE, pragma mark, mark, pragma"
excerpt: "When browsing through another developers source code you may have come across something in the source code that looks like this: `#pragma mark someText`. After seeing these you may have been somewhat confused as to what they do in the application. To be honest, they don’t do anything in the application. Rather, pragma marks are there as another way to help organise your source code and make it easier to read. In Xcode, pragma marks are used as a way to manage the list of methods (the class outline) that can be bought up to faster navigate your source code. This list:"
---

When browsing through another developers source code you may have come across something in the source code that looks like this: `#pragma mark someText`. After seeing these you may have been somewhat confused as to what they do in the application. To be honest, they don’t do anything in the application. Rather, pragma marks are there as another way to help organise your source code and make it easier to read. In Xcode, pragma marks are used as a way to manage the list of methods (the class outline) that can be bought up to faster navigate your source code. This list:

<!--more-->

![A list of methods in Xcode.](/images/posts/2011/05/wtfIsAPragmaMark/method_list_xcode.png)

As you can tell from the picture, that list of methods in one of my class files is a mess to read with no organisation to it what so ever. Using pragma marks though, we can clean up that list and make it look like this:

![A list of methods in Xcode organised using pragma marks.](/images/posts/2011/05/wtfIsAPragmaMark/method_list_xcode_pragmamised.png)

It’s now a lot easier to quickly skim through the list of methods and find the one I need. So how do you implement this into your project? It’s really easy. Before a set of methods you want to group simply enter the code `#pragma mark markTitle` to create a new group of methods (that’s outside of any method bodies but inside your @implementation section). All the methods after this pragma mark and up to another pragma mark will be put into a single group. To create another group after this, just put a pragma mark somewhere else after the first pragma mark. For example, to create a group called Initialisation Methods I’d simply type `#pragma mark Initialisation Methods` before any of the methods I want in this group.

There is one other type of pragma mark that looks like this: `#pragma mark -`  Note that there is no space after the hyphen. This creates a divisor in the list of methods like this:

![A divisor in a method list.](/images/posts/2011/05/wtfIsAPragmaMark/method_list_xcode_pragma_divisor.png)

You can actually go ahead and combine this with a named pragma mark to create a list of methods that looks like this:

![A divisor in a method list after a title in a method list.](/images/posts/2011/05/wtfIsAPragmaMark/method_list_xcode_pragma_divisor_name.png)

To create this effect simply enter a pragma mark like this: `#pragma mark markName #pragma mark -` Again, there is no space after the hyphen. If you wish to place the divisor before the group title, just do that code in the opposite order, so `#pragma mark - #pragma markName`. As of Xcode 4, a shorthand version of this exists which looks like this: `#pragma mark - markName`. This creates a divisor and a title. In large projects, pragma marks can become an absolute necessity but in small projects they are of little importance. Despite this, it’s a good idea to use them in small projects in order to get into the habit of using them in the future.

Follow the author of this post, [@alexjohnj](http://twitter.com/alexjohnj).
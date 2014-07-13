---
layout: post
title: "Getting Started With Markdown"
categories: Writing
description: "Outlines how to get started with Markdown, describing the syntax, applications & uses"
keywords: "markdown, multimarkdown, mou, dingus, dillinger, learn markdown, markup, text to html"
excerpt: "Markdown is a (web) writer's best friend. Markdown is an incredibly simple, lightweight markdown language and a lightweight perl script which takes plaintext files using the special Markdown syntax and converts them into HTML files, ready for publication on the web. Better yet, the syntax of Markdown is very easy to learn and simple resulting in “source” files that will be readable in the plaintext format they are written in, even if they haven't been converted to HTML. Created by [John Gruber](http://daringfireball.net/), he designed Markdown's syntax to be incredibly easy to read and for the Markdown project to be used by web writers who could, essentially, publish the plaintext markdown files “as is” and the content would still be readable. It's an incredibly useful tool for any writer and it's something which all writers should take some time to learn, largely because it takes just a few minutes to do so (well, maybe a little more)."
---

Markdown is a (web) writer's best friend. Markdown is an incredibly simple, lightweight markdown language and a lightweight perl script which takes plaintext files using the special Markdown syntax and converts them into HTML files, ready for publication on the web. Better yet, the syntax of Markdown is very easy to learn and simple resulting in “source” files that will be readable in the plaintext format they are written in, even if they haven't been converted to HTML. Created by [John Gruber](http://daringfireball.net/), he designed Markdown's syntax to be incredibly easy to read and for the Markdown project to be used by web writers who could, essentially, publish the plaintext markdown files “as is” and the content would still be readable. It's an incredibly useful tool for any writer and it's something which all writers should take some time to learn, largely because it takes just a few minutes to do so (well, maybe a little more). 

<!--more-->

## The Syntax

The syntax of Markdown is incredibly easy to learn. It'll take you 10 minutes at most. I'm going to teach you the syntax of Markdown before explaining how to convert Markdown files to HTML so that you can get a taste of Markdown and see if you like it. If you don't like it, I won't have wasted your time explaining whether to use the perl script, a web application or a native application to work with your markdown content. If you want, you can copy and paste the markdown into a web application called [Dingus](http://daringfireball.net/projects/markdown/dingus) which will allow you to sample the markdown output in your browser without having to install the script. In each example, the markdown syntax is given first, followed by the resulting HTML output. 

### Headers

	# Header 1
	## Header 2
	### Header 3

All translate to:

{% highlight html %}
<h1>Header 1</h1>
<h2>Header 2</h2>
<h3>Header 3</h3>
{% endhighlight %}

This:

	# Header 1 #
	## Header 2 ##
	### Header 3 ###

also translates to the same HTML code. It is more common to see the first style for declaring headers than the second style but they both do the same thing.

For the `h1` and `h2` tags, there's also a special syntax that can be used: 

	Header 1
	========
	Header 2
	--------

This produces the same result but the raw markdown looks even more readable since the headers appear to be underlined.

### Paragraphs

	A paragraph

	Another paragraph, separated by a new line. 

Produces:

{% highlight html %}
<p>A paragraph</p>
<p>Another paragraph, separated by a new line</p>
{% endhighlight %}

Paragraphs are super simple to do. Separate two chunks of text by a blank line and you've got yourself a paragraph. 

### Styling Text

	*Italics*
	_Also italics_
	**Bold**
	__Also Bold__

Pretty simple. Generally, people use `_..._` for italics and `**...**` for bold text. 

### Lists

Again, the syntax is incredibly logical and simple: 

	- A list.
	- Another entry in a list. 
	- And the list goes on. 

Produces:

{% highlight html %}
<ul>
<li> A list.</li>
<li> Another entry in a list.</li>
<li> And the list goes one.</li>
</ul>
{% endhighlight %}
	
Instead of using -, we could use + or * to denote a bullet point. For ordered lists you can use:

	1. Number 1
	2. Number 2
	
Which produces:

{% highlight html %}
<ol>
<li> Number 1</li>
<li> Number 2</li>
</ol>
{% endhighlight %}

### Horizontal Rules/Separators

Want to insert a horizontal separator? No problem, just do one of the following:

	***
	---
	___

Either of those produces:
	
{% highlight html %}
<hr />
{% endhighlight %}

Just put three or more asterisks, hyphens or underscores in a row on a new line and you've got yourself a line. 

### Quotations (Blockquotes)

The syntax for blockquotes is similar to that of email blockquotes.

	> A blockquote.
	> 
	> Another line of blockquote separated by a blank line.

	>A new blockquote.
	Content in the same blockquote.

	> # A header in a blockquote.
	>
	> **Bold text** in a quote.

	> Nested
	> 
	>> Quotes

Produces: 

{% highlight html %}
<blockquote>
  <p>A blockquote.</p>

<p>Another line of blockquote separated by a blank line.</p>

<p>A new blockquote.
Content in the same blockquote.</p>

<h1>A header in a blockquote.</h1>

<p><strong>Bold text</strong> in a quote.</p>

<p>Nested</p>

<blockquote>
  <p>Quotes</p>
</blockquote>
</blockquote>
{% endhighlight %}

You can include most other Markdown elements (italics, bold, code e.t.c) in blockquotes. 

## Code

Embedding a line of code with markdown is pretty simple:

	`printf("A line of code.\n");`

Produces:

{% highlight html %}
<code>printf("A line of code.\n");</code>
{% endhighlight %}

Indenting a block of code with a tab will produce a multiline section of code that preserves all tab formatting:

		#import stdio.h
		int main(int argc, char *argv[]){
			printf("Hello World");
		}

Becomes:

{% highlight html %}
<pre><code>    #import stdio.h
    int main(int argc, char *argv[]){
        printf("Hello World");
    }</code></pre>
{% endhighlight %}    

## Links

There's a couple of methods for including links in Markdown. 

	An [inline link](http://example.com)

Produces:

{% highlight html %}
<p>An <a href="http://example.com">inline link</a></p>
{% endhighlight %}

Alternatively, you can use reference links:

	A [reference][referenceLinkId] link

Then, later in the document:

	[referenceLinkId]: http://example.com

This will produce the same HTML code as before but makes the Markdown file considerably more readable. There's also lazy links:

	<http://iamlazy.com>


Produces:

{% highlight html %}
<p><a href="http://iamlazy.com">http://iamlazy.com</a></p>
{% endhighlight %}

## Images

Obviously you can't include images in plaintext files but Markdown includes a basic syntax for linking to images. 

	![altTitle](http://linkToImage)

Produces:
	
{% highlight html %}
<p><img src="http://linkToImage" alt="altTitle" title="" /></p>
{% endhighlight %}

To include a title just do:

	![altTitle](http://linkToImage "Image Title")

Which produces:

{% highlight html %}
<p><img src="http://linkToImage" alt="altTitle" title="Image Title" /></p>
{% endhighlight %}

The Markdown syntax for images is pretty limiting. You can't, for example, set the height and width of images. There's a nifty work around for this though.

## When You Need To Include Raw HTML

There may be a point when you need to include raw HTML in your Markdown document (say for altering the dimensions of images). It's easy to do:

	# Random Markdown text. 

	<img src="myImage/image.png" height="250px" width="180px" />

	# Some more Markdown text

This, unsurprisingly, produces: 

{% highlight html %}
<h1>Random Markdown text.</h1>
<img src="myImage/image.png" height="250px" width="180px" />
<h1>Some more Markdown text</h2>
{% endhighlight %}

You can include any HTML tags within your Markdown document, just remember that you can't use markdown syntax within the HTML tags. 

---

And that's the Markdown syntax in a nutshell. Simple, clean & easy to use. Like it? Read on and find out the best way to work with Markdown on your computer, don't like it? That's a shame. 

## Installing Markdown

In order to convert any markdown you write to HTML you need to do one of three things. Either a) install the markdown perl script b) Download/Buy a dedicated markdown editor c) Use an online web app. Each method has its pros and cons.  

### Web Applications

The selection of web apps available is somewhat limited. There's the previously mentioned [*Dingus*](http://daringfireball.net/projects/markdown/dingus) created by John Gruber. It will allow you to preview the output of your markdown and copy and paste the HTML code and that's about it. You *could* write out your markdown document in Dingus but you won't be able to save it so Dingus is more suited to experimenting with Markdown. An alternative web application is [*Dillinger*](http://dillinger.io/). Dillinger is a beautiful HTML5 web application which does support (offline) saving and features a much nicer user interface than Dingus. It allows you to export the HTML or the markdown to your computer and also integrates with GitHub. It doesn't have anywhere near as many features as a native application but if you *must* use a web app, Dillinger is probably your best bet. 

<img src="{{ site.baseurl }}/images/posts/2011/12/gettingStartedWithMarkdown/dingusScreenShot.png" width="640px" alt="Dingus" /> Dingus

<img src="{{ site.baseurl }}/images/posts/2011/12/gettingStartedWithMarkdown/dillingerScreenshot.png" width="640px" alt="Dillinger" /> Dillinger

### Native Applications

Native applications are generally the way to go when it comes to editing markdown content. They're more convenient than the perl script and offer many more features than web apps. There's also quite a selection of native applications for Windows & Mac OS X, most of which are free. 

#### Any Plaintext Editor

Since all a markdown file is, is a plaintext file using a special syntax, any plaintext editor will work with markdown files. Combining a plaintext editor with the markdown script can be quite an effective workflow but you won't get some of the benefits you get from using a dedicated markdown editor. Some of the more expensive text editors such as [Chocolat](http://chocolatapp.com/) include “bundles” which add some extra functionality for editing markdown files such as keyboard shortcuts for inserting italics or links. When saving a markdown file using a plaintext editor, the extension can be left as anything you want or nothing at all. Most commonly, markdown files will be given no extension, *.md*, *.markdown*, or *.txt*. 

#### [Mou](http://mouapp.com/) (Mac OS X | Donationware)

Mou is a relative newcomer to the world of markdown editors but it's already absolutely fantastic. Mou is currently in beta but it boasts an impressive selection of features and is my favourite markdown editor by far. Its brilliance lies in its simplicity. In full screen mode, the only thing visible is a word counter allowing you to focus on your writing. The application includes a split screen live preview, so you can see how the content will look on your website as you write and the application includes a collection of handy “actions” which essentially means I didn't have to teach you all of that syntax, because Mou's actions will handle the syntax for you. Options for exporting your markdown text in Mou is somewhat limited however. Mou allows you to export your document as a HTML file or, alternatively, you can copy the HTML into a HTML file. Mou is an exceptional application nonetheless. Whilst it's currently free, the developer seems to be planning to make the stable version shareware, which isn't a bad thing, [he deserves some credit](http://mouapp.com/donate/) for this great application. 

<img src="{{ site.baseurl }}/images/posts/2011/12/gettingStartedWithMarkdown/mouScreenShot.png" width="640px" alt="Mou"/> [Mou](http://mouapp.com/)

#### [Byword](http://bywordapp.com/) (Mac OS X | $9.99/£6.99)

Byword is a minimalistic text editor for Mac OS X that integrates nicely with markdown. Whilst the application is also a rich text editor, it works very nicely with Markdown. The minimalist nature of the application allows you to concentrate on your writing and, again, the application includes a set of actions so you don't need to know the markdown syntax in that much detail. Unlike most applications, Byword doesn't include a live preview of your markdown document, instead you have to click a button to see a preview. This isn't necessarily a bad thing, it helps reduce distractions. Byword allows you to export your markdown files in a variety of formats including HTML, PDF, Word .doc and LaTeX. Alternatively, you can get Byword to copy the HTML output to your clipboard, where you can then paste it into a HTML file. Byword is a very good writing application and markdown editor and, whilst it isn't cheap (or expensive), it's definitely worth the money if you're after a minimalistic editor. 

<img src="{{ site.baseurl }}/images/posts/2011/12/gettingStartedWithMarkdown/bywordScreenshot.png" width="640px" alt="Byword"/> [Byword](http://bywordapp.com/)

#### [MarkdownPad](http://markdownpad.com/) (Windows | Free)

MarkdownPad is basically Mou for Windows. MarkdownPad includes a split pane live preview of your markdown files, numerous actions to simplify your writing and a HTML export feature. It also includes a distraction free mode and is customisable with custom themes and custom CSS for your previews. It's very powerful but also very simple and the best part is it's free! 

<image src="{{ site.baseurl }}/images/posts/2011/12/gettingStartedWithMarkdown/markdownPad.PNG" width="640px" alt="MarkdownPad"/> [MarkdownPad](http://markdownpad.com/)

#### [ReText](http://sourceforge.net/p/retext/home/ReText/) (Linux | Free)

I'll be honest, I haven't actually tried ReText. As someone who's linux system is a barebones Arch Linux install, I can't really test it. Looking at the project's page, ReText appears to be very good however. It, again, has a split pane live preview with customisable CSS and also offers the ability to export your markdown files in HTML, PDF and ODT file formats. One thing it has which other markdown editors lack is the ability to integrate with Google Docs which seems quite useful for collaborative work.

[ReText](http://sourceforge.net/p/retext/home/ReText/)

### Using the Perl Script

If none of those applications are cutting it for you, maybe you'd like to go down the “traditional” Markdown route of using a plaintext editor and the Markdown perl script to fulfil your Markdown needs. The perl script isn't too complicated to use, it's going to require access to the terminal/command line and you're going to need to have perl installed too. Then you can download the script from [here](http://daringfireball.net/projects/downloads/Markdown_1.0.1.zip). Once downloaded, open up a terminal session and cd into the directory you just downloaded (e.g `cd UserName/Downloads/Markdown_1-1.0.1`).  For ease of use, you may wish to copy the markdown file you want to convert to the directory too. Then, in terminal run:

> `perl Markdown.pl markdownfile.md`

Markdown will then process the markdown file and output the resulting HTML to your terminal prompt. You can then copy and paste the output into a HTML file and you're good to go. Of course, there's a far more convenient method of obtaining the output than copying it. Still in your terminal session, enter the following:

> `perl Markdown.pl markdownfile.md > outputFileName.html`

Now, you don't get any HTML output in your terminal session. Instead, you get a new HTML file created in your current directory (you can type `ls` to check) with all the content of your markdown file in it. This is much easier than copy and pasting the outputted HTML from your terminal session. Just remember that the outputted HTML file *doesn't* include the basic `<html>` layout and so isn't a valid HTML document. 

A small note, by default, Markdown outputs HTML tags with empty elements in the XHTML format (`<hr />`). To change this to the HTML format (`<hr>`), enter the following when running the perl script:

> `perl Markdown.pl --html4tags markdownfile.md > outputFileName.html`

The `--html4tags` argument will tell Markdown to produce HTML tags with empty elements instead of XHTML tags. 

Conclusion
-------------

And so that's an introduction to Markdown, the amazing writer's tool from John Gruber. I know this post has been *very* long but I wanted to make it as information rich as possible (even then, I've had to cut out some sections). By adopting Markdown, your writing should improve substantially* since it saves you so much time and effort by not letting you mess around with the formatting of your post, allowing you to focus just on your writing. 

*Not a guarantee

Follow the author of this post, [@alexjohnj](http://twitter.com/alexjohnj).
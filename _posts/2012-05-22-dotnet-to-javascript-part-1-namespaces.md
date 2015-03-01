---
layout: post
title:  "Dotnet to JavaScript part 1 namespaces"
excerpt: "The part 1 of an articles series on JavaScript good practices, this one talk about how retrieve your lovely C# namespaces in the JavaScript world."
date:   2012-05-22 22:18:44
categories: post
tags : [JavaScript]
lang : [en]
image:
  feature: abstract-11.jpg
---

The part 1 of an articles series on JavaScript good practices, this one talk about how retrieve your lovely C# namespaces in the JavaScript world.

##Introduction
###Personal background on JavaScript

The first time I see JavaScript 10 years ago, I felt that it was some kind of gadget... When I first used it in real world application 5 years ago and during a few years, I had really bad headaches. Debugging was crazy, some JavaScript on header of the page, on files, everywhere in the content of page and the differences between browser was terrible. I thought this language simply can’t create well developed applications.

For me this language couldn't exist like this longer and it was obvious that JavaScript (with no changes since 1999!) will disappear soon, thanks to the beautiful WPF/Silverlight and Flash/Flex. I made the choice to avoid this language in most cases, wait and learn the "new wave" of RIA development.

But as we can see today, the plug-in approach is dying slowly but surely and it is no more a good idea for internet website, thank to Apple that don't allow plug-in on the iphone/ipad browser for the best and the worst.

Yes Silverlight is a wonderful technology, the one every DotNet developers wait for and want be the best and only one technology to create RIA with DotNet on all platforms. We all want Silverlight to - fully - succeed, but the developers don't make the technologies succeed, business do.

JavaScript is now evolving quickly with the html5 standard massively developed and supported by all the biggest software company (Microsoft, Apple, Google and others) and I think every DotNet developer should have a look to these technologies, probably the best future technologies for web development but may be for full portable application development too.

So let's take a look.

###What about JavaScript ?

JavaScript was created quickly (who say "draft" ?) and integrated in the browser at the beginning of internet. This "revolution" introduced by the JavaScript language was to enable interactivity instead of static web pages and create some years later the "Web 2.0". 

Now let's go from heaven to the hell... What is the worse from JavaScript ? After a quick look we can see this:

- No namespaces
- Functional programming and no class: everything is a function or a variable.
- Strangely "typed"
- Strange "this"
- Support in the different browsers
- Some curious "functionalities"

In fact JavaScript is now the only language that can be used everywhere on web your application:

- In your browser of course and it's the only plug-in less solution
- In your database with nosql database like MongoDB or CouchDB
- In your web server like Node.js and Vert.x
- In touch applications (Windows 8, ipad/iphone)
- But also on various platforms like TV, OS (WebOS, JoliCloud, ...) or multiple smartphone with PhoneGap

JavaScript has its drawbacks but it is not so horrible, it's just "different" and has a really big flexibility that allow cool things as really bad things.

###No namespace ? Really ?

One of the biggest problem of the missing of namespace is that when you declare a function it's global and everyone can use it and erase it, even not intentionally, just by choosing the same name.

Not a problem on a little website with 10 function but in really complex code with hundreds of functions it can be horrible to develop and maintain. This is one of the biggest reason why people hate JavaScript.

Don't worry you can, with good practices like the "module pattern", organize your code with "namespaces". 

##The Module Pattern

Let's see how to create the "Company.Project.ModuleA" namespace step by step.

###Isolated code

The first really important thing is to isolate each functionality.

To do this we can create a scope with "(" scope ")" that encapsulate an anonymous function.

```javascript
(function () {
    //Your private code written
})
```

Like this all things you create in this function is isolated and inaccessible from outside of this block.
It seems good but the problem is that this code is defined but not executed so let's simply call it with a "()".

```javascript
(function () {
    //Your private code defined (executed)
})()
```

###Root namespace

Now we need to provide functionality accessible from outside, to achieve this you have to add your functionalities to the "root" of JavaScript namespace. The root namespace is "window" in the browser. Let's add a function:

```javascript
(function () {
    window.testFunction = function(){
        //Your function code
    };
})()
//You can call your function outside
testFunction();
```

There is a problem in this code for framework/toolkit use: window is the root namespace in the browser but not on windows 8, node.js or others.

To fix that, you have to choose a conventional name like "global" and use it on all your module's scopes like this:

```javascript
(function (global) {
    global.testFunction = function(){
        //Your function code
    };
})(this) //this contains the root namespace
```

Like this you can customize the root element that construct your scope.

###The magic trick
Now the bases of the module pattern, the namespace creation:

```javascript
(function (global) {
    //This line get an existing namespace or create a new (with an empty object)
    global.MyNamespace = global.MyNamespace || {};
    //Now you can add functions to your namespace
    global.MyNamespace.testFunction = function(){
        //Your function code
    };
})(this)
//You can call your function outside from your namespace
MyNamespace.testFunction();
```

It seems special, the result is that you don't erase a potentially existing namespace (created in another JavaScrip file). 
If you want to create a multiple depth namespace, you can proceed like this:

```javascript
(function (global) {
    global.Company = global.Anthyme || {};
    global.Company.Project = global.Company.Project || {};
    global.Company.Project.ModuleA = global.Company.Project.ModuleA || {};
    var ModuleA = global.Company.Project.ModuleA;
    //Now you can add functions to your namespace
    ModuleA.testFunction = function(){
        //Your function code
    };
})(this)
//Shortcut to your module (like an "using")
var ModuleA = Company.Project.ModuleA;
//You can call your function outside from your namespace
ModuleA.testFunction();
```

Oh it is too verbose ! Yes a little, you can improve it a little like this:

```javascript
(function (global) {
    var Company = global.Company = global.Company || {};
    var Project = Company.Project = Company.Project || {};
    var ModuleA = Project.ChatService = ModuleA.ChatService || {};
    //Now you can add functions to your namespace
    ModuleA.testFunction = function(){
        //Your function code
    };
})(this)
```

The module pattern end here. There is a lot of different ways to implement and improve it.

##Go Further

###Improve namespace creation
Here is an example of code written in 5 minutes that can create your namespace in one line:

```javascript
(function (global, undefined) {
    global.namespace = function (namespace) {
        var namespaces = namespace.split(".");
        var current = global;
        for (var i = 0; i < namespaces.length; i++) {
            current[namespaces[i]] = current[namespaces[i]] || {};
            current = current[namespaces[i]];
        }
        return current;
    };
})(this)
```

Now you can create your namespace like this:

```javascript
(function (global, undefined) {
    //Create the namespace
    var ModuleA = namespace("Company.Project.ModuleA");
    //Now you can add functions to your namespace
    ModuleA.testFunction = function(){
        //Your function code
    };
})(this)
//Shortcut to your module (like an "using")
var ModuleA = Company.Project.ModuleA;
//You can call your function outside from your namespace
ModuleA.testFunction();
```

###References and dependencies

The last problem is if you don't reference a library in your page and use it in another library you will raise an error.

You can start creating an API to "import" your namespaces with a "require" function like this:

```javascript
(function (global, undefined) {
    global.require = function (namespace) {
        var namespaces = namespace.split(".");
        var current = global;
        for (var i = 0; i < namespaces.length; i++) {
            current = current[namespaces[i]];
            if (!current) {
                throw "Error: namespace " + namespace + " not loaded";
            }
        }
        return current;
    };
})(this)
```

And use it this way:

```javascript
(function (global, undefined) {
    var ModuleA = require("Company.Project.ModuleA");
    ModuleA.testFunction();
})(this)
```

Now you have a real error for debug when modules aren't loaded.
Instead of raising an error You can add loading strategy of your JavaScript files with conventions like using directories "/Scripts/Company/Project/ModuleA.js" or named files "/Scripts/Company.Project.ModuleA.js"

It's up to you, some framework use this kind of techniques like [Dojo][dojotoolkitUrl] for example. It's out of the scope of this article.

##Final words

I hope you enjoy a little more JavaScript now, especially if you are a DotNet developer.
In a future article I will speak about other patterns and OOP in JavaScript.


[dojotoolkitUrl]: http://dojotoolkit.org/
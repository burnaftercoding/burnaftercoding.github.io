---
layout: post
title:  "Dotnet to JavaScript part 2 OOP"
excerpt: "This article presents how to implement OOP with JavaScript with the prototype/closure techniques and help you avoid a few traps."
date:   2012-06-06 19:18:44
categories: post
tags : [JavaScript]
lang : [en]
image:
  feature: abstract-11.jpg
---
This article presents how to implement OOP with JavaScript with the prototype/closure techniques and help you avoid a few traps.

##Introduction

“JavaScript is an ugly scripting language created for some kind of – sub – developers and that don’t support OOP”, is a summary of what I often heard about JavaScript (or I thought).
So let’s prove this is a mistake.

###Classic OOP
For “standard developers” (I mean those who use C/C++ derived languages like C# or Java) the OOP imply a few things:

- **class**

You define classes to define the members and methods of your object.

- **this**

A way to access the current instance.

- **constructor (new)**

Your class has a (or multiples) dedicated method to construct your object with the “new” keyword.

- **public/protected/private**

Members/Methods have different authorization level to access it to separate internal code and external API clearly.

- **inheritance**

Once a class is defined you can inherit from this one to create a new one with more functionalities.

- **interface**

You can define only signatures that your class can implement.
    In fact JavaScript support almost nothing of these functionalities … Let’s see what it can do.

In fact JavaScript support almost nothing of these functionalities ... Let's see what it can do.

###JavaScript OOP ?
In JavaScript there are only a few keywords "about OOP":

- **new**

A keyword to create new object, sometime optional.

- **this**

A keyword that contains the execution context (sometime not your instance)

- **instanceof**

A way to know if an object is an instance of an "object type".

And ... nothing more in the keywords or structure of your code!
Fortunately you have also a "prototype model" API to create some kind of "class".

In fact - and more than the legacy languages - in JavaScript everything is an object or more precisely "a box where you can put everything you want in" (except number, string, boolean and undefined).
The prototype approach of JavaScript is the standard way to model your object it offer a few capacities listed before and a few more. 
It seems a little poor but it is just a different paradigm than the classical C++ way.
I say "standard way" because there is another - modern/custom - solution named "closure" made possible by the flexibility of JavaScript.

Let's start by the prototype way.

##Prototype Oriented Programming

###Functionalities
Prototype programming offer these "OOP" functionalities:

- Constructor
- Instance methods/members
- Static methods/members
- Inheritance
- An internal access to the instance

But no support to:

- Interface
- Private methods/members (in fact it's possible but not easy and readable)

Ok it's pretty basic but sufficient, there is also a nice thing with prototype: 
You can enhance a prototype everywhere in your code.
The existing objects of this prototype will benefit of these new methods automatically.
And you can add or change functionality on standard objects (like adding method on Array for example) and allow really easy meta programing.

###Sample

Now let see how to create a prototype:

```javascript
var myClass = function () {
    var privateMember = "hidden";//useless
};
MyClass.prototype.publicMethod = function() { return "hello from object"; };
MyClass.prototype.publicMember = "public";
MyClass.prototype.getMember = function () { return this.privateMember; };

MyClass.staticMethod = function () {
    return "hello from class";
};

var myObject = new myClass();

MyClass.staticMethod(); //return "hello from class"
myClass.publicMethod(); //error
myObject.staticMethod(); //error
myObject.publicMethod(); //return "hello from object"
myObject.privateMember; //undefined
myObject.publicMember; //return "public"
myObject.getMember(); //undefined
myObject instanceof myClass; // return true
```

The first function is the “constructor” and each other assigned to the MyClass.prototype are public methods/members.
Functions assigned to MyClass directly are static methods.
Private members simply do not work.

Ok, now we can see how it works but if it is flexible it is not really structured.
We can improve a little like this:

```javascript
myClass.prototype =
    {
        publicMethod: function() { return "hello from object"; },
        publicMember: "public",
        getMember: function() { return this.privateMember; }
    };
```

But in this case you do not enhance a possible existing prototype but replace it.

###Inheritance

So how the inheritance work? Let's see a sample with our previous MyClass:

```javascript
var MySubClass = function () {}; //sub constructor
MySubClass.prototype = new MyClass();
MySubClass.prototype.constructor = MySubClass;
MySubClass.prototype.subMethod = function () { return "hello from sub object"; };

var mySubObject = new mySubClass();

mySubObject.publicMethod(); //"hello from object"
mySubObject.subMethod(); //"hello from object"
mySubObject instanceof mySubClass; //true
mySubObject instanceof MyClass; //true
```

Ok so prototype is not really readable ("clean") but do the work.
Before seeing the "closure" way I have one more important thing to say ...

###Take care of "this"

The “this” keyword is not the same of the C# one. In fact “this” contains the “execution context”.
For example this code will fail:

```javascript
MyClass.prototype.alertLaterMember =
    function () {
        setTimeout(function () { alert(this.publicMember); }, 1);
    };
```

If you call the “alertLaterMember” on an object created with MyClass the “this” keyword will not contain your instance but the context that call your function so the result will be an alert with “undefined”. In this case “this” should be “window”, I’m not sure, and you certainly won’t be sure when you are using “this”, so avoid it.

The solution is to create a copy of this stored in a local variable.
You can call it “self” (like in python), “that”, “me” … Personally I prefer “me”, it’s simple, light and readable.

The solution for this case is:

```javascript
MyClass.prototype.alertLaterMember =
    function () {
        var me = this;
        setTimeout(function () { alert(me.privateMember); }, 1);
    };
```

Now let's see the closure approach.

##Closure

###Functionalities
Prototype programming offer these "OOP" functionalities:

- Constructor
- Instance methods/members
- Static methods/members
- Private methods/members
- Structured declaration
- An internal access to the instance

But no support to:

- Interface
- Inheritance (possible with a hack)

The closure pattern is some kind of "trick" that allow more but you will see that it is more readable.

###Sample

Now let see how to create a closure class:

```javascript
var MyClass = function () {
    var privateMember = "hidden";
    this.publicMethod = function () { return "hello from object"; };
    this.publicMember = "public";
    this.getMember = function() { return privateMember; };
};

MyClass.staticMethod = function () {
    return "hello from class";
};

var myObject = new MyClass();

MyClass.staticMethod(); //return "hello from class"
MyClass.publicMethod(); //error
myObject.staticMethod(); //error
myObject.publicMethod(); //return "hello from object"
myObject.privateMember; //undefined
myObject.publicMember; //return "public"
myObject.getMember(); //return "hidden"
myObject instanceof MyClass; // return true
```

This time everything happen in the constructor function and you can access to private variables or methods because the instance methods are define in the constructor. 

There is another way to write used by some developers:

```javascript
var MyClass = function () {
    var privateMember = "hidden";
    return {
        publicMethod: function () { return "hello from object"; },
        publicMember: "public",
        getMember: function () { return privateMember; }
    };
};

MyClass.staticMethod = function () {
    return "hello from class";
};

var myObject = new MyClass();

MyClass.staticMethod(); //return "hello from class"
MyClass.publicMethod(); //error
myObject.staticMethod(); //error
myObject.publicMethod(); //return "hello from object"
myObject.privateMember; //undefined
myObject.publicMember; //return "public"
myObject.getMember(); //return "hidden"
myObject instanceof MyClass; // return false
```

It creates an anonymous object that contains the public methods/members. Personally I do not like it because it lose the instanceof functionality.

###Inheritance

So how the inheritance is possible in closure? There are a lot of possibilities, the simplest is this one:

```javascript
var MySubClass = function () {
    var me = new MyClass();

    me.subMethod = function () { return "hello from sub object"; };

    return me;
};   //sub constructor

var mySubObject = new MySubClass();

mySubObject.publicMethod(); //"hello from object"
mySubObject.subMethod(); //"hello from object"
mySubObject instanceof MySubClass; //false
mySubObject instanceof MyClass; //true
```

In fact you are creating an object from the main class and adding functionality on it but the problem is that it's not typed on your sub class but only on your root class.

###"this" again

The "this" keyword is still a problem with the same solution but this time you can declare your instance shortcut once at the beginning of the constructor.
It can be written like this:

```javascript
var MyClass = function() {
    var me = this;

    var privateMember = "hidden";
    
    me.publicMethod = function () { return "hello from object"; };
    me.publicMember = "public";
    me.getMember = function () { return privateMember; };
};
```


##Final words

It is a choice you have to do before starting your project you can imagine these scenarios.

**prototype only**

Less readability but more extensibility and more performance because instance methods/member are defined once.
You can choose this way if you 

**closure only**

Good choice for a majority of projects (like LOB applications) because it's more readable and maintainability. This choice is often made in B2B "simple" software.

**mixed**

Maybe your application has big performance requirements in some cases but because of it is a big application you want the most readability/maintainability possible so in this case you can make the choice to mix the both approach and use prototype on your sensible objects.

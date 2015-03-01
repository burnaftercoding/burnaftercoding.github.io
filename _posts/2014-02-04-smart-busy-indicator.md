---
layout: post
title:  "Smart busy indicator"
excerpt: "This article presents a way to use busy indicator with a nice user experience."
date:   2014-11-16 22:50:00
categories: post
tags : [Async, JavaScript]
lang : [en]
---

This article presents a way to use busy indicator with a nice user experience.

##Introduction

###Context

Today Developers are not just coding, they are developping rich GUI for users that are more and more demanding.
In a lot of application you have to load data and block the user during the loading. The simpliest approach is to write a Load method and call it in your View (ViewModel/Model/etc).
In this case you have an application frozen in each load! Users may think that the application crashs!

###Busy indicator control

Fortunatly , nice guys create controls like "BusyIndicator" (WPF toolkit). You put the BusyIndicator in your app and when you have to load data you show it and when the data is loaded you hide it.

Well ... In fact this is sometime an anti pattern! Why? Because for short loading time your BusyIndicator will blink, and it's horrible for the user and he may think that the application is artificially slow if you show busy indicator everywhere everytime.

###The good timing

So you ve got to show the busy indicator on long loading and don't show it for short loading. My preferences is that less than 500ms is a short loading and more is a long one.

But most of the time you can't predict the duration of your loading process you have to take in consideration that your busy indicator must be visible at least some time or else it will blink.

The rule is: don't show a BusyIndicator if the duration of your loading is less than 500ms and show the BusyIndicator at least 1s. Easy! 

Let's implement that.

<h2>WPF and C#</h2>

In a basic view I create 3 busy indicators for loading durations of 100ms/600ms/3s.

```xml
<xctk:BusyIndicator IsBusy="{Binding IsBusy1}" Grid.Row="0">
    <TextBlock Text="Short task (100ms) load quickly without showing the loading"/>
</xctk:BusyIndicator>
<xctk:BusyIndicator IsBusy="{Binding IsBusy2}" Grid.Row="1">
    <TextBlock Text="Medium task (600ms) display loading after 500ms for 1s"/>
</xctk:BusyIndicator>
<xctk:BusyIndicator IsBusy="{Binding IsBusy3}" Grid.Row="2">
    <TextBlock Text="Big task (3s) display loading after 500ms for 2.5s"/>
</xctk:BusyIndicator>
```

And the C# code associated.

```csharp
private void Load()
{
    var workPromise1 = Task.Delay(100);
    DisplayProgressFor(workPromise1, v => IsBusy1 = v);

    var workPromise2 = Task.Delay(600);
    DisplayProgressFor(workPromise2, v => IsBusy2 = v);

    var workPromise3 = Task.Delay(3000);
    DisplayProgressFor(workPromise3, v => IsBusy3 = v);
}

public async Task DisplayProgressFor(Task task, Action<bool> setBusyIndicator)
{
    await Task.Delay(500);

    if (task.IsCompleted == false)
    {
        setBusyIndicator(true);
        await Task.Delay(1000);
        try
        {
            await task;
        }
        finally
        {
            setBusyIndicator(false);
        }
    }
}
```

## HTML5 and Promises

The same is possible in web technologies with promises.

```html
<span>Short task (100ms) load quickly without showing the loading :</span>
<br />
<span id="loading1" style="display:none;">loading</span>
<br /><br />
<span>Medium task (600ms) display loading after 500ms for 1s:</span>
<br />
<span id="loading2" style="display:none;">loading</span>
<br /><br />
<span>Big task (3s) display loading after 500ms for 2.5s:</span>
<br />
<span id="loading3" style="display:none;">loading</span>
```

And the JavaScript code:

```javascript
$(function () {
    var workPromise1 = delay(100);
    displayProgressFor(workPromise1, $("#loading1"));

    var workPromise2 = delay(600);
    displayProgressFor(workPromise2, $("#loading2"));

    var workPromise3 = delay(3000);
    displayProgressFor(workPromise3, $("#loading3"));
});

function displayProgressFor(workPromise, $loader) {
    var loading = true;
    workPromise.then(function () { loading = false; });

    return delay(500).then(function () {
        if (!loading) return;
        $loader.show();
        Q.all([delay(1000), workPromise])
            .done(function () { $loader.hide(); });
    });
}

function delay(ms) {
    var deferred = Q.defer();
    setTimeout(deferred.resolve, ms);
    return deferred.promise;
}
```

##Final words
A little thing for a big win. Focus on ergonomy! Don't let your users with a poor experience on loading data. 

Put yourself in the user place! ;-)

You can find the source code associated to this article [here][downloadlink]

[downloadlink]: https://skydrive.live.com/re



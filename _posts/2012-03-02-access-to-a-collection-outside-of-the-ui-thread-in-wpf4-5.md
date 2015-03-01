---
layout: post
title:  "Access to a collection outside of the UI thread in WPF 4.5"
excerpt: "This article presents a new feature of WPF 4.5: the capacity to modify collections on background threads."
date:   2012-03-02 14:55:00
categories: post
tags : [WPF, Async]
lang : [en]
image:
  feature: abstract-11.jpg
---

This article presents a new feature of WPF 4.5: the capacity to modify collections on background threads.

One of the biggest problems of programming with RIA is that if you are running a long process on your UI thread the application is frozen until it’s finished.
A solution is the asynchronous programming. In that case you are running your “heavy” code in another thread and the UI is still responsible.
But there is still a drawback. You can't modify an UI object (object used with data binding in your GUI) in another thread than the UI thread.

For example you have a ListBox:

```xml
<ListBox ItemsSource="{Binding Items}">
```

Bound on a Collection of strings: 

```csharp
private ObservableCollection<string> _items = new ObservableCollection<string>();
public ObservableCollection<string> Items { get { return _items; } }
```

Now you can add elements on the UI Thread like this:

```csharp
private void Button_Click_1(object sender, RoutedEventArgs e)
{
    Items.Add("Hello sync !");
}
```

But if you try to add elements on another thread (here created with a Task object):

```csharp
private void Button_Click_2(object sender, RoutedEventArgs e)
{
    Task.Run(() => Items.Add("Hello async !"));
}
```

You will have an NotSupportedException and your application will fail.

This is quite annoying but after several versions of WPF and multiple solutions more or less natural to achieve this kind of operations (Background Worker, Dispatcher …) there is now a natural solution to manipulate asynchronously UI collections: the BindingOperations.EnableCollectionSynchronization() method that combines an observable collection with a lock and allow manipulation of the collections without any more code.

It can be used like this :


```csharp
private static object _itemsLock = new object();
private ObservableCollection<string> _items = new ObservableCollection<string>();
public ObservableCollection<string> Items { get { return _items; } }

public MainWindow()
{
    InitializeComponent();
    BindingOperations.EnableCollectionSynchronization(_items, _itemsLock);
}
```

The line using a Task object can now work properly.
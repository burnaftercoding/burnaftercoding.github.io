---
layout: post
title:  "Draw something with html5"
excerpt: "This article presents an implementation of Draw Something in Html5 with the canvas technology."
date:   2012-06-13 16:01:34
categories: post
tags : [Html5, JavaScript]
lang : [en]
image:
  feature: abstract-11.jpg
---

This article presents an implementation of Draw Something in Html5 with the canvas technology.

##Introduction

###Draw Something ?
Draw Something is an IPhone/Android application (thank you for Windows Phone users) that allow you to draw an image that must represent a word. Your draw is then sent to a friend and this one have to guess the word by seeing your draw as draw it.

###Why this article ?
I was thinking about writing an article using the html5 canvas but how can I be original compared with existing articles on canvas.
Draw something is my choice.

###The focus of this article
In the source code of the application you have a full asp.net MVC application with storage of drawing in an SQL Server database with Entity Framework Code First.
The focus of this article is totally on the client side, on the creation and play of the drawing without social interactions.


##Conception
###Let's think about the playability of a drawing
So how can I create the same user experience? 
I can't just save a bitmap at the end of the first user save because I want the user seeing the drawing see it with the same experience as he see it in live.
I can't capture bitmaps at xx fps and create a video because it's too heavy.
So I will save each path and each point traced by the user with the color, pen size, and time associated in a JSON list of paths.


###Models

Let's start with our models. The 2 models are "Path" and "Point".
A Path is a list of Point with the color/pen size associated.
A Point has coordinates (x,y) and a date.

```javascript
(function (global, undefined) {
    "use strict";
    var DrawSomething = global.DrawSomething = global.DrawSomething || {};
    var Models = DrawSomething.Models = DrawSomething.Models || {};

    Models.Point = function (x, y) {
        var me = this;
        me.x = x;
        me.y = y;
        me.date = new Date().getTime();
    };

    Models.Path = function (color, lineWidth) {
        var me = this;
        me.points = [];
        me.color = color;
        me.lineWidth = lineWidth;
    };
})(this)
```

Each drawing is save on the server side with a Draw model
The Key property is the word associated to the drawing, the Data property is the raw JSON of the drawing.

```csharp
public class Draw
{
    [Key]
    public int Id { get; set; }

    [Required]
    [StringLength(30)]
    public string Name { get; set; }

    [Required]
    [StringLength(30)]
    public string Key { get; set; }

    public string Data { get; set; }
}
```

##Draw engine

The separation of concerns is done by extraction the drawing logic of the views (Create/Details) code.
A DrawEngine object is constructed with a canvas and store color/pen size/pen type and has 2 methods:

- draw(from, to)
Draw a line between 2 points.
- updateParameters()
Apply the colors/pen size/ pen type to the 2d context of the canvas

```javascript
(function (global, undefined) {
    "use strict";
    var DrawSomething = global.DrawSomething = global.DrawSomething || {};
    
    DrawSomething.DrawEngine = function (canvas) {
        var me = this;
        me.canvas = canvas;
        me.context = canvas.getContext("2d");

        me.color = "#000000";
        me.lineJoin = "round";
        me.lineWidth = 10;

        me.updateParameters = function () {
            me.context.lineJoin = me.lineJoin;
            me.context.strokeStyle = me.color;
            me.context.lineWidth = me.lineWidth;
        };

        me.draw = function (from, to) {
            me.context.beginPath();
            me.context.moveTo(from.x, from.y);
            me.context.lineTo(to.x, to.y);
            me.context.closePath();
            me.context.stroke();
        };

        me.updateParameters();
    };

})(this)
```

##Creation of a drawing
###View

The view has 4 parts:

A classic asp.net MVC form.

```html
@using (Html.BeginForm()) {
    @Html.ValidationSummary(true)
    
    <fieldset>
        <legend>Draw</legend>

        <div class="editor-label">
            @Html.LabelFor(model => model.Name)
        </div>
        <div class="editor-field">
            @Html.EditorFor(model => model.Name)
            @Html.ValidationMessageFor(model => model.Name)
            @Html.HiddenFor(model => model.Data)
        </div>

        <div class="editor-label">
            @Html.LabelFor(model => model.Key)
        </div>
        <div class="editor-field">
            @Html.EditorFor(model => model.Key)
            @Html.ValidationMessageFor(model => model.Key)
        </div>  
        <p>
            <button id="saveButton">Save</button>
        </p>
    </fieldset>
}
```

A color picker.

```html
<table id="colorPicker">
    <tr>
        <td style="background: black"></td>
        <td style="background: red"></td>
        <td style="background: green"></td>
        <td style="background: yellow"></td>
        <td style="background: blue"></td>
        <td style="background: white"></td>
    </tr>
</table>
```

A size picker.

```html
<table id="sizePicker">
    <tr>
        <td>6</td>
        <td>10</td>
        <td>16</td> 
        <td>30</td>
        <td>50</td>
        <td>100</td>
    </tr>
</table>
```

And the drawing surface.

```html
<canvas id="surface" width="400" height="300" style=" border: black 2px solid;"></canvas>
```

###JavaScript behind the drawing creation

Ok now the code of the creation view, you think it's difficult? No, you are wrong.
It's really simple in less than 80 lines?

First the imports and members:

```javascript
(function (global, undefined) {
    "use strict";
    var Point = DrawSomething.Models.Point;
    var Path = DrawSomething.Models.Path;
    var DrawEngine = DrawSomething.DrawEngine;


    var painting = false;
    var drawEngine;
    var paths = [];
    var currentPath = null;
    var lastPoint = null;

    //...

})(this)
```

The painting boolean is here to indicate if the user is currently drawing.
The paths member is the list of path of the drawing.
The currentPath and lastPoint store the current path the user is drawing and the last point created.

Now let's see the ready function that initialize the view:

```javascript
(function (global, undefined) {
    "use strict";
    
    //...

    var ready = function () {
        var canvas = document.getElementById("surface");
        drawEngine = new DrawEngine(canvas);

        $("#surface")
            .mousemove(mouseMove)
            .mousedown(mouseDown)
            .mouseup(stopTracking)
            .mouseout(stopTracking);
        $("form").submit(submit);

        $("#colorPicker").click(colorPicked);
        $("#sizePicker").click(sizePicked);
    };

    //...

    $(document).ready(ready);
})(this)
```

It creates the drawEngine, get the mouse events and color/size picker events.

Let's see mouse events functions:

```javascript
var mouseDown = function (e) {
    painting = true;

    currentPath = new Path(drawEngine.color, drawEngine.lineWidth);
    lastPoint = new Point(e.pageX - this.offsetLeft, e.pageY - this.offsetTop);
    currentPath.points.push(lastPoint);
    drawEngine.draw(lastPoint, lastPoint);
};

var mouseMove = function (e) {
    if (painting) {
        var point = new Point(e.pageX - this.offsetLeft, e.pageY - this.offsetTop);

        if (Math.abs(point.date - lastPoint.date) > 100
                || Math.abs(point.x - lastPoint.x) > 3
                || Math.abs(point.y - lastPoint.y) > 3) {
            drawEngine.draw(lastPoint, point);
            lastPoint = point;
            currentPath.points.push(point);
        }
    }
};

var stopTracking = function (e) {
    painting = false;

    if (currentPath != null) {
        paths.push(currentPath);
        currentPath = null;
    }
};
```

The only special line is the test on the mouseMove function.
It limits the number of points created (and lines drawn) to movements of more than 3 pixels or movements each 100 ms.

Now let's see the color/size pickers:

```javascript
var colorPicked = function (e) {
    drawEngine.color = $(e.target).css("background-color");
    drawEngine.updateParameters();
};

var sizePicked = function (e) {
    drawEngine.lineWidth = e.target.innerHTML;
    drawEngine.updateParameters();
};
```

Rather basic but simple.

And finally the submit method that capture the JSON from the paths.

```javascript
var submit = function (e) {
    $("#Data").val(JSON.stringify(paths));
};
```


##Play of a drawing
###View

The view has 4 parts:

A classic details view with hidden fields for JSON data and key.
The canvas is here to play the video and a key input is here to let the user guess the key.

```html
<fieldset>
    <legend>Draw</legend>

    <div class="display-label">Name</div>
    <div class="display-field">
        @Html.DisplayFor(model => model.Name)
        @Html.HiddenFor(model => model.Data)
        @Html.HiddenFor(model => model.Key)
    </div>

    <div class="display-label">Data</div>
    <div class="display-field">
        <canvas id="surface" width="400" height="300" style=" border: black 2px solid;">
        </canvas>
    </div>

    <div class="display-label">Key</div>
    <div class="display-field">
        <input id="keyInput" type="text"/>
        <span id="validTip">Well done !</span>
    </div>
</fieldset>
```

###JavaScript behind the drawing play

Ok now the code of the creation view, you think it's easy like the creation? In fact a little less than the creation. ;-)
The challenge is to play the drawing at the same speed than the speed of the drawer. In JavaScript, if you do not want to use advanced frameworks you are limited compared to C# for asynchronous tasks. Here I use the setTimeout function, that executes an action xx ms later. You can't simply loop on all paths and points and draw a line after a "sleep" so you have to work point by point.

The imports and members:

```javascript
(function (global, undefined) {
    "use strict";
    var DrawEngine = DrawSomething.DrawEngine;
    
    var paths = [];
    var pathIndex = 0;
    var pointIndex = 0;
    var previousPoint = null;
    var key;

    var drawEngine;

    //...
})(this)
```

The paths member is the list of path of the drawing.
The pathIndex and pointIndex are the indexes of your current path and point of your playing.
The previousPoint reference the point before the current (to draw a line between the previous and the current point)
The key member is the key that the user should guess.

Let's see the ready function that initializes the view:

```javascript
(function (global, undefined) {
    "use strict";
    
    //...

    var ready = function () {
        $("#validTip").hide();

        var canvas = document.getElementById("surface");
        drawEngine = new DrawEngine(canvas);

        var jsonData = $("#Data").val();
        paths = JSON.parse(jsonData);

        $("#keyInput").keyup(keyTyped);
        key = $("#Key").val();

        next();
    };

    //...

    $(document).ready(ready);
})(this)
```

This function prepares the draw engine, load the json data and bind the keyup event of the box dedicated to the guess.
Finally the "ready" function calls the "next" function that take care of the next point of the drawing.

Let's see how it works:

```javascript
var getCurrentPoint = function () {
    return paths[pathIndex].points[pointIndex];
};

var next;
next = function () {

    var currentPoint = getCurrentPoint();
    var path = paths[pathIndex];

    if (pointIndex == 0) {
        drawEngine.color = path.color;
        drawEngine.lineWidth = path.lineWidth;
        drawEngine.updateParameters();
    } else {
        drawEngine.draw(previousPoint, currentPoint);
    }

    previousPoint = currentPoint;

    if (pointIndex == path.points.length - 1) {
        pointIndex = 0;
        pathIndex += 1;
    } else {
        pointIndex += 1;
    }

    if (pathIndex != paths.length) {
        var nextPoint = getCurrentPoint();

        setTimeout(next, nextPoint.date - currentPoint.date);
    }

    previousPoint = currentPoint;
};
```

It's just an iteration on the paths/points with a setTimeout to call the "next" method after the time between the current point and the next point.
Maybe the iteration can be better but I am not a specialist of iterate JavaScript arrays.

Finally the method that validate the input of the user:

```javascript
var keyTyped = function (e) {
    var input = $("#keyInput");
    if (input.val() == key) {
        input.hide();
        $("#validTip").show();
    }
};
```

##The result
A video should be better but at least a screenshot can show you the user experience.

![Canvas draw something][drawSomethingImage]

##Final words
Again a lot of optimization are possible:

1. Optimize the test in the mouse move
The current test is just to avoid capturing too many points but it can be more complex to be more efficient with a more precise drawing.
2. Add an engine that optimize the point list
Create with "captured points" a list of "displayed points" by adding points by interpolation or removing useless points to have an user experience smoother.
3. Use Bezier curves instead of points
With some nice algorithms (correctly timed) you can transform the points captured to Bezier curves lighter and smoother than the paint approach of the drawing.

You can find the source code associated to this article [here][downloadlink]

[downloadlink]: https://onedrive.live.com/download?resid=EEE66E4387AB62A!3584&authkey=!ADRkhVVp_U3EnWo&ithint=file%2c7z
[drawSomethingImage]: https://onedrive.live.com/download?resid=EEE66E4387AB62A!3585&authkey=!AK-YXGL6Yqo2zDE&v=3&ithint=photo%2cpng
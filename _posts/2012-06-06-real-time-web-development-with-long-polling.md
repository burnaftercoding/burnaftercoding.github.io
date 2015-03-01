---
layout: post
title:  "Real time web development with long polling"
excerpt: "This article presents the long polling pattern and shows a way to implement it with a Web real-time chat."
date:   2012-06-06 22:27:00
categories: post
tags : [WCF]
lang : [en]
image:
  feature: abstract-11.jpg
---

This article presents the long polling pattern and shows a way to implement it with a Web real-time chat.

##Introduction
###The purpose of real time programming
Imagine you have distant users and you want that these users see the same state of a view and interact with it in real time (a chat, a dashboard, whatever you want), how can you do it ?

There is a development model named [Comet programming](http://en.wikipedia.org/wiki/Comet_(programming)) that allowing these kinds of functionalities and I will show you one of its patterns: the long polling.

###The timed polling technique
Inexperienced developers may use a timer on the client that refresh the view by polling the data every second (or 500 ms or less), it seems to be good but it's not really efficient.
If you have 100 users you have 100 (200 or more) calls per second even if there is no new data to load.
You can increase the time between 2 calls but your will lose responsiveness, even 1 second to have your screen refreshed can seem too slow in a lot of situations where you want or need real time responses.

###The pushing technique
The solution is to **"push"** some information from your server to your client. Push can be used to send data or "events" to the client.
When needed (and only when needed) the server sends information to the client directly, each call is useful and the latency is near 0 (depending on workload and bandwidth).
Push is natively possible with WCF DualHttpBinding and NetTcpBinding but there are some limitations:

- You need to open port dedicated to this communication (NetTcpBinding)
- Some networks (firewalls) don't allow connection from server to the client (even with the Http protocol)
- You can't (currently) push data to a browser so it can't be used for web development

###The long polling technique
One solution (among others) is to use the long polling technique that "simulate" Push.
The long polling is in fact a solution near timed polls but give an "experience" like push let see how it proceed:

0. The user launch the application or go to the website
    - Load (or return) your view with initialized data
1. On the client side
    - Call the server if there are modifications since a timestamp
2. on the server side
    - If they are modifications, return it immediately
    - Else block the client call and register for modifications with a timeout (for example 30s)
    - On modification event, return the new data
    - If the timeout is finish return an empty modifications list
3. On the client side with the return of the call
    - If they are modification apply them to the view and update your timestamp
    - Finnaly recall the server if there are modifications (step 1)

This approach permit two things:
- When there are modifications on the server they instantaneously return to your client (like a push).
- You have a maximum of "useless" calls of n users / t timeout (with 100 users and 30s timeout = 3.3 call/s instead of 100 or 200 for 1 s / 500 ms timed polling)

There is one drawback versus real push: your request is blocked on the server side, so one thread is blocked for each user. You have to think about your number of users and threads that your webserver can allow.

Now let's code an example of long polling screen, a simple multi user web chat.

##The model
First, we create our model's classes:

- User: represent a connected user on the chat.
- Message: A message sent by a user on the chat.
- SessionKey: A way to identify the user that sends data.

```csharp
public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
}

public class Message
{
    public User User { get; set; }
    public DateTime Date { get; set; }
    public string Text { get; set; }
}

public class SessionKey
{
    public Guid Id { get; set; }
    public User User { get; set; }
}
```

##The Webservice

Let's think about our web service, we need 3 things:

- CreateSession: Initialize the chat session for a user and give him a SessionKey
- GetUpdates: Our long polling method, return new messages of the chat since a timestamp (Ticks)
- SendMessage: Send a message on the chat

###Contracts

```csharp
[ServiceContract]
public interface IChatService
{
    [OperationContract, WebInvoke(ResponseFormat = WebMessageFormat.Json,
        RequestFormat = WebMessageFormat.Json, BodyStyle = WebMessageBodyStyle.Wrapped)]
    CreateSessionResult CreateSession(CreateSessionParameter parameter);

    [OperationContract, WebInvoke(ResponseFormat = WebMessageFormat.Json,
        RequestFormat = WebMessageFormat.Json, BodyStyle = WebMessageBodyStyle.Wrapped)]
    GetUpdatesResult GetUpdates(GetUpdatesParameter parameter);

    [OperationContract, WebInvoke(ResponseFormat = WebMessageFormat.Json,
        RequestFormat = WebMessageFormat.Json, BodyStyle = WebMessageBodyStyle.Wrapped)]
    SendMessageResult SendMessage(SendMessageParameter parameter);
}

public class ParameterBase
{
    public SessionKey SessionKey { get; set; }
}

public class GetUpdatesParameter : ParameterBase
{
    public long Ticks { get; set; }
}

public class GetUpdatesResult
{
    public long Ticks { get; set; }
    public ICollection Messages { get; set; }
}

public class SendMessageParameter : ParameterBase
{
    public string Message { get; set; }
}

public class SendMessageResult { }

public class CreateSessionParameter
{
    public string Name { get; set; }
}

public class CreateSessionResult
{
    public SessionKey Key { get; set; }
}
```

As you can see I use the WebInvoke attribute to create a REST service that return JSON.

###Notifications

Now I will create a base Notification class that represent a event dedicated to a user at a specific date.
The MessageNotification class represents a new message in the chat. You can also imagine a UserJoinNotification, to show when a user join the chat.

```csharp
public class Notification
{
    public DateTime Date { get; set; }
}

public class MessageNotification : Notification
{
    public Message Message { get; set; }
}
```

###User sessions
Then I create a representation of the session of a user with a UserSession class.

This session contains:

- A SessionKey to do a correlation between request and user
- A collection of notifications associated to the user
- An event that raise changes in the session (new notifications)
- Methods to Add/Get/Check notifications

```csharp
public class UserSession
{
    public UserSession(SessionKey key)
    {
        Key = key;
        Notifications = new BlockingCollection();
    }

    public DateTime LastActivityDate { get; set; }
    public SessionKey Key { get; set; }

    protected BlockingCollection Notifications { get; set; }

    public event EventHandler HasChanged;

    protected void NotifyChanges()
    {
        EventHandler handler = HasChanged;
        if (handler != null) handler(this, EventArgs.Empty);
    }

    private object notifyAddLock = new object();
    public void Notify(Notification notification)
    {
        lock (notifyAddLock)
        {
            notification.Date = DateTime.Now;
            Notifications.Add(notification);
        }

        NotifyChanges();
    }

    public ICollection GetUpdates(long ticks)
    {
        return Notifications.Where(n => n.Date.ToClientTicks() > ticks).ToList();
    }

    public bool HasChanges(long ticks)
    {
        return Notifications.Any(n => n.Date.ToClientTicks() > ticks);
    }
}
```

###Chat engine

Now I create a ChatEngine class that represents the chat session.
It is a singleton class and contains the user sessions.
You can send message on this object with the SendMessage method, it simply creates new message notifications on the user sessions.

```csharp
public class ChatEngine
{
    private ChatEngine()
    {
        Sessions = new ConcurrentDictionary();
    }

    private static ChatEngine _current;
    public static ChatEngine Current
    {
        get { return _current ?? (_current = new ChatEngine()); }
    }

    public event EventHandler Changed;

    public void OnChanged(EventArgs e)
    {
        EventHandler handler = Changed;
        if (handler != null) handler(this, e);
    }

    public ConcurrentDictionary Sessions { get; set; }

    public void SendMessage(Message message)
    {
        var notification = new MessageNotification
        {
            Message = message,
        };

        Sessions.Values.Notify(notification);
    }
}

public static class Extensions
{
    public static void Notify(this IEnumerable sessions, Notification notification)
    {
        foreach (var userSession in sessions.AsParallel())
        {
            userSession.Notify(notification);
        }
    }

    public static long ToClientTicks(this DateTime dateTime)
    {
        return dateTime.Ticks / 100;
    }
}
```

###Web service implementation
Now let's see the implementation of the service.

I create a helper method "GetSession" that return a UserSession by a SessionKey.
The CreateSession method create a SessionKey and an User with a "fake autoinc" id and register it to the ChatEngine.
The SendMessage method simply calls the SendMessage method of the ChatEngine with a DateTime created on the server side.

```csharp
public class ChatService : IChatService
{
    private UserSession GetSession(SessionKey key)
    {
        UserSession userSession;

        if (ChatEngine.Current.Sessions.TryGetValue(key.Id, out userSession))
            return userSession;

        throw new FaultException("La session utilisateur n'existe pas", new FaultCode("NoSession"));
    }

    private static int _userAutoIncId;
    public CreateSessionResult CreateSession(CreateSessionParameter parameter)
    {
        var userId = Interlocked.Increment(ref _userAutoIncId);
        var key = new SessionKey
        {
            User = new User { Id = userId, Name = parameter.Name },
            Id = Guid.NewGuid(),
        };
        var session = new UserSession(key);

        ChatEngine.Current.Sessions.TryAdd(key.Id, session);

        return new CreateSessionResult {Key = key};
    }

    public SendMessageResult SendMessage(SendMessageParameter parameter)
    {
        var userSession = GetSession(parameter.SessionKey);

        ChatEngine.Current.SendMessage(
            new Message { Date = DateTime.Now, Text = parameter.Message, User = userSession.Key.User });

        return new SendMessageResult();
    }
    //...
}
```

And the main method of the long polling pattern: the GetUpdates method
The principle is to create an EventWaitHandle object and wait for a timeout (lesser than the client timeout).
A subscribe to the modification of the UserSession simply stop the EventWaitHandle.

And at the end of the method I return the new notifications and the synchronization time point ticks.

```csharp
public class ChatService : IChatService
{
    //...
    public GetUpdatesResult GetUpdates(GetUpdatesParameter parameter)
    {
        var userSession = GetSession(parameter.SessionKey);

        var timeout = new TimeSpan(0, 0, 15);

        var wait = new EventWaitHandle(false, EventResetMode.ManualReset);

        EventHandler waiter = (s, e) => wait.Set();
        userSession.HasChanged += waiter;

        if (userSession.HasChanges(parameter.Ticks) == false)
        {
            wait.WaitOne(timeout);
        }

        userSession.HasChanged -= waiter;
        var changes = userSession.GetUpdates(parameter.Ticks);

        return new GetUpdatesResult
                    {
                        Ticks = (changes.Any() ? changes.Max(n => n.Date).ToClientTicks() : 0),
                        Messages = changes.OfType().Select(n => n.Message).ToList(),
                    };
    }
}
```

##The Client
Now let's see the client part I start with the webservice calls

###Webservice proxy

No soap here, we have to format data with ["convention instead of configuration"](http://en.wikipedia.org/wiki/Convention_over_configuration) mapped on the classes signatures.

The SendMessage and CreateSession are simple xhr calls.
The GetUpdates has the particularity to be started once with the StartGetUpdate function and relaunch himself when completed.

```javascript
(function (global, undefined) {

    //namespace Anthyme.LongPollingChat.ChatService
    var Anthyme = global.Anthyme = global.Anthyme || {};
    var LongPollingChat = Anthyme.LongPollingChat = Anthyme.LongPollingChat || {};
    var ChatService = LongPollingChat.ChatService = LongPollingChat.ChatService || {};


    var key = null;
    var runningUpdates = null;
    var ticks = 0;
    var genericFailed = function (rep) { debugger; };

    ChatService.SendMessage = function (callback, message) {
        $.ajax(
            {
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "/ChatService.svc/SendMessage",
                data: JSON.stringify(
                    {
                        parameter: { Message: message, SessionKey: key }
                    }),
                success: callback,
                error: genericFailed
            }
        );
    };

    ChatService.CreateSession = function (callback, name) {
        $.ajax(
            {
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "/ChatService.svc/CreateSession",
                data:
                    JSON.stringify(
                        {
                            parameter: { Name: name }
                        }
                    ),
                success: function (rep) {
                    key = rep.CreateSessionResult.Key;
                    callback(rep.CreateSessionResult);
                },
                error: genericFailed
            }
        );
    };

    ChatService.StartGetUpdates = function (callback) {
        getUpdates(callback);
    };

    var getUpdates = function (callback) {
        if (runningUpdates == null) {
            runningUpdates =
                $.ajax(
                    {
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "/ChatService.svc/GetUpdates",
                        data: JSON.stringify(
                            {
                                parameter: { Ticks: ticks, SessionKey: key }
                            }
                        ),
                        success: function(rep) {
                            var newTicks = rep.GetUpdatesResult.Ticks;
                            if (newTicks != 0) ticks = newTicks;
                            runningUpdates = null;
                            callback(rep.GetUpdatesResult);
                            setTimeout(function() {
                                getUpdates(callback);
                            }, 50);
                        },
                        error: genericFailed
                    });
        }
    };
})(this);
```

###View
The view of the chat. Simply a login dialog and chat viewer/input.

```html
<div id="JoinGameDialog">
  <h4>Enter Login :</h4>
  <input id="LoginInput" type="text" />
  <button id="LoginButton">Join</button>
</div>
<div id="ChatBox">
 <h4 id="UserWelcome">Welcome</h4>
 <div id="RoomChat"></div>
 <input id="MessageInput" type="text" />
 <button id="SendButton">Send</button>
</div>
```


###View logic code

The JavaScript associated to our view that map user actions with webservice call and format the data for the display.

```javascript
(function (global, undefined) {

    var ChatService = Anthyme.LongPollingChat.ChatService;

    var messageCount = 0;

    var initSession = function (name) {
        ChatService.CreateSession(
            function (r) {
                ChatService.StartGetUpdates(manageUpdates);
                $("#ChatBox").show(0.5);
                $("#MessageInput").focus();
            },
            name);
        $("#JoinGameDialog").hide(0.5);
    };

    var sendMessage = function () {
        var input = $("#MessageInput");
        var message = input.val();
        input.val("");
        ChatService.SendMessage(function (rep) {}, message);
        input.focus();
    };

    var manageUpdates = function (data) {
        if (data.Messages != null) {
            data.Messages.forEach(function (message) {
                $("#Messages").append(message.User.Name + " : " + message.Text + "<br/>");
                messageCount++;
                $("#RoomChat").scrollTop(20 * messageCount);
            });
        }
    };

    $(document).ready(function () {
        $("#ChatBox").hide();
        $("#LoginButton").click(function (e) {
            var userName = $('#LoginInput').val();
            $('#UserWelcome').append(userName);
            initSession(userName);
        });
        $("#SendButton").click(function (e) {
            sendMessage();
        });
    });

})(this)
```

##The result

![Long polling chat][longPollingResultImage]

##Final words
Ok it's a draft and you can imagine a lot of optimizations and features (disconnection clear the notification collection ...). I have advices for you:

1. Don't create multiple long polling calls per page (and per user if possible) because it block a call on your webserver and it can be a big problem of thread/memory usage.
A solution can be a multiplication of data present in the GetUpdatesResult object (like user joining/leaving the chat, everything you need in the page).

2. If you have a complex application, create an event approach
Rename the GetUpdates method to "GetNotifications" and then publish notifications to the different parts (modules) of your application with an event aggregator (like amplify). These parts can then retreive information they need like a GetMessagesFrom(ticks) for the message part, GetUserJoinFrom(ticks) for the user list part, etc.

3. Websocket: It is a new html 5 technology that allows real pushes to your client. At this moment the technology is not supported in a lot a browser, you should wait a little before using it.

4. [SignalR](https://github.com/SignalR/SignalR):
It is a new framework to push data to your web client. It uses websockect if available else long polling automatically wrapped in the SignalR API.
It's not totally stable, nor integrated in the WCF stack (too bad) and you have less control but it's really really easy to push data to your client with this framework. You should try it.
I will probably create an article with SignalR if it's useful (there are already articles on SignalR uses).

You can find the source code associated to this article [here][downloadlink]

[downloadlink]: https://onedrive.live.com/download?resid=EEE66E4387AB62A!432&authkey=!AJi5prVy_w0qVnI&ithint=file%2c7z
[longPollingResultImage]: https://onedrive.live.com/download?resid=EEE66E4387AB62A!431&authkey=!AGgws62sMAzZO7A&v=3&ithint=photo%2cpng

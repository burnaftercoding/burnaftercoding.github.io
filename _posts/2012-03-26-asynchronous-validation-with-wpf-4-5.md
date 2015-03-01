---
layout: post
title:  "Asynchronous Validation with WPF 4.5"
excerpt: "This article is about the new validation techniques of WPF 4.5.
It includes an example using INotifyDataErrorInfo, INotifyPropertyChanged and the data annotations."
date:   2012-03-01 22:18:44
categories: post
tags : [WPF, async]
lang : [en]
image:
  feature: abstract-11.jpg
---

This article is about the new validation techniques of WPF 4.5.
It includes an example using INotifyDataErrorInfo, INotifyPropertyChanged and the data annotations.

<!--more-->

In WPF you have 3 differents types of validation:

- ValidationRule: a local (on the binding) valdiation object.
- Validation exception: use exception raised on the property set.
- IDataErrorInfo interface: validation owned by your models and permits more complex (business model) validation.

With WPF 4.5 you have a new (modern) way of valdiation: the INotifyDataErrorInfo interface (inherited from Silverlight. Thank you little brother, RIP).

This interface is somewhat a combination of the IDataErrorInfo technique and the capacity to raise event of a change on the status of the validation of a property (like the INotifyPropertyChanged interface raise the changement of the value).

It offers several interesting scenarios:

- Control the moment of the validation
- Allow asynchronous validation on a background thread
- Make it easier to invalidate a property when setting another property

To express (a part of) the possibilities offered of this interface I will create a base ValidatableModel class.
The approach is to implement INotifyDataErrorInfo and INotifyPropertyChanged interfaces, validate the entire object at each change on the properties with the DataAnnotation validation attributes.
The error are stored in a dictionary that represent the "validation state" of the model and the validation is ran on background (you can add a Thread.Sleep to see the latency).
The validation is locked and launch on each RaisePropertyChanged().

```csharp
public class ValidatableModel : INotifyDataErrorInfo, INotifyPropertyChanged
{
    private ConcurrentDictionary<string, List<string>> _errors = 
        new ConcurrentDictionary<string, List<string>>();

    public event PropertyChangedEventHandler PropertyChanged;

    public void RaisePropertyChanged(string propertyName)
    {
        var handler = PropertyChanged;
        if (handler != null)
            handler(this, new PropertyChangedEventArgs(propertyName));
        ValidateAsync();
    }

    public event EventHandler<DataErrorsChangedEventArgs> ErrorsChanged;

    public void OnErrorsChanged(string propertyName)
    {
        var handler = ErrorsChanged;
        if (handler != null)
            handler(this, new DataErrorsChangedEventArgs(propertyName));
    }

    public IEnumerable GetErrors(string propertyName)
    {
        List<string> errorsForName;
        _errors.TryGetValue(propertyName, out errorsForName);
        return errorsForName;
    }

    public bool HasErrors
    {
        get { return _errors.Any(kv => kv.Value != null && kv.Value.Count > 0); }
    }

    public Task ValidateAsync()
    {
        return Task.Run(() => Validate());
    }

    private object _lock = new object();
    public void Validate()
    {
        lock (_lock)
        {
            var validationContext = new ValidationContext(this, null, null);
            var validationResults = new List<ValidationResult>();
            Validator.TryValidateObject(this, validationContext, validationResults, true);

            foreach (var kv in _errors.ToList())
            {
                if (validationResults.All(r => r.MemberNames.All(m => m != kv.Key)))
                {
                    List<string> outLi;
                    _errors.TryRemove(kv.Key, out outLi);
                    OnErrorsChanged(kv.Key);
                }
            }

            var q = from r in validationResults
                    from m in r.MemberNames
                    group r by m into g
                    select g;

            foreach (var prop in q)
            {
                var messages = prop.Select(r => r.ErrorMessage).ToList();

                if (_errors.ContainsKey(prop.Key))
                {
                    List<string> outLi;
                    _errors.TryRemove(prop.Key, out outLi);
                }
                _errors.TryAdd(prop.Key, messages);
                OnErrorsChanged(prop.Key);
            }
        }
    }
}
```

Now I will create a UserInput model with some validation attributes.

```csharp
public class UserInput : ValidatableModel
{
    private string _userName;
    private string _email;
    private string _repeatEmail;

    [Required]
    [StringLength(20)]
    public string UserName
    {
        get { return _userName; }
        set { _userName = value; RaisePropertyChanged("UserName"); }
    }

    [Required]
    [EmailAddress]
    [StringLength(60)]
    public string Email
    {
        get { return _email; }
        set { _email = value; RaisePropertyChanged("Email"); }
    }

    [Required]
    [EmailAddress]
    [StringLength(60)]
    [CustomValidation(typeof(UserInput), "SameEmailValidate")]
    public string RepeatEmail
    {
        get { return _repeatEmail; }
        set { _repeatEmail = value; RaisePropertyChanged("RepeatEmail"); }
    }

    public static ValidationResult SameEmailValidate(object obj, ValidationContext context)
    {
        var user = (UserInput)context.ObjectInstance;
        if (user.Email != user.RepeatEmail)
        {
            return new ValidationResult("The emails are not equal", 
                new List<string> { "Email", "RepeatEmail" });
        }
        return ValidationResult.Success;
    }
}
```

One last thing is to enable this validation on the bindings with the ValidatesOnNotifyDataErrors property.

```csharp
<TextBox Text="{Binding UserName, ValidatesOnNotifyDataErrors=True}"/>
<TextBox Text="{Binding Password, ValidatesOnNotifyDataErrors=True}" />
<TextBox Text="{Binding RepeatPassword, ValidatesOnNotifyDataErrors=True}" />
```

You can have this kind of render:

![Async validation][asyncValidationImage]

You can also imagine to launch the validate only when the save button is clicked or use a Reactive Extensions (RX) query with the Throttle method to limit the time between two validation (for exemple validate max once per sencond).

You can find the source code associated to this article [here][downloadlink]

[downloadlink]: https://onedrive.live.com/download?resid=EEE66E4387AB62A!424&authkey=!ACKziu7H8tQLhfg&ithint=file%2c7z

[asyncValidationImage]: https://onedrive.live.com/download?resid=EEE66E4387AB62A!429&authkey=!AE3F9QX53uJNr8I&v=3&ithint=photo%2cpng
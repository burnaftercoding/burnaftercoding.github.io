---
layout: post
title:  "Simplified connection string with Entity Framework edmx files"
excerpt: "This article shows how to simplify connection strings with Entity Framework."
date:   2012-03-25 22:18:44
categories: post
tags : [EF, Entity Framework]
lang : [en]
image:
  feature: abstract-11.jpg
---

This article shows how to simplify connection strings with Entity Framework.

Did you already have a project with multiples edmx files? Did you share the data access between entity framework and other frameworks? Did you define multiple configuration environments or multiple configuration files?

In this case you have to maintain a lot of connection strings (n edmx + m another frameworks/ADO.Net access) * x config files * y environments.
In this case you (or your release manager) can have a few headaches.

With edmx you have to use a special connection string that specifies the csdl/ssdl/msl metadata files instead of a simple link to the database like this:

```xml
<connectionStrings>
  <add name="MyDbContext" connectionString="metadata=res://*/MyDbContext.csdl|res://*/MyDbContext.ssdl|res://*/MyDbContext.msl;
    provider=System.Data.SqlClient;provider connection string="data source=.;
    initial catalog=MyDb;integrated security=True;
    multipleactiveresultsets=True;App=EntityFramework""
    providerName="System.Data.EntityClient" />
</connectionStrings>
```

With a little of code you can specify and use only one connection string for all your data accesses with a standard connection string like this:

```csharp
public class MyDbContext : DbContext
{
    public MyDbContext() : base(ConnectionString) { }

    private static string _connectionString;
    public static string ConnectionString
    {
        get
        {
            if (_connectionString == null)
            {
                string baseConnectionString = ConfigurationManager.
                    ConnectionStrings["MyDbContext"].ConnectionString;

                var entityBuilder = new EntityConnectionStringBuilder
                {
                    Provider = "System.Data.SqlClient",
                    ProviderConnectionString = baseConnectionString,
                    Metadata = 
                        @"res://*/MyDbContext.csdl|res://*/MyDbContext.ssdl|res://*/MyDbContext.msl"
                };

                _connectionString = entityBuilder.ToString();
            }
            return _connectionString;
        }
    }
    //...
}
```

And now use a standard connection string:

```xml
<connectionStrings>
  <add name="MyDbContext" connectionString="data source=.;initial catalog=MyDb;integrated security=True;multipleactiveresultsets=True" providerName="System.Data.SqlClient" />
</connectionStrings>
```

The drawback is that you cannot change the configuration without change your binary, in fact deploy a new version of your application. Personally I never need this functionality in real world application.


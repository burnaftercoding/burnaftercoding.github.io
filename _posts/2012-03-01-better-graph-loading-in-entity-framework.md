---
layout: post
title:  "Better graph loading in Entity Framework"
excerpt: "This article is for those who want to go further with Entity Framework and those who think Entity Framework and ORMs, in general, are slow."
date:   2012-03-01 22:18:44
categories: post
tags : [EF, Entity Framework]
lang : [en]
image:
  feature: abstract-11.jpg
---

This article is for those who want to go further with Entity Framework and those who think Entity Framework and ORMs, in general, are slow.

#Context

Let's start to see how efficiently load a multi levels graph of objects from the database.

#Models

First, we create our model's classes : Subject, Category, SubCategory.

Subject is an heavy object that has multiples categories and a Category can have multiple SubCategory.

```csharp
public class ArticleDownloadedHandler : IHandleEvent<ArticleDownloaded>
{
    private readonly IReadabilityService _readabilityService;
    private readonly IArticleRepository _articleRepository;

    public ArticleDownloadedHandler(IReadabilityService readabilityService,
        IArticleRepository articleRepository)
    {
        _readabilityService = readabilityService;
        _articleRepository = articleRepository;
    }

    public async Task HandleAsync(ArticleDownloaded domainEvent)
    {
        var article = await _readabilityService.GetArticleAsync(domainEvent.ArticleId);
        article.Row.TypedId = domainEvent.LocalId;
        article.Row.DownloadedAt = domainEvent.Date;
        _articleRepository.Persist(article.Row);
    }
}

public class Category
{
    public virtual int Id { get; set; }
    public virtual string Name { get; set; }
    public virtual int SubjectId { get; set; }
    public virtual Subject Subject { get; set; }
    public virtual ICollection<SubCategory> SubCategories { get; set; }
}

public class SubCategory
{
    public virtual int Id { get; set; }
    public virtual int Name { get; set; }
    public virtual int CategoryId { get; set; }
    public virtual Category Category { get; set; }
}

public class GraphContext : DbContext
{
    public GraphContext()
    {
        Configuration.LazyLoadingEnabled = true;
        Configuration.ProxyCreationEnabled = true;
    }

    public DbSet<Subject> Subjects { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<SubCategory> SubCategories { get; set; }
}
```

#The target
I want to load one (or multiples) subject(s) with all its categories and sub categories.
Here, we have an one-to-many relation between Subject and Category and another one-to-many relation between Category and SubCategory.

There is two standard ways to load them in Entity Framework:

- Get by id the parent then (by lazy loading or manual loading) load the children collections.
- Get all the graph in one shot with the "Include" method.

##Lazy loading

The lazy loading is activated when you naturaly navigate into reference properties and collections.

```csharp
static void Lazy()
{
    using (var context = new GraphContext())
    {
        var subjects = context.Subjects.Take(fetchSize).ToList();
        foreach (var subject in subjects)
        {
            foreach (var category in subject.Categories)
            {
                foreach (var subCategory in category.SubCategories)
                {
                }
            }
        }
    }
}
```

So what's happenning here ? In the first case you have:

- One query to load the Subject object(s),
- One query per subject to load the categories associated,

- One query per categories to load the sub categories associated.

This is the **n+1 loading problem** and as you can see that it's not an efficient way to load data.

##Include

The include technique allow you to fetch relational data in one shot, reducing the number of trips to the database.

```csharp
static void Include()
{
    using (var context = new GraphContext())
    {
        var subjects =  context.Subjects
            .Include("Categories.SubCategories")
            .Take(fetchSize).ToList();
    }
}
```

Unfortunatly in this case the loading time with Include is far superior to the standard lazy-loading technique !

How is it possible ?
In fact the Include method create a **sql left outer join**. So if we have a subject with 30 categories that each have 20 sub categories the result set of the query contains 1 * 30 * 20 = 600 times the subject data ! If the subject data is big, your result set will be 600 bigger than it should be.

This is why, in my own opinion, the include pattern is, sometimes, an anti-pattern.
Indeed it should be use only on many-to-one relations (that avoid this type of joins) or when the lisibility of the code is more important than the performances.

#Alternative

So how can I efficiently load my objects ?

My technique is to query once per levels and then link the objects in your application.

This technique is automatic (lazy) in others ORM like NHibernate and named as the **batch loading** but in Entity Framework you have to do it manualy.

Let see how it can be written:
(Note that I deactivate the lazy-loading because of the lines that cast to EntityCollection. You don't need to do this if you use EntityObject for your models)

```csharp
static void MultiQuery()
{
    using (var context = new GraphContext())
    {
        context.Configuration.LazyLoadingEnabled = false;
        var subjects = context.Subjects.Take(fetchSize).ToList();
        var subjectsIds = subjects.Select(s => s.Id).ToArray();

        var categories = context.Categories
                .Where(c => subjectsIds.Contains(c.Subject.Id))
                .ToList();

        var categorieIds = categories.Select(s => s.Id).ToArray();

        var subCategories = context.SubCategories
            .Where(c => categorieIds.Contains(c.Category.Id))
            .ToList();

        var categoriesDict = categories.GroupBy(c => c.Subject.Id)
            .ToDictionary(c => c.Key, c => c.ToList());
        var subCategoriesDict = subCategories.GroupBy(c => c.Category.Id)
            .ToDictionary(c => c.Key, c => c.ToList());

        foreach (var subject in subjects)
        {
            var categoriesCollection = 
                (EntityCollection<Category>)subject.Categories;
            categoriesCollection.Attach(categoriesDict[subject.Id]);
        }

        foreach (var category in categories)
        {
            var subCategoriesCollection = 
                (EntityCollection<SubCategory>)category.SubCategories;
            subCategoriesCollection.Attach(
                subCategoriesDict[category.Id]);
        }
        context.Configuration.LazyLoadingEnabled = true;
    }
}
```

Wow, what's a huge code ! That seem's ugly ! Yeah that's a lot of code for loading an object.
But now let see the results in a benchmark with one and multiples subjects:

![Benchmark][benchmarkEfImage]

In this case we have an improvement in performance from 8 to 15 times relativily to the include pattern!

Ok but you can imagine that I optimised the data for this demonstration but don't forget this:

- My database is local and one of biggest problem is the volume of data loaded by the Include pattern.
- I have only one concurent access, imagine if I multiply the same access parallelly? Your data transfert (mostly on network) will be saturated.
- In real world application, I personaly applied this technique several times and won performances from 3 to 8 times vs Include or lazy loading.

Indeed, in this kind of scenario the most efficient way to load data is a multi result set stored procedure.

You can find the source code associated to this article [here][downloadlink]

If you try and you have any observations do not hesitate to comment. ;-)

[benchmarkEfImage]: https://onedrive.live.com/download?resid=EEE66E4387AB62A!416&authkey=!AHCCYnLmP6gye1M&v=3&ithint=photo%2cpng
[downloadlink]: https://onedrive.live.com/download?resid=EEE66E4387AB62A!413&authkey=!AH0ZyqVQagoTo3w&ithint=file%2c7z
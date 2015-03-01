---
layout: post
title:  "Software Architect 2014"
excerpt: "Cette article est un retour sur la conférence Software Architect 2014 @SoftArchConf. Cette conférence s'est déroulée du 14 au 17 octobre 2014 dans la charmante ville de Londres et regroupait des intervenants des plus talentueux nous présentant les derniers patterns d'architecture. Nous allons faire le tour des différentes sessions qui ont retenu mon attention."
date:   2014-11-20 00:00:00
categories: post
tags : [Architecture, Conference]
lang : [fr]
image:
  feature: abstract-11.jpg
---

#Software Architect 2014


Cette article est un retour sur la conférence Software Architect 2014 @SoftArchConf. Cette conférence s'est déroulée du 14 au 17 octobre 2014 dans la charmante ville de Londres et regroupait des intervenants des plus talentueux nous présentant les derniers patterns d'architecture. Nous allons faire le tour des différentes sessions qui ont retenu mon attention.

##This is Water

Cette première session orchestré par Neal Ford @neal4d est une vrai prise de température du monde du développement logiciel aujourd'hui.

###Transactions

    Real world has not transactions, ATMs too

C'est un rappel sur le fait qu'il ne faut pas vouloir tout faire entrer dans des transactions (notamment distribuées).
Le monde réel n'est jamais transactionnel et beaucoup d'implémentations très avancé de systèmes sensibles et complexes (comme les ATMs) ne sont pas basé sur des transactions de bout en bout.

###Functional programming

    Life is too short for malloc

Que ce soit Closure, Scala ou F#, la programmation fonctionnelle fait de plus en plus sens plutôt que la POO
Java 8 a maintenant des équivalents de Linq et Plinq, encore un langage populaire qui cède à l'appel de la programmation fonctionnelle !

![This is water func programming][softarch14-this-is-water-func-programming]

###Architecture evolves

    Yesterday patterns are tomorrow anti patterns

Ou comment insister sur le fait que dans notre métier qui évolue extrêmement rapidement il est nécessaire de se remettre perpétuellement en cause, d'autant plus au niveau architecture.

###Don't forget the value

    Meta work is more interesting than work

Les développeurs préfèrent écrire du Framework que de la fonctionnalité. Ce qui mène souvent à de l'over design.

###Datomic

Citation d'une base de données intéressante : Datomic, une base de données immutable. A tester !

###Women

    Women in team increase average inteligence

Pas grand-chose à ajouter. De la diversité né la créativité.

[La vidéo ici](http://vimeo.com/user22258446/review/110888067/22b2e53897)

##Agile is dead

Une session "bilan" de l'agilité par Allen Holub et notamment de tous les problèmes induis par SCRUM.

###Certified Scrum Master

![Scrum Master][softarch14-death-of-agile-scrum-master]

La certification ne démontrerait rien des compétences de ceux qui l'on passé. 
Il insiste sur le fait que le guide officiel est réduit à 16 pages  mais également aux conditions de passage de l'examen : 

- QCM à 35 questions
- 24 réponses justes pour l'avoir
- Réalisé à la maison avec largement le temps de se documenter
- Et un 2eme passage possible en cas d'échec

###SCRUM and XP

Allen critique le fait que SCRUM ne reprenne que 2 des 13 grand pratiques d'XP.

###SCRUM agile ?

Pour Allen les fondamentaux de SCRUM font qu'il n'est pas agile, par exemple la notion de sprint et cette fameuse durée fixe. Il le démontre avec un exemple simple :
Si vous avez prévu de faire 50 points dans votre sprint, vous serez très rarement pile à ce niveau-néalà à la fin.
Il y a 2 possibilités :

- Vous êtes en retard, et vous allez faire le maximum pour faire rentrer cette dernière user story dans le sprint, en général en dégradant la qualité du livrable et/ou en stressant/chargeant l'équipe de développement.
- Vous êtes en avance, mais le temps restant ne suffit pas à injecter une user story. Résultat : votre équipe est sous chargée et va donc ralentir le temps que le sprint se termine et donc amener une perte de productivité inutile.

Pour lui :

    SCRUM = just say NO

Mais aussi et surtout : 

    100% of real agile projects has no deadlines, they have priorities

###Agile dysfunction partners

![Agile dysfunction partners][softarch14-death-of-agile-agile-killers]

Ils font partie du problème, en voulant faire une espèce de pont entre la gestion de projet classique et le monde agile ils ont complétement déformé le vrai manifeste agile.

    Real agile project doesn't need project management


###Companies ...

Beaucoup d'entreprise souhaitent avoir de l'agilité dans leurs équipes pour en avoir les bénéfices (la productivité surtout).
Mais pour assurer l’environnement nécessaire à ses équipes ne veulent pas remettre en cause : 

Leur culture 

    All your organization like support has to be agile

Leur réactivité

    Agile don’t ask for training or license, they take it now!

Leur management 

    Corporations ask what is the role of project manager in agile team but there are no one

En somme leurs processes

    Some large companies will never be agile [...] because of processes

Néanmoins pour lui les entreprises vont devoir muter et devenir réellement agiles ou disparaitre.

![Companies][softarch14-death-of-agile-companies]

[La vidéo ici](http://vimeo.com/user22258446/review/110886596/b49a8ec509)

##Micro Services with smart use cases

Une session de Sander Hoogendoorn @aahoogendoorn sur les micro services et un gros retour d'expérience sur ce qu'il a déjà mis en place dans son entreprise.


###Why micro services?

Et bien, en vulgarisant, pour éviter ce cas extrême :

    Millions lines of code (in COBOL) => project of 150 millions dollars to migrate => failed

Evidement cela s'applique également à des projets moins ambitieux (éviter de perdre quelques millions est déjà intéressant !).

Le principe est simple: au lieu de créer un gros projet monolithique, vous allez le séparer en une multitude de produits indépendants (au niveau code, déploiement, technologie) qui auront pour but d'être réutilisables et partagés au sein du SI de l'entreprise.

Une fois que cette approche est mise en place, les micro services sont individuellement évaluables ou voir même jetables. 
De par leur conception ils sont également très simples.
Il faut également apprendre à penser en tant que petits produits et non plus en tant que gros projet ne s’intéressant qu’a ses besoin propre.

###Micro Services open standard ISO IEEE

Ok c'est super je veux trop en faire ! C'est quoi le standard à implémenter !?

    Micro service for deployment and scalability. Yes but .., WTF it is !? JSON over http ? 5000 lines of code max?

Et bien en fait non …

    There are no standard way of creating, find your style that work for you

Et oui, même s'il y a des courants de pensée sur la toile, il n'y a pas une seule bonne façon de faire.

Ce qui rend la chose forcement complexe car vous allez, en tant qu'architecte, devoir faire les bons choix d'implémentation en fonction de vos contraintes.

###Micro Design

    Create micro application too! Improve applications after they work, not before!

L'approche classique du commencer petit. Même si on dérive un peu sur l'agilité, ne vous limitez pas à faire des micro services, faites des micro applications et n'évoluez que celles qui font sens.

    Doing big up front deisgn is dumb, doing no design up front is even dumber

###Catalog

Pour pérenniser et mettre en avant la réutilisation de vos micro services vous devez penser à les documenter sous peine d'avoir des doublons créés dans vos futurs projets.

    Create a catalog of components that we can grab for new (micro) applications. For every component we create use cases


###Polyglot persistence

    Polyglot persistence in micro services With a better selection of the persistence

Un des avantages des micro services est là, vu que les micro services sont conçus pour être complètement indépendants, ils ont chacun leur propre persistance et notamment leur propre type de base de données correspondant réellement à leurs besoin.

 ![Micro services polyglot persistence][softarch14-microservices-polyglot]    

###Scalability

    In a DDD perspective a Micro service can be considered as a bounded context

 Un autre avantage des micro services est clairement leur capacité à être scalable. En effet on peut déjà choisir de mettre un micro service par machine/regrouper ceux qui sont peu gourmands entre eux, etc.

 ![Micro services scalability][softarch14-microservices-scalability]

###Drawbacks

Néanmoins il faut faire attentions à certain problèmes que posent les micro services :

- L'approche totalement indépendante en termes de technologies implique un cout de communication important si vous êtes sur des standards comme REST
- La multiplication des technologies peut induire des couts importants en maintenance
- Chaque micro service a un cout d'initialisation plus important

Ces points ont été contournés par Sander de cette façon :

- Utilisation exclusive de Java (une seule compétence requise et des communications natives)
- Chaque micro service est un fichier jar livrable indépendamment
- Une rigueur et des règles vis à vis de ces jars qui ne peuvent pas avoir des dépendances n'importe comment sur d'autres éléments du système

[La vidéo ici](http://vimeo.com/user22258446/review/111313102/5358e5a60a)

##Emergent Design

Une autre session de Neal Ford @neal4d, c'est un recueil de bonnes pratiques sur le design d'application.

###What is (emergent) design?

Commençons par un parallèle avec le monde de l'ingénierie.

    Design in engineering is plan to create the product (like a bridge) but in dev it is the code.  

Euh mais ce n'est pas ce que j'appelle l'architecture ?

    design vs architecture : stuff that's hard vs easy to change latter 

D'accord mais le coté emergent ? 

    emergent design = finding and harvesting idiomatic patterns 

![Idiomatic patterns][softarch14-emergent-design-idiomatic-patterns]

###Unknown unknowns

Une notion très importante dans le design d’application et qui représente le plus grand chalenge : gérer les "unknown unknowns"

![Unknown unknowns][softarch14-emergent-design-unknown-unknowns]


###Reactive Design

    Prefer pro/re-active to predictive when dealing with unknown unknowns  

Ou en 3 mots : No over design ! Vu qu’il existe des unknown unknowns et qu’on ne pourra pas les prévoir et inutile de faire des solutions de type « au cas où je ne sais pas quoi ».

![predictive design][softarch14-emergent-design-predictive]

###Refactoring and Technical debt

    Don’t refactor complex classes refactor complex classes with big class afference (~coupling)

Si une classe est peu utilisé inutile de la refactoriser, refactorisez plutôt ce qui est très couplé au sein de votre application.

Une façon de trouver ces classes est d'utiliser des analyseurs de code comme par exemple Sonar technical debt analyzer.

![Sonar technical debt analyzer][softarch14-emergent-design-sonar]
 
    Convince someone of technical debt exists before speaking repayment! - @martinfowler 

La notion de dette technique si elle devient de plus en plus connue pour les développeurs, elle est encore totalement méconnue des décideurs. Donc avant de parler de refactorisation et de budgets il faut que cette notion soit bien comprise des décideurs.


###Bad design decisions

    Beware of essential (good) vs accidental (bad) complexity like EJB and BizTalk

La complexité qui vient du business (domaine) doit avoir une implantation en rapport avec sa complexité mais ne vous tirez pas une balle dans le pied avec de l'inutile complexité accidentelle venant d’architecture technique trop complexe sans raison.

    Time increase knowledge and context, The longer you can wait the better is the decision 

Retardez le plus possible vos décisions pour faire le choix le plus adéquat et le plus en rapport avec le besoin.

[La vidéo ici](http://vimeo.com/user22258446/review/110882340/b49c85d221)

##Conducting an architecture review 

Une présentation sur les réunions d'architecture de Robert Smallshire.

###Why and when ?

Pourquoi faire une réunion d'architecture ?

- Faire un état des lieux (2eme point de vue)
- Planifier
- Problématiques de performances
- Comprendre pourquoi un projet (ou une équipe) ne délivre plus de valeur
- BIG FAILURE

###Plan your review

Attention aux choix de vos interlocuteurs pour cette réunion.
Si vous faites venir toutes les sortes d’interlocuteurs possibles, la somme de leurs forces additionnées va créer un immobilisme et rien ne ressortira de cette réunion.

![Forces][softarch14-architecture-review-forces]

Et surtout adaptez ces interlocuteurs en fonction du sujet de la réunion.
Pour les performances :

![Performances][softarch14-architecture-review-performances]

Pour l'utilisabilité :

![Usability][softarch14-architecture-review-usability]

Pour les couts :

![Costs][softarch14-architecture-review-costs]

etc

Mais aussi et surtout ne multipliez pas les architectes sous peine de faire s'annuler toutes les forces par oppositions de visions.

![Conceptual integrity][softarch14-architecture-review-conceptual-integrity]

###Perfom the review
Une liste de bonne pratique pour bien conduire la réunion :

- Savoir distinguer les faits des opinions
- Ne pas se faire mousser
- Ne pas perdre du temps à vouloir rendre les gens heureux, le but est de pointer les problèmes et de sortir des solutions
- Faire un rapport 10/15 pages max adapté au public : les décideurs n'auront pas forcement le même rapport (orienté coût et décision) que les développeurs (orienté technique)
- Si la réunion ne doit pas faire plaisir a tout le monde, toujours avoir du tact dans le compte rendu
- Attention à ne pas faire de ces analyses des outils d'évaluation managérial sous peine de perdre la coopération des équipes 
Tell me how you will measure me, and I will tell you how I behave

###Why not?

Et pourquoi ne pas faire une réunion d'architecture ?

- Couts et bénéfices : il faut faire des reviews à l'échelle du problème, si les enjeux sont importants, mettre des moyens important. S’ils ne le sont pas, il n'y a peut-être pas besoin de mettre en place toute cette mécanique.
- Peur d'exposer des faiblesses : pour des raisons politiques des décideurs ne veulent pas que ce soit exposé au sein de l'organisation.
- Problématiques de sécurité : parfois il ne faut trop exposer des problématiques autour de la sécurité de peur qu'elles soient exploitées. 

[La vidéo ici](http://vimeo.com/user22258446/review/110654944/9135a1b58b)

##DDD Misconceptions 

Une session de Dino Esposito @despos qui décortique le DDD et fait la part des choses sur ce qui est universel et ce qui est spécifique dans ces méthodes.

    DDD is sometimes used right, sometimes used wrong, but always cause trouble

De par son approche et son effort important d'abstraction, DDD n'est pas évidant à mettre en place et peut causer des ennuis même sur des applications simples. Et n'enlève pas tous les problèmes sur les applications complexes !

    DDD analytic is good but strategic is optional


###Analytic part, the good part

Ok analytic c'est le top, on y trouve 2 notions que je vais vous détailler.

####Ubiquitous language

L'ubiquitous language est le fait de définir un langage unique partagé entre les équipes de développement et les équipes métier.
L'intérêt est de d'améliorer et de fluidifier la communication dans les échanges lors des réunions en évitant les mapping de type "nous on appel ceci comme cela". Il aide à la compréhension du fonctionnel pour les développeurs mais aide aussi les stackholders à comprendre l'implantation et potentiellement y voir des erreurs ou avoir des idées d'améliorations.
Il est également utilisé dans les documents et dans le code, permettant de faciliter l'arrivée de nouveaux développeurs qui peuvent faire un lien naturel entre les fonctionnalités et le code existant

Mon avis personnel est qu'il n'y a aucune raison de ne pas utiliser l'ubiquitous language.

####Bounded context
La notion de Bounded context est le principe de segmenter par des frontières différents "modèles" d'une application (par exemple la gestion de vente et la gestion de stock dans un site e-commerce).
D'un point de vue implémentation ces frontières peuvent correspondre à séparer différentes équipes, différentes infrastructures, ou différents modules de la même application.
Il faut cibler la consistance dans chaque bounded context sans être impacté par les problèmes arrivant dans les autres bounded context.

Une très bonne pratique à systématiser lorsque vous avez une équipe ou une application d'une certaine taille, je dirais à partir de 5/6 développeurs ou une application développée sur plus de 6 mois.



###Strategic part, the optionnal part

Pour rappel la partie stratégique de DDD est tout ce qui est relatif à l'implémentation, l'usage des notions de Value, Aggregate, Entity, Repository, Service, ... Cela correspond à des pratiques et principes bien précis pour ne pas dire une philosophie de conception de développement.

Sans revenir en détail sur ces principes, disons qu’ils sont souvent montrés pas les adeptes du DDD comme "la" bonne approche pour les applications complexes (non-CRUD).

Une seule approche pour résoudre toutes les problématiques applicatives ? Cette réflexion n'est pas raisonnable car certaines applications ont des contraintes bien spécifiques qui ne sont pas forcément compatibles avec l'approche DDD.
Par exemple en DDD on a une transactionalité au niveau de l'aggregate root imposant de charger tout l'aggregate root pour faire des modifications dessus ou encore une "persistance ignorance" du domaine. Ce qui n'est pas compatible avec tous les besoins technique applicatifs.

C'est d'ailleurs pour cette raison qu'il existe des approches dérivées comme DDD lite.

###DDD or no DDD?

DDD reste une approche très intéressante et très intelligente, néanmoins prenez bien le temps d'en comprendre les tenants et aboutissants et de voir si cela correspond à votre application et ses contraintes avant de l'appliquer.

Et surtout n'écoutez pas aveuglement les prophètes des patterns aujourd'hui qui seront peut-être les anti-patterns de demain.

    The main problem of gurus is to sell themselves

[La vidéo ici](http://vimeo.com/user22258446/review/110669987/e7de3170e7)

##Let software design come to life using software cells

Une session de Ralf Westphal @ralfwen sur une façon light de représenter et de schématiser les architecture logicielles.

Petit rappel de Ralf avant de commencer :

    N-layer aren't encapsulation!


###Just a circle!

    We are so obsessed of details, don't use UML but start at a high level with a simple piece of paper

La technique est simple, oublier les outils lourds et les méthodes torturée, prenez un bout de papier (ou de serviette en papier) et faites un cercle !

![Circle][softarch14-software-cells-circle]

###Your system

    1 paper then 1 circle: boundary between the system and the environment

Ce cercle est la séparation entre votre système et votre environnement, ce que je maitrise et ce que je ne maitrise pas.
    
![System][softarch14-software-cells-system]


###Not circles, cells !

Imaginez maintenant que votre cercle est en fait une cellule, elle comporte une membrane (api) et un noyau (domaine) et entre les 2 une commination par adapter.

![Adapter][softarch14-software-cells-adapter]


###Actors

Ensuite vous pouvez avoir des acteurs qui interagissent avec votre "cellule système"

![Actor][softarch14-software-cells-actors]


Avec une vision détaillée de la membrane jusqu'au noyau.

![Actor détail][softarch14-software-cells-actors2]


###Resources

De la même façon votre cellule noyau peut s'appuyer sur des ressources.
![Resource][softarch14-software-cells-resources]

Avec une communication légèrement différente des acteurs.

![Resource détail][softarch14-software-cells-resources2]

###Cells everywhere

Maintenant ce qui devient intéressant c'est d'imaginer votre système non pas comme une cellule mais des cellules avec chacune leur couche de communication et noyau.

###Todo list

Une fois cette représentation en place on peut se poser les bonnes questions "ou va tel traitement métier ?", "qu'est ce qu'on fait comme adapter ici ?", etc ...
Et on peut se créer des todo list sur le schéma.

![Todo][softarch14-software-cells-todo]

###Cell split

Ensuite on peut aussi faire des splits, comme par exemple pour faire de la scalabilité.

    Cell split is possible for technical reason (scale, resources) horizontally

![Split tech][softarch14-software-cells-split1]

Ou encore pour séparer fonctionnellement l'application

    Divide system vertically to separate actors that will access shared resources. Conduct to simplicity of maintenance and choice to use different platform

![Split func][softarch14-software-cells-split2]

###Cells or UML

J'espère que vous avez apprécié cette technique de modélisation par cellules et que vous allez lâcher ce satané UML à la fois lourd et mal utilisé.
On avait 10% d'utilisateur d'UML dans la salle donc on est sur le bon chemin ! 

![Final][softarch14-software-cells-final]

Et je vous conseille de ne pas faire tous vos cercles sur le même paper board si vous voulez vous y retrouver !

[La vidéo ici](http://vimeo.com/user22258446/review/110984589/6c927cfb79)

##Conclusion

Voilà, c'était mon retour sur la conférence Software Architect 2014. J'espère que vous y avez vu des pistes intéressantes à creuser.
Vous pouvez retrouver les différentes sessions en vidéo sur le site officiel de la conférence : [http://software-architect.co.uk/][softarch14-website]

[softarch14-website]: http://software-architect.co.uk/

[softarch14-this-is-water-func-programming]: https://onedrive.live.com/download?resid=EEE66E4387AB62A!233866&authkey=!ACvZrspKtUkA4Pg&v=3&ithint=photo%2cjpg

[softarch14-death-of-agile-scrum-master]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233867&authkey=!ADmN4rA87ncRGZM&v=3&ithint=photo%2cjpg

[softarch14-death-of-agile-agile-killers]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233868&authkey=!AH22Bw-lPwE4ljE&v=3&ithint=photo%2cjpg

[softarch14-death-of-agile-companies]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233869&authkey=!AKrW0O0HtRUKo8o&v=3&ithint=photo%2cjpg

[softarch14-microservices-scalability]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233870&authkey=!ALP3sORXJTIvHBc&v=3&ithint=photo%2cjpg

[softarch14-microservices-polyglot]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233871&authkey=!AKZeVNoY01pKmCE&v=3&ithint=photo%2cjpg

[softarch14-emergent-design-unknown-unknowns]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233874&authkey=!AOP2pkmAVptlyOk&v=3&ithint=photo%2cjpg

[softarch14-emergent-design-idiomatic-patterns]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233875&authkey=!AHwzCJYmEKATXVw&v=3&ithint=photo%2cjpg

[softarch14-emergent-design-sonar]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233873&authkey=!AGtQab8q5F_rbiw&v=3&ithint=photo%2cjpg

[softarch14-emergent-design-predictive]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233872&authkey=!ANQVGnleTPysEVY&v=3&ithint=photo%2cjpg

[softarch14-architecture-review-conceptual-integrity]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233880&authkey=!AJjkrIUamA95m-8&v=3&ithint=photo%2cjpg

[softarch14-architecture-review-costs]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233879&authkey=!AASbHHPSTnm3KHQ&v=3&ithint=photo%2cjpg

[softarch14-architecture-review-usability]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233878&authkey=!ACVA8kYlcQQcOUs&v=3&ithint=photo%2cjpg

[softarch14-architecture-review-performances]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233877&authkey=!AGfiHl6C_ouN_Hw&v=3&ithint=photo%2cjpg

[softarch14-architecture-review-forces]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!233876&authkey=!AMqc8j1pxVSNO5E&v=3&ithint=photo%2cjpg

[softarch14-software-cells-circle]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234643&authkey=!APphJUOlQSIe14A&v=3&ithint=photo%2cjpg

[softarch14-software-cells-system]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234638&authkey=!AOg89Yc-kQNJyc0&v=3&ithint=photo%2cjpg

[softarch14-software-cells-actors]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234646&authkey=!AFnbhRLCrPZ6fPg&v=3&ithint=photo%2cjpg

[softarch14-software-cells-resources]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234641&authkey=!APnS0Nu1A8cUjZY&v=3&ithint=photo%2cjpg

[softarch14-software-cells-adapter]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234644&authkey=!AEoELuAjj9Cidas&v=3&ithint=photo%2cjpg

[softarch14-software-cells-actors2]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234645&authkey=!AEMi8zSbv0tzeU4&v=3&ithint=photo%2cjpg

[softarch14-software-cells-resources2]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234640&authkey=!AMTDi3l5P4jzIec&v=3&ithint=photo%2cjpg

[softarch14-software-cells-split1]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234639&authkey=!ALkB4NSxrPzss1g&v=3&ithint=photo%2cjpg

[softarch14-software-cells-split2]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234637&authkey=!AMBXZRP9qHrjJ_A&v=3&ithint=photo%2cjpg

[softarch14-software-cells-final]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234642&authkey=!AElcI7zsOmZm6qk&v=3&ithint=photo%2cjpg

[softarch14-software-cells-todo]:https://onedrive.live.com/download?resid=EEE66E4387AB62A!234636&authkey=!AAesaKhovfZcemc&v=3&ithint=photo%2cjpg


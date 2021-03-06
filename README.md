iris-python-faker
====

Python Faker library through Embedded Python support in InterSystems IRIS with UI

[Online Demo](https://faker.demo.community.intersystems.com/faker/index.html)

What is Faker
----

Faker helps to generate some fake data, but similar to real data. While InterSystems's Populate can only generate only very random text just from letters or numbers. Faker has many realizations for some other languages, such as NodeJS, PHP, Perl, Ruby. And this project uses Python's realization with embedded Python feature in IRIS.

Python Faker has

- 80+ locales, so, generated data, can be almost any language English, Russian, Chineese. Person names, Addresses and many other values can be localized
- 20+ [providers](https://faker.readthedocs.io/en/master/providers.html) for many different types of data. Not everything is implemented in this project, yet, just some basic ones.
- [community providers](https://faker.readthedocs.io/en/master/communityproviders.html) can be added later as well

![screenshot](https://raw.githubusercontent.com/caretdev/iris-python-faker/main/images/main.png)

Prerequisites
----

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Docker](https://www.docker.com/products/docker-desktop) with [BuildKit](https://docs.docker.com/develop/develop-images/build_enhancements/) support

Installation
----

Clone/git pull the repo into any local directory

```shell
git clone https://github.com/caretdev/iris-python-faker.git
```

Open the terminal in this directory and run the command to build and run IRIS container:

```shell
DOCKER_BUILDKIT=1 docker-compose up --build -d
```

Check the port selected for web by Docker with command

```shell
docker-compose ps
```

And open in the browser http://localhost:52773/faker/index.html (Replace 52773 port with port from ps's output). Or from menu in VSCode.

![menu](https://raw.githubusercontent.com/caretdev/iris-python-faker/main/images/menu.png)

Install with ZPM
----

The package is available to be installed with zpm.

```objectscript
zpm "install python-faker"
```

It requires IRIS version with Python Embedded feature (2021.2+) and package faker installed with [python-pip](https://docs.intersystems.com/iris20212/csp/docbook/DocBook.UI.Page.cls?KEY=AEPYTHON).

Usage UI
----

Add rows to table, as many as many columns you need in generating table. Select datatypes from the list of available types, and enter name for colummn.

![select-datatype](https://raw.githubusercontent.com/caretdev/iris-python-faker/main/images/select-datatype.png)

On the bottom toolbar, you can select Locale, and change the amount of preview rows to be generated on each change.

![select-locales](https://raw.githubusercontent.com/caretdev/iris-python-faker/main/images/select-locales.png)

Generate button, will open a dialog, where you will be able to enter how many rows to generate and desired class name. If you wish to add data to an existing class uncheck `Create class`. In case of any errors happend on the server side during generation, it will show the error message.

![generate-failed](https://raw.githubusercontent.com/caretdev/iris-python-faker/main/images/generate-failed.png)

![generate-success](https://raw.githubusercontent.com/caretdev/iris-python-faker/main/images/generate-success.png)

Usage programmatical
----

It is also possible to generate new data programmatically

```objectscript
  Set params = {
    "rows": 3,                // How many rows generate
    "className": (className), // Where to store generated data
    "locale": "en",           // Select Locale for generated data
    "columns": [{
      "type": "person_name",
      "name": "name"
    }, {
      "type": "date_of_birth",
      "name": "dob"
    }, {
      "type": "boolean",
      "name": "flag"
    }]
  }
  Set faker = ##class("caretdev.Faker.Main").%New()
  Do faker.%JSONImport(params)
  Quit:'$$$AssertStatusOK(faker.GenerateClass())
  Do $ClassMethod(className, "%KillExtent")

  Set result = faker.Generate()
  If $Extract(result)=0 Do $system.OBJ.DisplayError(result)
  Write !,"Rows created",result.created
```

Or just generate without saving to class

```objectscript
  Set params = {
    "previewRows": 3,         // How many items generate
    "locale": "en",           // Select Locale for generated data
    "columns": [{
      "type": "person_name",
      "name": "name"
    }, {
      "type": "date_of_birth",
      "name": "dob"
    }, {
      "type": "boolean",
      "name": "flag"
    }]
  }
  Set faker = ##class("caretdev.Faker.Main").%New()
  Do faker.%JSONImport(params)

  Set result = faker.Generate()
  If $Extract(result)=0 Do $system.OBJ.DisplayError(result)
  Set items = result."__getitem__"("items")
  Set count = items."__len__"()
  For i=0:1:count-1 {
    Set item = items."__getitem__"(i)
    Set name = item."__getitem__"("name")
    Set dob = item."__getitem__"("dob")
    Set flag = item."__getitem__"("flag")
  }
```

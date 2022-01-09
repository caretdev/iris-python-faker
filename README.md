iris-python-faker
====

Python Faker library through Embedded Python support in InterSystems IRIS with UI

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

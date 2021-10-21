# Interoperability Read Only access 

In companies, most of the time, we have test, stage and production environments.

It is very common that we, the developers, do not have the right to modify or touch the production directly because all the modifications must be traced in a versioning tool and tested before a production release.

However, a read access to the production (especially to the traces) can allow us to better understand a possible bug.

That's why I propose this ZPM module that creates a new role in IRIS that allows access to the productions and this only in read-only with access to the visual traces.

![Oct-21-2021 16-52-18](https://user-images.githubusercontent.com/47849411/138303293-413fdf5d-4138-4ce2-a5d8-c9227a89d267.gif)

<!--break-->
## iris-readonly-interop

This is a simple install of a new role : #Ready_Only_Interop.

The objective of this role is to visualize:

- the traces
- the productions
- the business process
- the business rules
- DTLs
- Records Maps
- ...

In a secure way, no action is permitted.
## Installation: ZPM

Open IRIS Namespace with Interoperability Enabled.
Open Terminal and call:

```
zpm "install readonly-interoperability"
```
## Demo

You can have a demo of this role, from this git repository.

Use the user **Viewer** with password **SYS**.

### Installation: Docker
Clone/git pull the repo into any local directory

```
$ git clone https://github.com/intersystems-community/iris-interoperability-template.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

### How to Run the Sample

Open the [production](http://localhost:52795/csp/irisapp/EnsPortal.ProductionConfig.zen?$NAMESPACE=IRISAPP&IRISUserName=Viewer&IRISPassword=SYS).
With this link you will able to visualize but not modify any thing.
![prodimg](https://raw.githubusercontent.com/grongierisc/iris-readonly-interop/master/misc/ProductionReadOnly.png)

See traces : [trace](http://localhost:52795/csp/irisapp/EnsPortal.MessageViewer.zen?SOURCEORTARGET=dc.Demo.RedditService&IRISUserName=Viewer&IRISPassword=SYS)
![traceimg](https://raw.githubusercontent.com/grongierisc/iris-readonly-interop/master/misc/AcccessToTrace.png)

Example :

![Oct-21-2021 16-52-18](https://user-images.githubusercontent.com/47849411/138303293-413fdf5d-4138-4ce2-a5d8-c9227a89d267.gif)

## Challange

The challange was from the SQL privileges to enable the message viewer.

This part was quiet tricky, because all the SQL privileges have to be promoted by hand of each Interoperabilty Namespace.

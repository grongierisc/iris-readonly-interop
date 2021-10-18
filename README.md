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
With this link you will able to visualize but not modifiy any thing.

See traces : [trace](http://localhost:52795/csp/irisapp/EnsPortal.MessageViewer.zen?SOURCEORTARGET=dc.Demo.RedditService&IRISUserName=Viewer&IRISPassword=SYS)

Example :

[demo](https://user-images.githubusercontent.com/47849411/137723222-e44737ba-7492-45d3-ae14-5c6fc07cd454.mp4)

## Challange

The challange was from the SQL privileges to enable the message viewer.

This part was quiet tricky, because all the SQL privileges have to be promoted by hand of each Interoperabilty Namespace.

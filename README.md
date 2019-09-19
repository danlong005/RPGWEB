# README

## Description
A small RPGLE web framework for building web api's on the IBM i.

## Local Setup
In QShell
```
cd /
git clone ....
```

Then exit QShell and run the following CL command
```
QSYS/CRTBNDCL PGM([YOURLIB]/BUILD)
              SRCSTMF('/RPGWEB/build.clle')
```

Then you can run the build script to create the RPGWEB library, and all of the 
programs, and include files.
```
CALL YOURLIB/BUILD
```

That's it!!! Now you are ready to write completely RPGLE web api's. Here is 
an example. 

For getting started quickly here is a small quick start guide

[Quick Start](QuickStart.md)

Here is the full documentation for the library.

[Api Documentation](ApiDocumentation.md)
# README

## Description
A small RPGLE web framework for building web api's on the IBM i.

## Installation
In QShell
```
cd /
git clone ....
```

Then exit QShell and run the following CL command
```
QSYS/CRTBNDCL PGM([YOURLIB]/BUILD)                        
              SRCSTMF('/downloaded/location/RPGAPI/build.clle')
              DBGVIEW(*SOURCE)                         
```

If you cannot compile CL's from the IFS on your machine, use the following command to copy the build program to a source member. Then use the CHGPFM command to make it a CL. Then compile as normal.
```
CPYFRMSTMF FROMSTMF('/downloaded/location/RPGAPI/BUILD.CLLE')
           TOMBR('/QSYS.LIB/[YOURLIB].LIB/QCLSRC.FILE/BUILD.MBR')

CHGPFM FILE([YOURLIB]/QCLSRC) MBR(BUILD) SRCTYPE(CLLE)
```

Then you can run the build script to create the RPGAPI library, and all of the 
programs, and include files.
```
CALL [YOURLIB]/BUILD PARM('/downloaded/location')
```

That's it!!! Now you are ready to write completely RPGLE web api's. Check the 
Quick start guide for a quick intro.

For getting started quickly here is a small quick start guide

[Quick Start](QuickStart.md)

Here is the full documentation for the library.

[Api Documentation](ApiDocumentation.md)
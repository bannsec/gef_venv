# Overview
This is a wrapper script to install the GDB Enhanced Features toolkit into a python virtual environment. It also installs libdislocator and exploitable and enables GEF analysis modules by default on start.

# Install
First, ensure you're in a virtual environment. The installer script will check and warn you if your python version mismatches with GDB's. Then, just run the installer:

```bash
(venv) $ ./install_gef.sh
```

It will compile and install stuff into your virtual environment. Nothing will be installed external to it.

# Running
This installer creates a wrapper named `gef`. So it's as simple as activating your virtual environment and replacing `gdb` with `gef`.

```bash
$ workon myenv
(myenv) $ gef ./a.out test
```

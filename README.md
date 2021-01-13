# About
An easy way to create Inno Setup installer packages for Microsoft Windows
directly from your Linux or macOS box.

## Provided core packages
This image provides the following core packages in addition to the ones
contained in the parent images:

- [Inno Setup](http://www.jrsoftware.org/isinfo.php) (Unicode version)

# Usage
Run in interactive mode with your source root bound to `/work`; specify your
setup script as the command:

```sh
docker run --rm -i -v $PWD:/work amake/innosetup helloworld.iss
```

Put the following wrapper script in your PATH as e.g. `iscc` to be able to run
just `iscc helloworld.iss`:

```sh
#!/usr/bin/env bash

exec docker run --rm -i -v $PWD:/work amake/innosetup "$@"
```

## Important notes
Be aware that depending on how you mount your code into the container, files
referenced by the setup script may or may not be "visible" within the
container. You probably want to make sure all referenced files are at or below
the directory your script is in. The same applies to the output.

# Known issues
## Wine, X11-related warnings and errors
This image pulls some tricks to get wine and Inno Setup installed and working
headlessly. This results in some yucky looking logs, but it seems to work
anyway.

# Does it work?
Yes. Unlike the various other, similar repos for Dockerized Inno Setup I found
on and around 2019-3-12, this one actually works.

# See also
An article about how to use this as part of a complete editing/building/signing
workflow: [Inno Setup on Linux and
macOS](https://gist.github.com/amake/3e7194e5e61d0e1850bba144797fd797)

# Use Inno Setup Download Plugin
Use the following command at the beginning of the file:

```
#include <C:\Program Files\Inno Download Plugin\idp.iss>
```
## mapnik-gyp

GYP build system for Mapnik 3.x.

[![Build Status](https://travis-ci.org/mapnik/mapnik-gyp.svg?branch=master)](https://travis-ci.org/mapnik/mapnik-gyp)

### Depends

  - Mapnik SDK
  - Mapnik 3.x

### Usage

First build all mapnik dependencies.

 - **Linux/OS X:** Use https://github.com/mapnik/mapnik-packaging
 - **Windows:** Use https://github.com/mapbox/windows-builds

NOTE: these projects are moving fast so expect things to break.

Then build Mapnik:

```sh
git clone https://github.com/mapnik/mapnik.git
cd mapnik
git clone https://github.com/mapnik/mapnik-gyp.git
cd mapnik-gyp
./build.sh  # or .\build on windows
```


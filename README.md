## mapnik-gyp

GYP build system for Mapnik 3.x.

### Depends

  - Mapnik SDK
  - Mapnik 3.x

### Usage

First build all mapnik dependencies.

 - Windows: Use https://github.com/BergWerkGIS/mapnik-dependencies
 - Linux/OS X: Use https://github.com/mapnik/mapnik-packaging

NOTE: these projects are moving fast so expect things to break.

Then build Mapnik:

```sh
git clone https://github.com/mapnik/mapnik.git
cd mapnik
git https://github.com/mapnik/mapnik-gyp.git
cd mapnik-gyp
build
```

NOTE: currently paths to mapnik-deps are hardcoded - this will be fixed in the future.


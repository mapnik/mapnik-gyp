#!/usr/bin/env bash

set -u

export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#cd ${ROOTDIR}

BASE_PATH=$(pwd)/mapnik-sdk

if [[ ! -d mapnik-sdk ]]; then
    ln -s ~/projects/mapnik-packaging/osx/out/build-cpp11-libcpp-x86_64-macosx ${BASE_PATH}
fi

if [[ ! -d gyp ]]; then
    git clone https://chromium.googlesource.com/external/gyp.git gyp
fi

export PATH=${BASE_PATH}/bin:$PATH
export PKG_CONFIG_PATH=${BASE_PATH}/lib/pkgconfig

rm -rf unix-build
rm -rf ./Release

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

COVERITY=false

if [[ $COVERITY == true ]];then
  ./gyp/gyp ./mapnik.gyp \
    --depth=. \
    -f make \
    --generator-output=./unix-build \
    -Dincludes=${BASE_PATH}/include \
    -Dconfiguration=Release \
    -Dlibs=${BASE_PATH}/lib \
    --no-duplicate-basename-check

  export PATH=${HOME}/cov-analysis-macosx-7.5.0/bin/:$PATH

  RESULTS_DIR="$(pwd)/cov-int"
  mkdir -p $RESULTS_DIR
  rm -rf $RESULTS_DIR/*
  # https://scan.coverity.com/download
  # https://scan.coverity.com/projects/3237/builds/new
  rm -f ${HOME}/cov-analysis-macosx-7.5.0/config/templates/.DS_Store
  cov-configure --template --compiler clang
  # --comptype clangcxx
  cov-build -dir $RESULTS_DIR make -C ./unix-build/ mapnik -j1 V=1
  rm -f mapnik-coverity.tgz
  DESCRIBE=$(git --git-dir=../.git describe)
  # NOTE: cov-int must be relative name not absolute
  tar czf mapnik-coverity.tgz cov-int
  curl --form token=${COVERITY_TOKEN} \
    --form email=dane@mapbox.com \
    --form file=@mapnik-coverity.tgz \
    --form version="${DESCRIBE}" \
    --form description="Mapnik 3.x alpha build" \
    https://scan.coverity.com/builds?project=mapnik%2Fmapnik
else
  if [[ ! -f ninja ]]; then
      git clone git://github.com/martine/ninja.git
      ./bootstrap.py
      cd ../
  fi

  ./gyp/gyp ./mapnik.gyp \
      --depth=. \
      -f ninja \
      -Dincludes=${BASE_PATH}/include \
      -Dconfiguration=Release \
      -Dlibs=${BASE_PATH}/lib \
      --no-duplicate-basename-check
  ninja/ninja -C out/Release/
fi

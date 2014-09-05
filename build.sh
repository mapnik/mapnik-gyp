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

./run_gyp ./mapnik.gyp \
  --depth=. -Goutput_dir=.. \
  -Dincludes=${BASE_PATH}/include \
  -Dlibs=${BASE_PATH}/lib \
  --generator-output=./build/ \
  -f make \
  --no-duplicate-basename-check

make -C ./build/ V=1 mapnik -j2

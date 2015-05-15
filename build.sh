#!/usr/bin/env bash

set -eo pipefail

export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ../bootstrap.sh

BASE_PATH="$(cd $(pwd)/../mason_packages/.link && pwd)"

# gyp
if [[ ! -d gyp ]]; then
    git clone --depth=1 https://chromium.googlesource.com/external/gyp.git gyp
fi

export PATH=${BASE_PATH}/bin:$PATH
export PKG_CONFIG_PATH=${BASE_PATH}/lib/pkgconfig

if [[ "${COVERITY:-unset_val}" == "unset_val" ]]; then
    COVERITY=false
fi

if [[ "${CONFIGURATION:-unset_val}" == "unset_val" ]]; then
    CONFIGURATION="Release"
fi

rm -rf ./unix-build
rm -rf ./${CONFIGURATION}

COVERITY_VERSION="7.6.0"

if [[ ${COVERITY} == 1 ]];then
  export CC=/usr/bin/clang
  export CXX=/usr/bin/clang++
  ./gyp/gyp ./mapnik.gyp \
    --depth=. \
    -f make \
    --generator-output=./unix-build \
    -Dincludes=${BASE_PATH}/include \
    -Dconfiguration=${CONFIGURATION} \
    -Dlibs=${BASE_PATH}/lib

  export PATH=${HOME}/cov-analysis-macosx-${COVERITY_VERSION}/bin/:$PATH

  RESULTS_DIR="$(pwd)/cov-int"
  mkdir -p $RESULTS_DIR
  rm -rf $RESULTS_DIR/*
  # https://scan.coverity.com/download
  # https://scan.coverity.com/projects/3237/builds/new
  rm -f ${HOME}/cov-analysis-macosx-${COVERITY_VERSION}/config/templates/.DS_Store
  cov-configure --template --compiler clangcc --comptype clangcxxcc
  cov-build -dir $RESULTS_DIR make -C ./unix-build/ mapnik -j4 V=1
  rm -f mapnik-coverity.tgz
  DESCRIBE=$(git --git-dir=../.git describe)
  # NOTE: cov-int must be relative name not absolute
  tar czf mapnik-coverity.tgz cov-int
  curl --form token=${COVERITY_TOKEN_MAPNIK} \
    --form email=dane@mapbox.com \
    --form file=@mapnik-coverity.tgz \
    --form version="${DESCRIBE}" \
    --form description="Mapnik 3.x alpha build" \
    https://scan.coverity.com/builds?project=mapnik%2Fmapnik
elif [[ ${SCAN} == 1 ]]; then
    #rm -rf ./scan-static-build
    scan-build \
     --use-analyzer=/opt/llvm/bin/clang++ \
     ./gyp/gyp ./mapnik.gyp \
    --depth=. \
    -f make \
    --generator-output=./scan-static-build \
    -Dincludes=${BASE_PATH}/include \
    -Dconfiguration=Debug \
    -Dlibs=${BASE_PATH}/lib

    scan-build \
     --use-analyzer=/opt/llvm/bin/clang++ \
     make -C ./scan-static-build/ mapnik -j4
else
  if [[ ! -d ninja ]]; then
      git clone --depth=1 git://github.com/martine/ninja.git
  fi
  if [[ ! -f ninja/ninja ]]; then
      cd ninja
      ./bootstrap.py
      cd ../
  fi

  ./gyp/gyp ./mapnik.gyp \
      --depth=. \
      -f ninja \
      -Dincludes=${BASE_PATH}/include \
      -Dconfiguration=${CONFIGURATION} \
      -Dlibs=${BASE_PATH}/lib
   # serial build of memory intensive things first
   time ninja/ninja -C out/${CONFIGURATION}/ mapnik-wkt -j1
   time ninja/ninja -C out/${CONFIGURATION}/ mapnik-json -j1
   # remainder of mapnik
   time ninja/ninja -C out/${CONFIGURATION}/ -j12 -l 2
fi

#!/usr/bin/env bash

#set -u

export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BASE_PATH="$(pwd)/mapnik-sdk"

if [[ $(uname -s) == 'Darwin' ]]; then
    SLUG="mapnik-macosx-sdk-v2.2.0-2235-gb907634-lto"
else
    SLUG="mapnik-linux-sdk-v2.2.0-2235-gb907634"
fi

# mapnik sdk
LOCAL_SDK="$HOME/projects/mapnik-package-lto/osx/out/dist/${SLUG}"

echo "looking for ${LOCAL_SDK}"
if [[ -d ${LOCAL_SDK} ]]; then
    echo "found ${LOCAL_SDK}"
    rm -f ./mapnik-sdk
    ln -s ${LOCAL_SDK} ${BASE_PATH}
elif [[ ! -d ${BASE_PATH} ]]; then
    if [[ ! -f ${SLUG}.tar.bz2 ]]; then
        echo "downloading https://mapnik.s3.amazonaws.com/dist/dev/${SLUG}.tar.bz2"
        wget https://mapnik.s3.amazonaws.com/dist/dev/${SLUG}.tar.bz2
    fi
    if [[ ! -f ${SLUG} ]]; then
        echo  "untarring ${SLUG}.tar.bz2"
        tar xf ${SLUG}.tar.bz2
    fi
    ln -s ./${SLUG} ${BASE_PATH}
fi

# gyp
if [[ ! -d gyp ]]; then
    git clone --depth=1 https://chromium.googlesource.com/external/gyp.git gyp
fi

export PATH=${BASE_PATH}/bin:$PATH
export PKG_CONFIG_PATH=${BASE_PATH}/lib/pkgconfig

rm -rf ./unix-build
rm -rf ./Release

if [[ "${COVERITY:-unset_val}" == "unset_val" ]]; then
    COVERITY=false
fi

if [[ "${CONFIGURATION:-unset_val}" == "unset_val" ]]; then
    CONFIGURATION="Release"
fi

if [[ $COVERITY == true ]];then
  #export CC=/usr/bin/clang
  #export CXX=/usr/bin/clang++
  ./gyp/gyp ./mapnik.gyp \
    --depth=. \
    -f make \
    --generator-output=./unix-build \
    -Dincludes=${BASE_PATH}/include \
    -Dconfiguration=${CONFIGURATION} \
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
      -Dlibs=${BASE_PATH}/lib \
      --no-duplicate-basename-check
   # serial build of memory intensive things first
   time ninja/ninja -C out/Release/ mapnik_wkt -j2  -l 2
   time ninja/ninja -C out/Release/ mapnik_json -j2  -l 2
   # remainder of mapnik
   time ninja/ninja -C out/Release/ -j12 -l 2
fi

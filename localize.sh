#!/bin/bash
UNAME=$(uname -s)
export CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ ${UNAME} = 'Darwin' ]; then
    export DYLD_LIBRARY_PATH="${CURRENT_DIR}/out/Release/lib/":${DYLD_LIBRARY_PATH}
else
    export LD_LIBRARY_PATH="${CURRENT_DIR}/out/Release/lib/":${LD_LIBRARY_PATH}
fi
export PYTHONPATH="${CURRENT_DIR}/out/Release/lib/python2.7/":$PYTHONPATH
export MAPNIK_FONT_DIRECTORY="${CURRENT_DIR}/../fonts/dejavu-fonts-ttf-2.34/ttf/"
export MAPNIK_INPUT_PLUGINS_DIRECTORY="${CURRENT_DIR}/out/Release/lib/mapnik/input/"
export PATH="${CURRENT_DIR}/out/Release/bin/":${PATH}
#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: YML_FILE=$1"
    exit 1
fi

YML_FILE="$1"
GEN_CORE_NAME="${DESIGN_NAME}_build"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "Setting up $DESIGN_NAME..."

cd "$LITEETH_DIR/dev"

source "$LITEETH_DIR/dev/.venv/bin/activate"

[ -d $LITEETH_DIR/dev/build ] && rm -rf build && echo "Cleaning previous build..."

python3 $LITEETH_DIR/dev/repo/liteeth/gen.py $YML_PATH/$YML_FILE && echo "Generating liteeth core..."

cp $LITEETH_DIR/dev/build/gateware/liteeth_core.v $LITEETH_DIR/$DESIGN_NAME.v && echo "Copying verilog files..."

ARCHIVE_DIR=$LITEETH_DIR/dev/$BUILD_DIR_NAME/${GEN_CORE_NAME}_${TIMESTAMP}
mkdir -p $ARCHIVE_DIR
cp -r $LITEETH_DIR/dev/build/* $ARCHIVE_DIR/ && echo "Build archived in $ARCHIVE_DIR"

[ -d $LITEETH_DIR/dev/build ] && rm -rf build
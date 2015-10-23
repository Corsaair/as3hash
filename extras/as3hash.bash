#!/bin/bash

function follow_links() {
  file="$1"
  while [ -h "$file" ]; do
    # On Mac OS, readlink -f doesn't work.
    file="$(readlink "$file")"
  done
  echo "$file"
}

# Unlike $0, $BASH_SOURCE points to the absolute path of this file.
PROG_NAME="$(follow_links "$BASH_SOURCE")"

# Handle the case where the program has been symlinked to.
CUR_DIR="$(cd "${PROG_NAME%/*}" ; pwd -P)"

UNAME="$(uname)"
BITS="32"
EXT=""

# REDTAMARIN_SDK env var not found
if [ -z "$REDTAMARIN_SDK" ]; then
    REDTAMARIN_SDK="$(dirname "$CUR_DIR")";
fi

if [ $UNAME == "Darwin" ]; then
    OS="macintosh";
elif [ $UNAME == "Linux" ]; then
    OS="linux"
elif [ "$(uname -o)" == "Cygwin" ]; then
#elif [ "$(uname -s)" == CYGWIN* ]; then
    OS="windows"
    EXT=".exe"
fi

if [ "$(uname -m)" == "x86_64" ]; then
    BITS="64"
fi

BIN="$CUR_DIR/as3hash-$OS$EXT"

#echo "PROG_NAME=$PROG_NAME";
#echo "CUR_DIR=$CUR_DIR";
#echo "REDTAMARIN_SDK=$REDTAMARIN_SDK";
#echo "OS=$OS";
#echo "BITS=$BITS"
#echo "BIN=$BIN";

exec "$BIN" -- "$@";

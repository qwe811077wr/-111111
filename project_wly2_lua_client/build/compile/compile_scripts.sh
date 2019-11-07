#!/bin/bash
export LUA_PATH="../bin/mac/?.lua;;"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
php "$DIR/lib/compile_scripts.php" $*

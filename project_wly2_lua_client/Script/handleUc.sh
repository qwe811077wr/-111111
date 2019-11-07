#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd  )"
DIR=$SCRIPT_DIR/../output
apkName=$1
apktool d $1 -o $SCRIPT_DIR/temp
sed -i "" "/- luac/d" $SCRIPT_DIR/temp/apktool.yml
$SCRIPT_DIR/decodeLua -d $SCRIPT_DIR/temp/assets/src/config.luac $SCRIPT_DIR/temp/assets/src/config.lua
python $SCRIPT_DIR/Set_Logo.py $SCRIPT_DIR/temp/assets/src/config.lua 2
$SCRIPT_DIR/decodeLua -e $SCRIPT_DIR/temp/assets/src/config.lua $SCRIPT_DIR/temp/assets/src/config.luac
apktool b $SCRIPT_DIR/temp -o $SCRIPT_DIR/temp.apk
curTime=`date "+%m-%d-%H-%M"`
jarsigner -verbose -keystore "${SCRIPT_DIR}/../frameworks/runtime-src/keystore/uqee.keystore" -storepass "2dxLua" -keypass  "2dxLua" -signedjar  "${DIR}/yijie_release_${curTime}_UC.apk" $SCRIPT_DIR/temp.apk "uqeekey"
rm -rf $SCRIPT_DIR/temp
rm -rf $SCRIPT_DIR/temp.apk
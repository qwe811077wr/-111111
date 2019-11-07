#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd  )"
DIR=$SCRIPT_DIR/..

version="$1"
echo $version
mkdir $DIR/$version

cp -rf $DIR/res $DIR/$version/
RES_PATH=$DIR/$version/res

rm -r "${RES_PATH}/img/login/lo_1.jpg" 
rm -r "${RES_PATH}/img/login/pic_background_jia_2.png" 
rm -r "${RES_PATH}/img/login/pic_background_jia_3.jpg" 
rm -r "${RES_PATH}/font/calibri.ttf" 
rm -r "${RES_PATH}/img/c/c0027.png" 
rm -r "${RES_PATH}/img/c/c0010.png" 
rm -r "${RES_PATH}/img/c/c0010.png" 
rm -r "${RES_PATH}/img/a/a0019.png" 
rm -r "${RES_PATH}/img/a/a0020.png" 
rm -r "${RES_PATH}/img/a/a0001.png" 
rm -r "${RES_PATH}/logo.png" 
rm -r "${RES_PATH}/logo_nonet.png" 
rm -r "${RES_PATH}/logoAd.jpg" 
rm -r "${RES_PATH}/data/keyword.lua" 
rm -r "${RES_PATH}/data/keyword/keyword.lua"
rm -r "${RES_PATH}/font" 
rm -r "${RES_PATH}/ui"
rm -r "${RES_PATH}/img/soldier" 

cd $DIR/$version
zip -r "res.zip" res
mv $DIR/$version/res.zip $DIR/${version}.zip
rm -rf $DIR/$version






#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd  )"
DIR=$SCRIPT_DIR/..
RES_PATH=$DIR/res
RES_BACK_PATH=$DIR/res_bak

if [ -d "${RES_BACK_PATH}" ];then
	rm -rf $RES_BACK_PATH
fi
mv $RES_PATH $RES_BACK_PATH
mkdir $RES_PATH
mkdir $RES_PATH/img
mkdir $RES_PATH/img/login
mkdir $RES_PATH/img/c
mkdir $RES_PATH/img/a
mkdir $RES_PATH/font
mkdir $RES_PATH/data
mkdir $RES_PATH/data/keyword

cp -r "${RES_BACK_PATH}/img/login/lo_1.jpg" "${RES_PATH}/img/login/lo_1.jpg"
cp -r "${RES_BACK_PATH}/img/login/pic_background_jia_2.png" "${RES_PATH}/img/login/pic_background_jia_2.png"
cp -r "${RES_BACK_PATH}/img/login/pic_background_jia_3.jpg" "${RES_PATH}/img/login/pic_background_jia_3.jpg"
# cp -r "${RES_BACK_PATH}/font/calibri.ttf" "${RES_PATH}/font/calibri.ttf"
cp -r "${RES_BACK_PATH}/img/c/c0027.png" "${RES_PATH}/img/c/c0027.png"
cp -r "${RES_BACK_PATH}/img/c/c0010.png" "${RES_PATH}/img/c/c0010.png"
cp -r "${RES_BACK_PATH}/img/c/c0010.png" "${RES_PATH}/img/c/c0010.png"
cp -r "${RES_BACK_PATH}/img/a/a0019.png" "${RES_PATH}/img/a/a0019.png"
cp -r "${RES_BACK_PATH}/img/a/a0020.png" "${RES_PATH}/img/a/a0020.png"
cp -r "${RES_BACK_PATH}/img/a/a0001.png" "${RES_PATH}/img/a/a0001.png"
cp -r "${RES_BACK_PATH}/logo.png" "${RES_PATH}/logo.png"
cp -r "${RES_BACK_PATH}/logo_nonet.png" "${RES_PATH}/logo_nonet.png"
cp -r "${RES_BACK_PATH}/logoAd.jpg" "${RES_PATH}/logoAd.jpg"
cp -r "${RES_BACK_PATH}/data/keyword.lua" "${RES_PATH}/data/keyword.lua"
cp -r "${RES_BACK_PATH}/data/keyword/keyword.lua" "${RES_PATH}/data/keyword/keyword.lua"

cp -r "${RES_BACK_PATH}/font" "${RES_PATH}/"
cp -r "${RES_BACK_PATH}/ui" "${RES_PATH}/"
cp -r "${RES_BACK_PATH}/img/soldier" "${RES_PATH}/img/"












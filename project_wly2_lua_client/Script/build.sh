#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd  )"
DIR=$SCRIPT_DIR/..
LUA_SRC=$DIR/src
LUA_SRC_BAK=$DIR/srcbak
LUA_SRC_SDK=$LUA_SRC/app/sdk
IOS_SDK=iphoneos11.2

REPORT=""
progressMsg(){
	REPORT="${REPORT}\n\033[33m STEP:$1 \033[0m"
}

successMsg(){
	REPORT="${REPORT}\n\033[32m SUCCESS:$1 \033[0m"
}

errorMsg(){
	REPORT="${REPORT}\n\033[31m ERROR:$1 \033[0m"
}

infoMsg(){
	REPORT="${REPORT}\n\033[36m INFO:$1 \033[0m"
}

while getopts a:i:o:ldcf arg
do
	case $arg in
		a)
			ANDROID_PACKAGENAME=$OPTARG
			;;
		c)
			CLEAN_PROJECT="clean"
			;;
		d)
			IS_DEBUG=true
			;;
		i)
			IOS_PACKAGENAME=$OPTARG
			;;
		l)
			BUILD_LIB=true
			;;
		o)
			OUTPUT_DIR=$OPTARG
			;;
		f)
			FPS_TRUE=true
			;;
		?)
			echo "help"
			echo "-c clean 工程"
			echo "-d debug 模式"
			echo "-o 选择输出目录"
			echo "-l 生成 prebuild"
			echo "-a 编译android包 渠道名称#渠道名称#渠道名称。\n例如: build.sh -a dev#uqee#yijie"
			echo "-i IOS打包 build.sh -i 渠道名称#渠道名称#渠道名称. \n例如: build.sh -i dev#aisi_ios#hmpay_ios"
			echo "-f lua 设置 config.lua CC_SHOW_FPS= true"
			exit 1
			;;
	esac
done


if [ -d  $LUA_SRC_BAK ];then
	rm -rf $LUA_SRC_BAK
fi

infoMsg "cp -rf $LUA_SRC $LUA_SRC_BAK"
cp -rf $LUA_SRC $LUA_SRC_BAK

if [ "${FPS_TRUE}" != "" ];then
	infoMsg "set config.lua CC_SHOW_FPS = false"
	python $SCRIPT_DIR/Set_Config_ShowFPS_False.py "${LUA_SRC}/config.lua" "true"
else
	infoMsg "set config.lua CC_SHOW_FPS = false"
	python $SCRIPT_DIR/Set_Config_ShowFPS_False.py "${LUA_SRC}/config.lua" "false"
fi


infoMsg "encode lua src"
$SCRIPT_DIR/decodeLua -f $LUA_SRC true


if [ "$OUTPUT_DIR" = "" ];then
	OUTPUT_DIR=$DIR/output
	if [ ! -d $OUTPUT_DIR ];then
		mkdir $OUTPUT_DIR
	fi
fi
infoMsg "output dir $OUTPUT_DIR"

if [ -d $DIR/archive ];then
	rm -rf $DIR/archive
fi
mkdir $DIR/archive


if [ "${IS_DEBUG}" != "" ];then
	NDK_DEBUG=1
	BUILD_TYPE="Debug"
	BUILD_TYPE2="debug"
else
	NDK_DEBUG=0
	BUILD_TYPE="Release"
	BUILD_TYPE2="release"
fi

while true
do
	#生成易接 IOS 包
	if [ "${BUILD_LIB}" != "" ];then
		infoMsg "start build lib"
		TARGET_LIB_PATH=$DIR/frameworks/runtime-src/prebuild/$BUILD_TYPE-iphoneos
		if [ -d $TARGET_LIB_PATH ];then
			infoMsg "delete $TARGET_LIB_PATH"
			rm -rf $TARGET_LIB_PATH
		fi
		mkdir -p $TARGET_LIB_PATH

		COCOSLIB_PROJECT_NAME=$DIR/frameworks/cocos2d-x/build/cocos2d_libs.xcodeproj
		COCOSLUALIB_PROJECT_NAME=$DIR/frameworks/cocos2d-x/cocos/scripting/lua-bindings/proj.ios_mac/cocos2d_lua_bindings.xcodeproj
		SIMULATOR_PROJECT_NAME=$DIR/frameworks/cocos2d-x/tools/simulator/libsimulator/proj.ios_mac/libsimulator.xcodeproj

		infoMsg "start build libsimulator"
		xcodebuild $CLEAN_PROJECT build -project $SIMULATOR_PROJECT_NAME -target "libsimulator iOS" -configuration $BUILD_TYPE -sdk $IOS_SDK TARGET_BUILD_DIR=$TARGET_LIB_PATH BUILT_PRODUCTS_DIR=$TARGET_LIB_PATH ONLY_ACTIVE_ARCH=NO
		if [ -f "$TARGET_LIB_PATH/libsimulator iOS.a" ];then
			successMsg "build libsimulator success"
			mv "$TARGET_LIB_PATH/libsimulator iOS.a" "$TARGET_LIB_PATH/libsimulator.a"
		else
			errorMsg "build libsimulator fail"
			break;
		fi

		infoMsg "start build libcocos2d"
		xcodebuild $CLEAN_PROJECT build -project $COCOSLIB_PROJECT_NAME -target "libcocos2d iOS" -configuration $BUILD_TYPE -sdk $IOS_SDK TARGET_BUILD_DIR=$TARGET_LIB_PATH BUILT_PRODUCTS_DIR=$TARGET_LIB_PATH ONLY_ACTIVE_ARCH=NO
		if [ -f "$TARGET_LIB_PATH/libcocos2d iOS.a" ];then
			successMsg "build libcocos2d success"
			mv "$TARGET_LIB_PATH/libcocos2d iOS.a" "$TARGET_LIB_PATH/libcocos2d.a"
		else
			errorMsg "build libcocos2d fail"
			break;
		fi

		infoMsg "start build libluacocos2d"
		xcodebuild $CLEAN_PROJECT build -project $COCOSLUALIB_PROJECT_NAME -target "libluacocos2d iOS" -configuration $BUILD_TYPE -sdk $IOS_SDK TARGET_BUILD_DIR=$TARGET_LIB_PATH BUILT_PRODUCTS_DIR=$TARGET_LIB_PATH ONLY_ACTIVE_ARCH=NO
		if [ -f "$TARGET_LIB_PATH/libluacocos2d iOS.a" ];then
			successMsg "build libluacocos2d success"
			mv "$TARGET_LIB_PATH/libluacocos2d iOS.a" "$TARGET_LIB_PATH/libluacocos2d.a"
		else
			errorMsg "build libluacocos2d fail"
			break;
		fi
	fi

	#生成易接 IOS 包
	if [ "$IOS_PACKAGENAME" != "" ];then
		OLD_IFS="$IFS"
		IFS="#"
		arr=($IOS_PACKAGENAME)

		for i in ${arr[@]}
		do
			progressMsg "package $i"
			codeSignIdentity=""
			provisioningProfile=""
			if [ "${i}" = "dev" ];then
				infoMsg "replace dev  lua sdk"
				YIJIEIOS_SCHEME="dev"
				YIJIE_PRODUCT_NAME="dev"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="yijie.plist"
			elif [ "${i}" = "appstore" ];then
				YIJIEIOS_SCHEME="appstore"
				YIJIE_PRODUCT_NAME="appstore"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="appstore.plist"
			elif [ "${i}" = "appstoreDev" ];then
				YIJIEIOS_SCHEME="appstore"
				YIJIE_PRODUCT_NAME="appstore"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="yijie.plist"
			elif [ "${i}" = "vietnamDev" ];then
				mv $DIR/src/project.manifest  $DIR/project__bak.manifest
				mv $DIR/src/version.manifest  $DIR/version__bak.manifest
				mv $DIR/res/data/keyword/keyword.lua $DIR/keyword_bak.lua
				cp -r $DIR/otherCountrys/vi/project.manifest  $DIR/src/project.manifest
				cp -r $DIR/otherCountrys/vi/version.manifest  $DIR/src/version.manifest
				cp -r $DIR/otherCountrys/vi/data/keyword.lua  $DIR/res/data/keyword/keyword.lua

				YIJIEIOS_SCHEME="vietnam"
				YIJIE_PRODUCT_NAME="vietnam"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="vietnamdev.plist"
				codeSignIdentity="iPhone Developer: Nguyen Thi Thu Lanh (V5U2GH6787)"
				provisioningProfile="f6f57d82-6b12-4eee-b0d4-c0ef5b0ae50c"
			elif [ "${i}" = "gatDev" ];then
				mv $DIR/src/project.manifest  $DIR/project__bak.manifest
				mv $DIR/src/version.manifest  $DIR/version__bak.manifest
				#mv $DIR/res/data/keyword/keyword.lua $DIR/keyword_bak.lua
				cp -r $DIR/otherCountrys/gat/project.manifest  $DIR/src/project.manifest
				cp -r $DIR/otherCountrys/gat/version.manifest  $DIR/src/version.manifest
				#cp -r $DIR/otherCountrys/gat/data/keyword.lua  $DIR/res/data/keyword/keyword.lua

				YIJIEIOS_SCHEME="gangaotai"
				YIJIE_PRODUCT_NAME="gangaotaiDev"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="gangaotaiDev.plist"
				codeSignIdentity="iPhone Developer: Heng Ma (RTJ273RUGL)"
				provisioningProfile="986c03fb-1d22-4423-842a-8fe8ea2816c6"
			elif [ "${i}" = "vietnam" ];then
				mv $DIR/src/project.manifest  $DIR/project__bak.manifest
				mv $DIR/src/version.manifest  $DIR/version__bak.manifest
				mv $DIR/res/data/keyword/keyword.lua $DIR/keyword_bak.lua
				cp -r $DIR/otherCountrys/vi/project.manifest  $DIR/src/project.manifest
				cp -r $DIR/otherCountrys/vi/version.manifest  $DIR/src/version.manifest
				cp -r $DIR/otherCountrys/vi/data/keyword.lua  $DIR/res/data/keyword/keyword.lua

				YIJIEIOS_SCHEME="vietnam"
				YIJIE_PRODUCT_NAME="vietnam"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="vietnam.plist"
				codeSignIdentity="iPhone Distribution: Nguyen Thi Thu Lanh (WX5LT4CW5Z)"
				provisioningProfile="b6871de4-5a99-4d1e-816e-87ec57dfb2e9"
			elif [ "${i}" = "gat" ];then
				mv $DIR/src/project.manifest  $DIR/project__bak.manifest
				mv $DIR/src/version.manifest  $DIR/version__bak.manifest
				#mv $DIR/res/data/keyword/keyword.lua $DIR/keyword_bak.lua
				cp -r $DIR/otherCountrys/gat/project.manifest  $DIR/src/project.manifest
				cp -r $DIR/otherCountrys/gat/version.manifest  $DIR/src/version.manifest
				#cp -r $DIR/otherCountrys/gat/data/keyword.lua  $DIR/res/data/keyword/keyword.lua

				YIJIEIOS_SCHEME="gangaotai"
				YIJIE_PRODUCT_NAME="gangaotai"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="gangaotai.plist"
				codeSignIdentity="iPhone Distribution: Heng Ma (5X924364M2)"
				provisioningProfile="f5093567-d24f-40d6-82fd-f8d5b2a17bc6"
			elif [ "${i}" = "malaysiaDev" ];then
				YIJIEIOS_SCHEME="malaysia"
				YIJIE_PRODUCT_NAME="malaysia"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="malaysiaDev.plist"
				codeSignIdentity="iPhone Developer: Guan Eng Huang (TDNB448QJW)"
				provisioningProfile="974f275d-9f41-4e83-be63-5df13582dfd3"
			elif [ "${i}" = "malaysia" ];then
				YIJIEIOS_SCHEME="malaysia"
				YIJIE_PRODUCT_NAME="malaysia"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="malaysia.plist"
				codeSignIdentity="iPhone Distribution: Guan Eng Huang (G9KM5BEGHR)"
				provisioningProfile="bccda6b1-22b8-4d28-b1ff-ce26b432f71f"
			elif [ "${i}" = "thaiDev" ];then
				YIJIEIOS_SCHEME="thai"
				YIJIE_PRODUCT_NAME="thai"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="thaiDev.plist"
				codeSignIdentity="iPhone Developer: boontem benchamad (9LUMN8E4KX)"
				provisioningProfile="db26e32e-fa86-438e-b2f0-4f57c9935758"
			elif [ "${i}" = "thai" ];then
				YIJIEIOS_SCHEME="thai"
				YIJIE_PRODUCT_NAME="thai"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="thai.plist"
				codeSignIdentity="iPhone Distribution: boontem benchamad (93698XM8DG)"
				provisioningProfile="b70d9f0c-c205-4829-a77a-1c54287dec58"
			elif [ "${i}" = "majiaDev" ];then
				YIJIEIOS_SCHEME="majia"
				YIJIE_PRODUCT_NAME="majia"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="zslmDev.plist"
				codeSignIdentity="iPhone Developer: Brandon Zachary (W46CKFBH5S)"
				provisioningProfile="a53f791d-4ce2-4291-bbb2-c78724fa9b3c"
			elif [ "${i}" = "majia" ];then
				YIJIEIOS_SCHEME="majia"
				YIJIE_PRODUCT_NAME="majia"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="zslm.plist"
				codeSignIdentity="iPhone Distribution: Brandon Zachary (GMJ8BU323L)"
				provisioningProfile="551612f3-5ea6-4c9a-9f0f-d1f8f1847261"
			elif [ "${i}" = "majia2Dev" ];then
				YIJIEIOS_SCHEME="majia2"
				YIJIE_PRODUCT_NAME="majia2"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="xbbzdDev.plist"
				codeSignIdentity="iPhone Developer: Jude Kyle (Q6FDX3VB3U)"
				provisioningProfile="9a38f0d2-c61a-4b78-bc50-b04cab6a725e"
			elif [ "${i}" = "majia2" ];then
				YIJIEIOS_SCHEME="majia2"
				YIJIE_PRODUCT_NAME="majia2"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c.xcodeproj
				YIJIEIOS_PLIST="xbbzd.plist"
				codeSignIdentity="iPhone Distribution: Jude Kyle (FWJDNSSHKG)"
				provisioningProfile="c513cc7b-a46f-4ff7-854d-2be924b78f80"
			else
				infoMsg "replace yijie_ios lua sdk" 
				YIJIEIOS_SCHEME="yijie"
				YIJIEIOS_PROJECT_NAME=$DIR/frameworks/runtime-src/proj.ios_sdk/project_c{$i}.xcodeproj
				YIJIE_PRODUCT_NAME="yijie"
				YIJIEIOS_PLIST="yijie.plist"
			fi

			if [ "${i}" = "sy07073_ios" ];then
				infoMsg "change product name sy07073_ios"
				YIJIE_PRODUCT_NAME="g07073symx"
			fi

			YIJIEIOS_ARCHIVE_PATH=$DIR/archive/$i.xcarchive
			if [ -d $YIJIEIOS_PROJECT_NAME ];then
				if [ "${CLEAN_PROJECT}" != "" ];then
					infoMsg "xcodebuild clean -project $YIJIEIOS_PROJECT_NAME -schemfie $YIJIEIOS_SCHEME"
					xcodebuild clean -sdk $IOS_SDK -project $YIJIEIOS_PROJECT_NAME -scheme $YIJIEIOS_SCHEME
				fi
				infoMsg "xcodebuild archive  -project $YIJIEIOS_PROJECT_NAME -scheme $YIJIEIOS_SCHEME -archivePath $YIJIEIOS_ARCHIVE_PATH"
				if [ "${codeSignIdentity}" != "" ];then
					infoMsg "codeSignIdentity :  $codeSignIdentity"
					xcodebuild archive  -sdk $IOS_SDK -project $YIJIEIOS_PROJECT_NAME -scheme $YIJIEIOS_SCHEME -archivePath $YIJIEIOS_ARCHIVE_PATH -configuration $BUILD_TYPE PRODUCT_NAME="${YIJIE_PRODUCT_NAME}" CODE_SIGN_IDENTITY="${codeSignIdentity}" PROVISIONING_PROFILE_SPECIFIER="${provisioningProfile}"
				else
					xcodebuild archive  -sdk $IOS_SDK -project $YIJIEIOS_PROJECT_NAME -scheme $YIJIEIOS_SCHEME -archivePath $YIJIEIOS_ARCHIVE_PATH -configuration $BUILD_TYPE PRODUCT_NAME="${YIJIE_PRODUCT_NAME}"
				fi
				infoMsg "xcodebuild -exportArchive -archivePath $YIJIEIOS_ARCHIVE_PATH -exportPath $OUTPUT_DIR -exportOptionsPlist $SCRIPT_DIR/yijie.plist"
				xcodebuild -exportArchive -archivePath $YIJIEIOS_ARCHIVE_PATH -exportPath $OUTPUT_DIR -exportOptionsPlist $SCRIPT_DIR/$YIJIEIOS_PLIST
			    curTime=`date "+%m-%d-%H-%M"`
			    infoMsg "mv $OUTPUT_DIR/$YIJIEIOS_SCHEME.ipa $OUTPUT_DIR/${i}_${curTime}.ipa"
			    if [ ! -f $OUTPUT_DIR/$YIJIEIOS_SCHEME.ipa ]; then
			    	errorMsg "package $i fail"
			    	infoMsg "请使用易接工具生成ios工程文件！"
			    	break;
			    fi

			    if [ "${i}" = "vietnam" ];then
			    	rm -rf $DIR/src/project.manifest
					rm -rf $DIR/src/version.manifest
					mv $DIR/project__bak.manifest $DIR/src/project.manifest
					mv $DIR/version__bak.manifest $DIR/src/version.manifest
					mv $DIR/keyword_bak.lua $DIR/res/data/keyword/keyword.lua
			    fi

			    if [ "${i}" = "vietnamDev" ];then
			    	rm -rf $DIR/src/project.manifest
					rm -rf $DIR/src/version.manifest
					mv $DIR/project__bak.manifest $DIR/src/project.manifest
					mv $DIR/version__bak.manifest $DIR/src/version.manifest
					mv $DIR/keyword_bak.lua $DIR/res/data/keyword/keyword.lua
			    fi

			    if [ "${i}" = "gat" ];then
			    	rm -rf $DIR/src/project.manifest
					rm -rf $DIR/src/version.manifest
					mv $DIR/project__bak.manifest $DIR/src/project.manifest
					mv $DIR/version__bak.manifest $DIR/src/version.manifest
					#mv $DIR/keyword_bak.lua $DIR/res/data/keyword/keyword.lua
			    fi

			    if [ "${i}" = "gatDev" ];then
			    	rm -rf $DIR/src/project.manifest
					rm -rf $DIR/src/version.manifest
					mv $DIR/project__bak.manifest $DIR/src/project.manifest
					mv $DIR/version__bak.manifest $DIR/src/version.manifest
					#mv $DIR/keyword_bak.lua $DIR/res/data/keyword/keyword.lua
			    fi

			    mv $OUTPUT_DIR/$YIJIEIOS_SCHEME.ipa $OUTPUT_DIR/${i}_${curTime}.ipa

			else
				errorMsg "can not find $YIJIEIOS_PROJECT_NAME"
				infoMsg "如果提示：does not contain a scheme 错误 请用xcode 打开一次工程文件"
				break;
			fi
		done
		IFS="$OLD_IFS"
	fi

	#生成android 包
	if [ "$ANDROID_PACKAGENAME" != "" ];then
		if [ "$ANDROID_NDK_ROOT" != "" ];then
			ANDROID_PROJECT_PATH="$DIR/frameworks/runtime-src/proj.android-studio"
			NDK_MODULE_PATH="${DIR}/frameworks/cocos2d-x:${DIR}/frameworks/cocos2d-x/cocos:${DIR}/frameworks/cocos2d-x/external"
			CPU_NUM=`sysctl hw.ncpu | awk '{print $2}'`

			infoMsg "ANDROID_NDK_ROOT:$ANDROID_NDK_ROOT"
			infoMsg "NDK_DEBUG:$NDK_DEBUG"
			infoMsg "NDK_MODULE_PATH:$NDK_MODULE_PATH"
			infoMsg "CPU_NUM:$CPU_NUM"

			if [ "${CLEAN_PROJECT}" != "" ];then
				infoMsg "clean android project"
				rm -rf $ANDROID_PROJECT_PATH/app/obj
			fi

			$ANDROID_NDK_ROOT/ndk-build \
			NDK_APPLICATION_MK="${ANDROID_PROJECT_PATH}/app/jni/Application.mk" \
			NDK_DEBUG=$NDK_DEBUG \
			-C "${ANDROID_PROJECT_PATH}/app" \
			NDK_TOOLCHAIN_VERSION=4.9 \
			NDK_MODULE_PATH="${NDK_MODULE_PATH}" \
			"-j${CPU_NUM}"

			if [ ! -d $ANDROID_PROJECT_PATH/app/assets ];then
				mkdir $ANDROID_PROJECT_PATH/app/assets
			fi
			infoMsg "clean $ANDROID_PROJECT_PATH/app/assets"
			rm -rf $ANDROID_PROJECT_PATH/app/assets/*
			infoMsg "copy res to $ANDROID_PROJECT_PATH/app/assets"
			# cp -r $DIR/res $ANDROID_PROJECT_PATH/app/assets/
			ln -s $DIR/res $ANDROID_PROJECT_PATH/app/assets/
			infoMsg "copy config.json to $ANDROID_PROJECT_PATH/app/assets"
			cp -r $DIR/config.json $ANDROID_PROJECT_PATH/app/assets/

			infoMsg "copy src to $ANDROID_PROJECT_PATH/app/assets"
			# cp -r $DIR/src $ANDROID_PROJECT_PATH/app/assets/
			ln -s $DIR/src $ANDROID_PROJECT_PATH/app/assets/

			OLD_IFS="$IFS"
			IFS="#"
			arr=($ANDROID_PACKAGENAME)
			for i in ${arr[@]}
			do
				progressMsg "package android $i"
				targetName=$i
				if [ "${i:0:4}" == "lequ" ];then
					echo "===================Ddd"
					targetName="lequ"
					targetAdid=${i:4}
					if [ "${targetAdid}" != "" ];then
						echo "===================Ddd"
						infoMsg "change sdk ad_id ${targetAdid}"
						python $SCRIPT_DIR/SetAD_ID.py $SCRIPT_DIR/../frameworks/runtime-src/proj.android-studio/app/sdk/lequ/src/org/cocos2dx/lua/CmdString.java "${targetAdid}"
					fi
				elif [ "${targetName}" == "vietnam" ];then
					python $SCRIPT_DIR/Change_BuildGradle.py $DIR/frameworks/runtime-src/proj.android-studio/app/build.gradle "true"
					mv $DIR/src/project.manifest  $DIR/project__bak.manifest
					mv $DIR/src/version.manifest  $DIR/version__bak.manifest
					mv $DIR/res/data/keyword/keyword.lua $DIR/keyword_bak.lua
					cp -r $DIR/otherCountrys/vi/project.manifest  $DIR/src/project.manifest
					cp -r $DIR/otherCountrys/vi/version.manifest  $DIR/src/version.manifest
					cp -r $DIR/otherCountrys/vi/data/keyword.lua  $DIR/res/data/keyword/keyword.lua
					# cdn 小包的时候 但是他们要求obb 暂时忽略
					# sh $SCRIPT_DIR/moveViRes.sh
				elif [ "${targetName}" == "gat" ];then
					mv $DIR/src/project.manifest  $DIR/project__bak.manifest
					mv $DIR/src/version.manifest  $DIR/version__bak.manifest
					#mv $DIR/res/data/keyword/keyword.lua $DIR/keyword_bak.lua
					cp -r $DIR/otherCountrys/gat/project.manifest  $DIR/src/project.manifest
					cp -r $DIR/otherCountrys/gat/version.manifest  $DIR/src/version.manifest
					#cp -r $DIR/otherCountrys/gat/data/keyword.lua  $DIR/res/data/keyword/keyword.lua
				elif [ "${targetName}" == "linghou" ]; then
					#uc 替换无网址logo
					infoMsg "set linghou third_platform = linghou"
					$SCRIPT_DIR/decodeLua -d $DIR/src/platform/app/sdk/SDKConfig.luac $DIR/src/platform/app/sdk/SDKConfig.lua
					python $SCRIPT_DIR/SetThirdPlatform.py $DIR/src/platform/app/sdk/SDKConfig.lua "\"linghou\""
					$SCRIPT_DIR/decodeLua -e $DIR/src/platform/app/sdk/SDKConfig.lua $DIR/src/platform/app/sdk/SDKConfig.luac
				elif [ "${targetName}" == "uc" ]; then
					#uc 替换无网址logo
					infoMsg "set uc CC_LOGO_FLAG = 2"
					$SCRIPT_DIR/decodeLua -d $DIR/src/config.luac $DIR/src/config.lua
					python $SCRIPT_DIR/Set_Logo.py $DIR/src/config.lua 2
					$SCRIPT_DIR/decodeLua -e $DIR/src/config.lua $DIR/src/config.luac
				fi
				infoMsg "begin build apk"
				cd $ANDROID_PROJECT_PATH
				APK_TARGET_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${targetName:0:1})${targetName:1}"
				sh gradlew clean "assemble$APK_TARGET_NAME$BUILD_TYPE"
				APK_PATH="${ANDROID_PROJECT_PATH}/app/build/outputs/apk/mengxin-${targetName}-${BUILD_TYPE2}.apk"

				if [ "${targetName}" == "vietnam" ];then
					python $SCRIPT_DIR/Change_BuildGradle.py $DIR/frameworks/runtime-src/proj.android-studio/app/build.gradle "false"
					# if [ -d "${DIR}/res_bak" ];then
						# cdn 小包的时候 但是他们要求obb 暂时忽略
						# infoMsg "reset res from bak"
						# rm -rf ${DIR}/res
						# mv ${DIR}/res_bak ${DIR}/res
					# fi
					rm -rf $DIR/src/project.manifest
					rm -rf $DIR/src/version.manifest
					mv $DIR/project__bak.manifest $DIR/src/project.manifest
					mv $DIR/version__bak.manifest $DIR/src/version.manifest
					mv $DIR/keyword_bak.lua $DIR/res/data/keyword/keyword.lua
				elif [ "${targetName}" == "gat" ];then
					# if [ -d "${DIR}/res_bak" ];then
						# cdn 小包的时候 但是他们要求obb 暂时忽略
						# infoMsg "reset res from bak"
						# rm -rf ${DIR}/res
						# mv ${DIR}/res_bak ${DIR}/res
					# fi
					rm -rf $DIR/src/project.manifest
					rm -rf $DIR/src/version.manifest
					mv $DIR/project__bak.manifest $DIR/src/project.manifest
					mv $DIR/version__bak.manifest $DIR/src/version.manifest
					#mv $DIR/keyword_bak.lua $DIR/res/data/keyword/keyword.lua
				elif [ "${targetName}" == "vietnam" ];then
					python $SCRIPT_DIR/Change_BuildGradle.py $DIR/frameworks/runtime-src/proj.android-studio/app/build.gradle "false"
					# if [ -d "${DIR}/res_bak" ];then
						# cdn 小包的时候 但是他们要求obb 暂时忽略
						# infoMsg "reset res from bak"
						# rm -rf ${DIR}/res
						# mv ${DIR}/res_bak ${DIR}/res
					# fi
					rm -rf $DIR/src/project.manifest
					rm -rf $DIR/src/version.manifest
					mv $DIR/project__bak.manifest $DIR/src/project.manifest
					mv $DIR/version__bak.manifest $DIR/src/version.manifest
					mv $DIR/keyword_bak.lua $DIR/res/data/keyword/keyword.lua
				elif [ "${targetName}" == "uc" ]; then
					infoMsg "set uc CC_LOGO_FLAG = 1"
					$SCRIPT_DIR/decodeLua -d $DIR/src/config.luac $DIR/src/config.lua
					python $SCRIPT_DIR/Set_Logo.py $DIR/src/config.lua 1
					$SCRIPT_DIR/decodeLua -e $DIR/src/config.lua $DIR/src/config.luac
				elif [ "${targetName}" == "linghou" ]; then
					infoMsg "set linghou thirdplatform = sdk.platform"
					infoMsg "set linghou third_platform = linghou"
					$SCRIPT_DIR/decodeLua -d $DIR/src/platform/app/sdk/SDKConfig.luac $DIR/src/platform/app/sdk/SDKConfig.lua
					python $SCRIPT_DIR/SetThirdPlatform.py $DIR/src/platform/app/sdk/SDKConfig.lua "sdk.platform"
					$SCRIPT_DIR/decodeLua -e $DIR/src/platform/app/sdk/SDKConfig.lua $DIR/src/platform/app/sdk/SDKConfig.luac
				fi

				if [ -f "${APK_PATH}" ];then
					successMsg "build apk ${APK_PATH}"
					curTime=`date "+%m-%d-%H-%M"`
					if [ "${targetAdid}" == "" ];then
						infoMsg "mv $APK_PATH $OUTPUT_DIR/mengxin-${targetName}-${BUILD_TYPE2}-${curTime}.apk"
						mv "${APK_PATH}" "${OUTPUT_DIR}/mengxin-${targetName}-${BUILD_TYPE2}-${curTime}.apk"
					else
						infoMsg "mv $APK_PATH $OUTPUT_DIR/mengxin-${targetName}-${BUILD_TYPE2}-${curTime}-${targetAdid}.apk"
						mv "${APK_PATH}" "${OUTPUT_DIR}/mengxin-${targetName}-${BUILD_TYPE2}-${curTime}-${targetAdid}.apk"
						python $SCRIPT_DIR/SetAD_ID.py $SCRIPT_DIR/../frameworks/runtime-src/proj.android-studio/app/sdk/lequ/src/org/cocos2dx/lua/CmdString.java "291"
					fi
				else
					errorMsg "build apk $APK_PATH fail"
					break;
				fi

			done
			IFS="$OLD_IFS"
		else
			errorMsg "please set env ANDROID_NDK_ROOT"
			break;
		fi
	fi
	break;
done


rm -rf $LUA_SRC
mv $LUA_SRC_BAK $LUA_SRC
rm -rf $DIR/archive
echo $REPORT

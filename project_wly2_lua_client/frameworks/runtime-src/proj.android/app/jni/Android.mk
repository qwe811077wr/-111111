LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := \
../../../Classes/AppDelegate.cpp \
../../../Classes/ide-support/SimpleConfigParser.cpp \
../../../Classes/ide-support/RuntimeLuaImpl.cpp \
../../../Classes/ide-support/lua_debugger.c \
../../../Classes/auto/lua_custom_api_auto.cpp \
../../../Classes/Foxair/atomic.cpp \
../../../Classes/Foxair/buffer.cpp \
../../../Classes/Foxair/utils.cpp \
../../../Classes/Foxair/crypto_helper.cpp \
../../../Classes/Foxair/game_connection.cpp \
../../../Classes/Foxair/iomanager.cpp \
../../../Classes/Foxair/socket.cpp \
../../../Classes/Foxair/thread.cpp \
../../../Classes/Foxair/thread_synchronization.cpp \
../../../Classes/Foxair/Commons.cpp \
../../../Classes/Foxair/HttpDownload.cpp \
../../../Classes/Foxair/LocalNotificationHelp.cpp \
../../../Classes/Foxair/RemoteNotificationHelp.cpp \
../../../Classes/Foxair/SdkHelper_android.cpp \
hellolua/main.cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../../Classes \
$(LOCAL_PATH)/../../../.. \
$(LOCAL_PATH)/../../../Classes \
$(LOCAL_PATH)/../../../Classes/protobuf \
$(LOCAL_PATH)/../../../Classes/auto \
$(LOCAL_PATH)/../../../Classes/Foxair \
$(LOCAL_PATH)/../../../Classes/uqeeExtend \
$(LOCAL_PATH)/../../../Classes/irregularButton \
$(LOCAL_PATH)/../../../Classes/sdk \
$(LOCAL_PATH)/../../../../cocos2d-x/external \
$(LOCAL_PATH)/../../../../cocos2d-x/cocos/platform/android/jni \
$(LOCAL_PATH)/../../../../cocos2d-x/tools/simulator/libsimulator/lib

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END

LOCAL_STATIC_LIBRARIES := cocos2d_lua_static

# _COCOS_LIB_ANDROID_BEGIN
# _COCOS_LIB_ANDROID_END

include $(BUILD_SHARED_LIBRARY)

$(call import-add-path, $(LOCAL_PATH)/../../../../cocos2d-x)
$(call import-module, cocos/scripting/lua-bindings/proj.android)

# _COCOS_LIB_IMPORT_ANDROID_BEGIN
# _COCOS_LIB_IMPORT_ANDROID_END

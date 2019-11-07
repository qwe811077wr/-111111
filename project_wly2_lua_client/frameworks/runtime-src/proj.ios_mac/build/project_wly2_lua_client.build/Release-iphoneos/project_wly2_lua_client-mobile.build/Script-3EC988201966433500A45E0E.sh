#!/bin/sh
PWD=$HOME/code/public_code/project_wly2_lua_client/src
#PWD="/Users/admin/code/public_code/project_wly2_lua_client/src"
_TARGET_BUILD_CONTENTS_PATH=$TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH
echo _TARGET_BUILD_CONTENTS_PATH: $_TARGET_BUILD_CONTENTS_PATH
echo PWD: $PWD

echo Cleaning $_TARGET_BUILD_CONTENTS_PATH/
rm -fr $_TARGET_BUILD_CONTENTS_PATH/src/*
                                        
                                               
                                               mkdir -p $_TARGET_BUILD_CONTENTS_PATH/src/
                                               
                                               cp -RLp $PWD/* $_TARGET_BUILD_CONTENTS_PATH/src/

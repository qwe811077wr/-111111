emacs src/config.lua
emacs src/app/sdk/SDKConfig.lua
emacs src/app/config/init.lua
cp -r src src_bak
cd ../project_c_tool && ./main
cd ../project_c
#cocos compile --lua-encrypt --lua-encrypt-key 2dxLua --lua-encrypt-sign XXTEA --compile-script 0 -m release -p android
cocos compile --compile-script 0 -m release -p android
rm -rf src
mv src_bak src

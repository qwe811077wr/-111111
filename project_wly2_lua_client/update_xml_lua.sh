cd ../wly2_lua_svn/StaticData/
svn up
rm -rf lua/dataset_debug
sh ./convert.sh
rm -rf ../../project_wly2_lua_client/src/app/static_data/dataset_debug
cp -r lua/dataset_debug ../../project_wly2_lua_client/src/app/static_data/
cd ../../project_wly2_lua_client
git checkout src/app/static_data/dataset_debug/keyword.lua

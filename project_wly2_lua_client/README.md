#热更新

##脚本
> * build.py
> * buildobb.py

##热更新流程
* 创建两个文件夹publish, versions
* 在publish下创建versions.txt
* 首次发布渠道包之前，执行：**python build.py xxx**(xxx渠道标示)
* 之后更新资源，执行：**python build.py xxx**
* 执行完脚本后，在publish下生成本次增量更新包(zip)
* 上传资源到FTP，**先上传zip资源，再上传version.manifest和project.manifest**

##Manifest说明
项目包含两个manifest文件，**project.manifest**和**version.manifest**
###project.manifest
####参数
> * **asset** 历史更新增量包的信息
	* compressed 是否是压缩包
	* group 暂为用到(无需关注)
	* md5 包的md5码
	* path 增量包路径 例如：1.0.1-180504193313.zip
	* size 增量包大小
> * **engineVersion** 引擎版本(无需关注)
> * **packageUrl** 资源下载地址
> * **remoteManifestUrl** 远程project.manifest所在地址
> * **remoteVersionUrl** 远程version.manifest所在地址
> * **version** 最近一次更新的版本号

###version.manifest
####参数
> * **engineVersion** 引擎版本(无需关注)
> * **packageUrl** 资源下载地址
> * **remoteManifestUrl** 远程project.manifest所在地址
> * **remoteVersionUrl** 远程version.manifest所在地址
> * **version** 最近一次更新的版本号


##海外市场OBB打包流程
###OBB打包
> * 执行：**python buildobb.py verisoncode isApk 渠道名**
> * 参数说明
	* versioncode
	* isApk 
	* 渠道名 vi:越南 gat:港澳台
> * 打包OBB，会生成 **obb+versioncode+安卓包名.zip** 和 **version+obb+versioncode+安卓包名.zip**
> * 生成在对应的othercountrys目录下对应渠道的publish目录(例如：othercountrys/vi/publish)
	* 例如：
	* 包名为com.yxwy.tw，version.manifest中version为1.0.1-180428115542，versioncode为2
	* 生成 **obb2com.yxwy.tw.zip**，  **1.0.1-180428115542obb2com.yxwy.tw.zip**
	* **obb2com.yxwy.tw.zip** 提交到google应用商店
	* **1.0.1-180428115542obb2com.yxwy.tw.zip** 上传到FTP服务器
	* 如果重新出**1.0.1-180428115542obb2com.yxwy.tw.zip**，**切记让运维清缓存，同名资源CDN有缓存**

###越南注意事项
####安卓包
> * android-studio下，将compileSdkVersion改为26，buildToolsVersion改为26
> * platform下必须要有26，若没有，android-studio sdkmanager中下载
> * 打包需要翻墙，否则打包不成功
> * project_c/frameworks/runtime-src/proj.android-studio/app文件夹下如果没有res文件夹 ，打包也会不成功


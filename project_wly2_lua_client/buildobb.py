#!/usr/bin/python
# -*- coding: <encoding name> -*- 例如，可添加# -*- coding: utf-8 -*-

import os, zipfile
import shutil , sys
import hashlib, time, re, json

if len(sys.argv) < 3 :
	print("参数有误 ， 1 version code. 2 true or false. 是否打包apk 3 渠道名称")
	sys.exit(0)

if len(sys.argv) < 2 :
	print("=======")
	CONUNTRY = ""
	VERSION_MANIFEST = "src/version.manifest"
	PROJECT_MANIFEST = "src/project.manifest"
	APK_PACKAGE_NAME = ""
	RES_PATCH = None
elif sys.argv[3] == "vi" :
	print("=======越南")
	CONUNTRY = "otherCountrys/%s"% "vi"
	VERSION_MANIFEST = "%s/version.manifest"%CONUNTRY
	PROJECT_MANIFEST = "%s/project.manifest"%CONUNTRY
	APK_PACKAGE_NAME = "com.lyt.cihamo"
	RES_PATCH = "res_%s"%sys.argv[3]
elif sys.argv[3] == "gat" :
	print("=======港澳台")
	CONUNTRY = "otherCountrys/%s"% "gat"
	VERSION_MANIFEST = "%s/version.manifest"%CONUNTRY
	PROJECT_MANIFEST = "%s/project.manifest"%CONUNTRY
	APK_PACKAGE_NAME = "com.tema.tw"
	RES_PATCH = "res_%s"%sys.argv[3]

def getRealPath(p):
	print("==========", os.path.join(CONUNTRY, p))
	return os.path.join(CONUNTRY, p)

VERSION_DIR = getRealPath('versions')
PACKAGE_DIR = getRealPath("publish")
VERSIONS_FILE = os.path.join(PACKAGE_DIR, 'versions.txt')

def getVersions():
	ret = list()
	try:
		f = file(VERSIONS_FILE, 'r')
	except:
		return ret
	while(True):
		line = f.readline()
		if len(line) <= 0:
			break
		line = line[0:-1]
		parts = line.split(' ')
		ret.append(parts)
	return ret

def getFileMD5(fname):
	m5 = hashlib.md5()
	f = file(fname, 'rb')
	with(f):
		while (True):
			data = f.read(1024)
			if (len(data) <= 0):
				break
			m5.update(data)
	return m5.hexdigest()

def make_zip(dirname, zipfilename):
	filelist = []
	if os.path.isfile(dirname):
		filelist.append(dirname)
	else :
		for root, dirs, files in os.walk(dirname):
			for name in files:
				filelist.append(os.path.join(root, name))
         
	zf = zipfile.ZipFile(zipfilename, "w", zipfile.zlib.DEFLATED)
	for tar in filelist:
		arcname = tar[len(dirname):]
		#print arcname
		zf.write(tar,arcname)
	zf.close()

if __name__ == '__main__':
	BUILDAPK = False
	if sys.argv[2] == "true":
		print("======pppp")
		#os.system("sh switch_country_vi.sh")
		BUILDAPK = True

	if os.path.exists("tempobbfolder"):
		shutil.rmtree("tempobbfolder")
	versionCode = sys.argv[1]
	os.mkdir("tempobbfolder")
	print("移动img文件夹......")
	shutil.copytree("res/img/","tempobbfolder/assets/res/img/")
	print("删除img/login文件夹......")
	shutil.rmtree("tempobbfolder/assets/res/img/login")

	PACKAGE_DIR = PACKAGE_DIR + "/"
	if not os.path.exists(PACKAGE_DIR):
		os.mkdir(PACKAGE_DIR)
	print("创建obb标识文件txt .....")
	OBBFILEPATH = "tempobbfolder/assets/res/obb" + versionCode + APK_PACKAGE_NAME + ".txt"
	if os.path.exists(OBBFILEPATH):
		os.remove(OBBFILEPATH)
	os.system("touch " + OBBFILEPATH)
	print("创建obb" + versionCode + APK_PACKAGE_NAME + ".zip.......到publish")
	make_zip("tempobbfolder/" , PACKAGE_DIR + "obb" + versionCode + APK_PACKAGE_NAME + ".zip")
	print("创建obb" + versionCode + APK_PACKAGE_NAME + ".cdn.zip.......到publish")
	make_zip("tempobbfolder/assets/" , PACKAGE_DIR + "obb" + versionCode + APK_PACKAGE_NAME + ".cdn.zip")
	print("zip finish~~~")

	print("编辑打包相关配置......")
	versions = getVersions()
	lastData = versions[len(versions)-1]
	cur_version = lastData[0]
	cur_version_obb = cur_version + "obb" + versionCode + APK_PACKAGE_NAME
	print("重命名cdnzip........")
	os.rename(PACKAGE_DIR + "obb" + versionCode + APK_PACKAGE_NAME + ".cdn.zip",PACKAGE_DIR + cur_version_obb + ".zip")

	version_item = list()
	version_item.append(cur_version_obb)
	version_item.append(cur_version_obb + '.apk')
	version_item.append(cur_version_obb + '.zip')
	version_item.append(getFileMD5(PACKAGE_DIR + cur_version_obb + '.zip'))
	versions.append(version_item)

	assets = dict()
	f = file(VERSIONS_FILE, 'w')
	for k in versions:
		if len(k) > 2:
			asset = dict()
			asset['path'] = k[2]
			asset['md5'] = k[3]
			asset['compressed'] = True
			asset['group'] = '1'
			asset['size'] = os.path.getsize(os.path.join(getRealPath('publish'), k[2])) *1.0/1024/1024
			assets[k[0]] = asset
		f.write(' '.join(k) + '\n')
	f.close()
	f = file(PROJECT_MANIFEST, 'r')
	obj = json.loads(f.read())
	f.close()
	obj['assets'] = assets
#	obj['version'] = cur_version
	f = file(PROJECT_MANIFEST, 'w')
	f.write(json.dumps(obj, indent=4, sort_keys=True))
	f.close()

	print("清空文件夹.....")
	shutil.rmtree("tempobbfolder/")

	if BUILDAPK == True :
		os.mkdir("tempobbfolder")
		shutil.move("res/img/","tempobbfolder/")
		shutil.move("tempobbfolder/img/login","res/img/login")
		if sys.argv[3] == "vi" :
			os.system("./Script/build.sh -a vietnam")
		elif sys.argv[3] == "gat" :
			os.system("./Script/build.sh -a gat")

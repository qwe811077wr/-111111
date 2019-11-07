#!/usr/bin/python
# -*- coding: <encoding name> -*- 例如，可添加# -*- coding: utf-8 -*-
import os, sys, hashlib, time, zipfile, re, json

if len(sys.argv) < 2:
	print("=======222")
	CONUNTRY = ""
	VERSION_MANIFEST = "publish/ios/version.manifest"
	PROJECT_MANIFEST = "publish/ios/project.manifest"
	RES_PATCH = None
else:
	CONUNTRY = "otherCountrys/%s"%sys.argv[1]
	VERSION_MANIFEST = "%s/version.manifest"%CONUNTRY
	PROJECT_MANIFEST = "%s/project.manifest"%CONUNTRY
	RES_PATCH = "res_%s"%sys.argv[1]


def getRealPath(p):
	print("==========", os.path.join(CONUNTRY, p))
	return os.path.join(CONUNTRY, p)


VERSION_DIR = getRealPath('versions/ios')
PACKAGE_DIR = getRealPath("publish/ios")
PACKET_NAME = 'newwl'
VERSIONS_FILE = os.path.join(PACKAGE_DIR, 'versions.txt')

print "VERSION_DIR : %s"%VERSION_DIR
print "PACKAGE_DIR : %s"%PACKAGE_DIR
print "PACKET_NAME : %s"%PACKET_NAME
print "VERSIONS_FILE : %s"%VERSIONS_FILE
print "VERSION_MANIFEST : %s"%VERSIONS_FILE
print "PROJECT_MANIFEST : %s"%VERSIONS_FILE

if len(sys.argv) < 2:
	FTP_ADDR = '122.226.206.134'
	FTP_PORT = '10021'
	FTP_LOGIN_NAME = 'mengxin'
	FTP_LOGIN_PASSWWORD = 'DS@PSEjd11'
else:
	if sys.argv[1] == 'vi' :
		FTP_ADDR = 'upload.gaba.vn'
		FTP_PORT = '21'
		FTP_LOGIN_NAME = 'sg-t2950'
		FTP_LOGIN_PASSWWORD = 'Og6bdgs$^%*74xxsd'
	elif sys.argv[1] == 'gat' :
		FTP_ADDR = '119.28.19.58'
		FTP_PORT = '22'
		FTP_LOGIN_NAME = 'root'
		FTP_LOGIN_PASSWWORD = 'gfpXxM6nwIPwiP'

from ftplib import FTP
def ftp_up(filename):
	ftp=FTP()
	ftp.set_debuglevel(2)
	#打开调试级别2，显示详细信息;0为关闭调试信息
	ftp.connect(FTP_ADDR, FTP_PORT)
	#连接
	ftp.login(FTP_LOGIN_NAME, FTP_LOGIN_PASSWWORD)
	#ftp.cwd('test1')
	#登录，如果匿名登录则用空串代替即可
	print ftp.getwelcome()
	#显示ftp服务器欢迎信息
	#ftp.cwd('xxx/xxx/')
	#选择操作目录
	bufsize = 1024
	#设置缓冲块大小
	file_handler = open(filename,'rb')
	#以读模式在本地打开文件
	ftp.storbinary('STOR %s' % os.path.basename(filename),file_handler,bufsize)
	#上传文件
	ftp.set_debuglevel(0)
	file_handler.close()
	ftp.quit()
	print "ftp up OK"

def ftp_down(filename):
	ftp=FTP()
	ftp.set_debuglevel(2)
	ftp.connect('192.168.0.1','21')
	ftp.login('admin','admin')
	#print ftp.getwelcome()
	#显示ftp服务器欢迎信息
	#ftp.cwd('xxx/xxx/')
	#选择操作目录
	bufsize = 1024
	filename = "20120904.rar"
	file_handler = open(filename,'wb').write
	#以写模式在本地打开文件
	ftp.retrbinary('RETR %s' % os.path.basename(filename),file_handler,bufsize)
	#接收服务器上文件并写入本地文件
	ftp.set_debuglevel(0)
	file_handler.close()
	ftp.quit()
	print "ftp down OK"

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

def getNewFiles():
	ret = dict()
	fs = list()
	for root, dirs, files in os.walk(os.path.join('src','app')):
		for f in files:
			fname = os.path.join(root, f)
			if not fname.startswith(os.path.join('src', 'app', 'sdk')) and not fname.startswith(os.path.join('src', 'app', 'replace')):
				fs.append(fname)
			if fname.startswith(os.path.join('src', 'app', 'sdkcommon' , 'HttpUtilsCommon')):
				fs.append(fname)

	for root, dirs, files in os.walk('res'):
		for f in files:
			name = os.path.join(root, f)
			fs.append(name)
	for fname in fs:
		print(fname)
		print("Scan file " + fname)
		ret[fname] = getFileMD5(fname)
	return ret

if __name__ == '__main__':
	if len(sys.argv)>=2 and sys.argv[1] == "vi" :
		print("vivivivviv\n\n")
		os.system("sh switch_country_vi.sh")
	elif len(sys.argv)>=2 and sys.argv[1] == "gat" :
		print("gatgatgatgat\n\n")
		os.system("sh switch_tw.sh")
	elif len(sys.argv) >= 2 and sys.argv[1] == "linghou" :
		os.system("sh switch_king.sh")

	sub_ver = time.strftime('%y%m%d%H%M%S')
	line = file(getRealPath('version_ios.txt')).readline()
	main_version = line.split('\n')[0]
	cur_version = main_version + '-' + sub_ver
	file_list = getNewFiles()
	cur_version_file = os.path.join(VERSION_DIR, cur_version + '.txt')
	f = file(cur_version_file, 'w')
	for k in file_list.keys():
		f.write(k + ' ' + file_list[k] + '\n')
	f.close()
	versions = getVersions()
	pre_version = None
	if (len(versions) > 0):
		for v in versions:
			if v[0] == cur_version:
				break
			pre_version = v[0]
			if (len(pre_version) > 18):
				pre_version = pre_version[0:18]
        pre_file_list = dict()
	version_item = list()
	version_item.append(cur_version)
	version_item.append(cur_version + '.ipa')
	if (pre_version != None):
		f = file(os.path.join(VERSION_DIR, pre_version + '.txt'), 'r')
		while (True):
			line = f.readline()
			if len(line) <= 0:
				break
			line = line[0:-1]
			parts = line.split(' ')
			pre_file_list[parts[0]] = parts[1]
		f.close()
		diff_files = list()
		for k in file_list.keys():
			if (not pre_file_list.has_key(k) or pre_file_list[k] != file_list[k]):
				diff_files.append(k)
		if len(diff_files) > 0:
			zip_fname = os.path.join(PACKAGE_DIR, cur_version + '.zip')
			zip_f = zipfile.ZipFile(zip_fname, 'w', zipfile.ZIP_DEFLATED)
			for k in diff_files:
				extArr = os.path.splitext(k)
				if len(extArr) == 2 and extArr[1] == ".lua":
					# newName = k+'c'
					# os.system('Script/decodeLua -e %s %s'%(k, newName))
					newName = k
					zip_f.write(newName)
					# os.system('Script/decodeLua -d %s %s'%(newName, k))
				else:
					zip_f.write(k)
			zip_f.close()
			version_item.append(cur_version + '.zip')
			version_item.append(getFileMD5(zip_fname))
			print('diff files:')
			print(diff_files)
			input("interrupt!")
	update = False
	for i in xrange(len(versions)):
		if (versions[i][0] == version_item[0]):
			versions[i] = version_item
			update = True
			break
	if (not update):
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
			asset['size'] = os.path.getsize(os.path.join(getRealPath('publish/ios'), k[2])) *1.0/1024/1024
			assets[k[0]] = asset
		f.write(' '.join(k) + '\n')
	f.close()
	f = file(PROJECT_MANIFEST, 'r')
	obj = json.loads(f.read())
	f.close()
	obj['assets'] = assets
	obj['version'] = cur_version
	f = file(PROJECT_MANIFEST, 'w')
	f.write(json.dumps(obj, indent=4, sort_keys=True))
	f.close()
	f = file(VERSION_MANIFEST, 'r')
	obj = json.loads(f.read())
	f.close()
	obj['version'] = cur_version
	f = file(VERSION_MANIFEST, 'w')
	f.write(json.dumps(obj, indent=4, sort_keys=True))
	f.close()

	#ftp update
	# zip_fname_update = os.sep.join([PACKAGE_DIR, cur_version + '.zip'])
	# if os.path.exists(zip_fname_update) :
	# 	ftp_up(VERSION_MANIFEST)
	# 	ftp_up(PROJECT_MANIFEST)
	# 	ftp_up(zip_fname_update)


	# print("上传成功 ~~~")
	# if len(diff_files) > 0:
	# 	for k in diff_files:
	# 		print("上传的文件内容：" + k)

	print('build ios hot update finish ', cur_version)



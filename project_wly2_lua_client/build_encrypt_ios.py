import os, sys, hashlib, time, zipfile, re, json

VERSION_DIR = 'versions/ios'
PACKAGE_DIR = "publish/ios"
PACKET_NAME = 'newwl'

VERSIONS_FILE = os.sep.join([PACKAGE_DIR, 'versions.txt'])

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
	for root, dirs, files in os.walk(os.sep.join(['src','app'])):
		for f in files:
			fname = os.sep.join([root, f])
			if not fname.startswith(os.sep.join(['src', 'app', 'sdk'])):
				fs.append(fname)

	for root, dirs, files in os.walk('res'):
		for f in files:
			name = os.sep.join([root, f])
			fs.append(name)
	for fname in fs:
#		print("Scan file " + fname)
		ret[fname] = getFileMD5(fname)
	return ret

if __name__ == '__main__':
	if (len(sys.argv) >= 2):
		sub_ver = str(int(sys.argv[1]))
	else:
		sub_ver = time.strftime('%y%m%d%H%M%S')
		line = file('version_ios.txt').readline()
	main_version = line.split('\n')[0]
	cur_version = main_version + '-' + sub_ver
	file_list = getNewFiles()
	cur_version_file = os.sep.join([VERSION_DIR, cur_version + '.txt'])
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
		pre_file_list = dict()
	version_item = list()
	version_item.append(cur_version)
	version_item.append(cur_version + '.ipa')
	# if (pre_version != None):
	# 	f = file(os.sep.join([VERSION_DIR, pre_version + '.txt']), 'r')
	# 	while (True):
	# 		line = f.readline()
	# 		if len(line) <= 0:
	# 			break
	# 		line = line[0:-1]
	# 		parts = line.split(' ')
	# 		pre_file_list[parts[0]] = parts[1]
	# 	f.close()
	# 	diff_files = list()
	# 	for k in file_list.keys():
	# 		if (not pre_file_list.has_key(k) or pre_file_list[k] != file_list[k]):
	# 			diff_files.append(k)
	# 	if len(diff_files) > 0:
	# 		zip_fname = os.sep.join([PACKAGE_DIR, cur_version + '.zip'])
	# 		zip_f = zipfile.ZipFile(zip_fname, 'w', zipfile.ZIP_DEFLATED)
	# 		for k in diff_files:
	# 			zip_f.write(k)
	# 			zip_f.extractall(PACKAGE_DIR + '/' + cur_version)
	# 			zip_f.close()
	# 			if os.system('cocos luacompile -s ' + PACKAGE_DIR + '/' + cur_version + ' -d ' + PACKAGE_DIR + ' -e -k 2dxLua -b XXTEA --disable-compile') != 0:
	# 				print("Unable to cocos luacompile")
	# 				sys.exit(1)
	# 			if os.system('rm -rf ' + PACKAGE_DIR + '/' + cur_version + '.zip') != 0:
	# 				print("Unable to remove directory:" + cur_version)
	# 				sys.exit(1)
	# 			zip_fname = os.sep.join([PACKAGE_DIR, cur_version + '.zip'])
	# 			zip_f = zipfile.ZipFile(zip_fname, 'w', zipfile.ZIP_DEFLATED)
	# 			for dirpath, dirnames, filenames in os.walk(os.sep.join([PACKAGE_DIR, 'src'])):
	# 				for filename in filenames:
	# 					subDirPath = dirpath[len(PACKAGE_DIR)+1:]
	# 					zip_f.write(os.path.join(dirpath,filename), os.path.join(subDirPath,filename))
	# 			for dirpath, dirnames, filenames in os.walk(os.sep.join([PACKAGE_DIR, 'res'])):
	# 				for filename in filenames:
	# 					subDirPath = dirpath[len(PACKAGE_DIR)+1:]
	# 					zip_f.write(os.path.join(dirpath,filename), os.path.join(subDirPath,filename))
	# 		version_item.append(cur_version + '.zip')
	# 		version_item.append(getFileMD5(zip_fname))

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
			assets[k[0]] = asset
		f.write(' '.join(k) + '\n')
	f.close()
	f = file('publish/ios/project.manifest', 'r')
	obj = json.loads(f.read())
	f.close()
	obj['assets'] = assets
	obj['version'] = cur_version
	f = file('publish/ios/project.manifest', 'w')
	f.write(json.dumps(obj, indent=4, sort_keys=True))
	f.close()
	f = file('publish/ios/version.manifest', 'r')
	obj = json.loads(f.read())
	f.close()
	obj['version'] = cur_version
	f = file('publish/ios/version.manifest', 'w')
	f.write(json.dumps(obj, indent=4, sort_keys=True))
	f.close()

	os.system('cp -rf publish/ios/version.manifest src/')
	os.system('cp -rf publish/ios/project.manifest src/')

	ipas = os.listdir(os.sep.join(['publish/ios', 'pack']))
	for ipa in ipas:
		os.unlink(os.sep.join(['publish/ios', 'pack', ipa]))

	if os.system('cd build/scripts/;lua build_ipa_new.lua version=' + cur_version) != 0:
		print("Unable to build packet")
		sys.exit(1)

	ipas = os.listdir(os.sep.join(['publish/ios', 'pack']))
	if len(ipas) == 0:
		print("No ipas")
		exit(1)

	ipa_name = ipas[0]
	infile = file(os.sep.join(['publish/ios', 'pack', ipa_name]), 'rb')
	outfile = file(os.sep.join([PACKAGE_DIR, PACKET_NAME + '-' + cur_version + '.ipa']), 'wb')
	while(True):
		data = infile.read(1024)
		if len(data) <= 0:
			break
		outfile.write(data)
	infile.close()
	outfile.close()

	print('build ios pack finish', cur_version)

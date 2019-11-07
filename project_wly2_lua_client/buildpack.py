import os, sys, hashlib, time, zipfile, re, json

VERSION_DIR = 'versions'
PACKAGE_DIR = "publish"
PACKET_NAME = 'project_wly2_lua_client'

VERSIONS_FILE = os.sep.join([PACKAGE_DIR, 'versions.txt'])

EXCLUDE_PATTERNS = [os.sep.join(['src', 'app', 'sdk', '.*'])]

def isExclude(fname):
	for p in EXCLUDE_PATTERNS:
		if (re.search(p, fname)):
			return True
	return False

def genDiffFile(ver1 , ver2):
	diff_files = dict()
	list1 = getFileDicts(ver1)
	list2 = getFileDicts(ver2)
	for k in list2.keys():
		if (not list1.has_key(k) or list1[k] != list2[k]):
			if not diff_files.has_key(k) :
				diff_files[k] = k
	return diff_files

def getFileDicts(ver):
	file_list = dict()
	f = file(os.sep.join([VERSION_DIR, ver + '.txt']), 'r')
	while (True):
		line = f.readline()
		if len(line) <= 0:
			break
		line = line[0:-1]
		parts = line.split(' ')
		file_list[parts[0]] = parts[1]
	f.close()
	return file_list

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
			fs.append(fname)

	for root, dirs, files in os.walk('res'):
		for f in files:
			name = os.sep.join([root, f])
			fs.append(name)
	for fname in fs:
		print("Scan file " + fname)
		if (isExclude(fname)):
			print('Exclude ' + fname)
			continue
		ret[fname] = getFileMD5(fname)
	return ret

if __name__ == '__main__':
	go_back_items = 0
	go_back_items_arr = list()
	diff_files_total = dict()

	if (len(sys.argv) >= 2):
		go_back_items = int(sys.argv[1])
	sub_ver = time.strftime('%y%m%d%H%M%S')
	line = file('version.txt').readline()

	main_version = line.split('\n')[0]
	cur_version = main_version + '-' + sub_ver
	file_list = getNewFiles()
	cur_version_file = os.sep.join([VERSION_DIR, cur_version + '.txt'])
	f = file(cur_version_file, 'w')
	for k in file_list.keys():
		f.write(k + ' ' + file_list[k] + '\n')
	f.close()

	versions = getVersions()
	if go_back_items > 0 and go_back_items < len(versions) :
		temp_go_back_items = go_back_items
		while temp_go_back_items > 0:
			go_back_items_arr.insert(0, versions.pop()[0])
			temp_go_back_items -= 1

	pre_version = None
	if (len(versions) > 0):
		for v in versions:
			if v[0] == cur_version:
				break
			pre_version = v[0]
        pre_file_list = dict()
	version_item = list()
	version_item.append(cur_version)
	version_item.append(cur_version + '.apk')
	if (pre_version != None):
		#f = file(os.sep.join([VERSION_DIR, pre_version + '.txt']), 'r')
		#while (True):
		#	line = f.readline()
		#	if len(line) <= 0:
		#		break
		#	line = line[0:-1]
		#	parts = line.split(' ')
		#	pre_file_list[parts[0]] = parts[1]
		#f.close()
		del pre_file_list
		if go_back_items == 0 :
			pre_file_list = getFileDicts(pre_version)
		else:
			for k in go_back_items_arr:
				temp_diff_files = genDiffFile(pre_version , k)
				diff_files_total.update(temp_diff_files)
				pre_version = k
			pre_file_list = getFileDicts(pre_version)

		diff_files = list()
		for k in file_list.keys():
			if (not pre_file_list.has_key(k) or pre_file_list[k] != file_list[k]):
				diff_files_total[k] = k
		diff_files = diff_files_total.keys()
		for k in diff_files :
			if not file_list.has_key(k):
				diff_files.remove(k)
			else:
				print ("diff files : %s" % (k))
		input("input interrupt!")

		if len(diff_files) > 0:
			zip_fname = os.sep.join([PACKAGE_DIR, cur_version + '.zip'])
			zip_f = zipfile.ZipFile(zip_fname, 'w', zipfile.ZIP_DEFLATED)
			for k in diff_files:
				zip_f.write(k)
			zip_f.close()
			version_item.append(cur_version + '.zip')
			version_item.append(getFileMD5(zip_fname))
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
			asset['size'] = os.path.getsize('publish/' + k[2]) *1.0/1024/1024
			assets[k[0]] = asset
		f.write(' '.join(k) + '\n')
	f.close()
	f = file('src/project.manifest', 'r')
	obj = json.loads(f.read())
	f.close()
	obj['assets'] = assets
	obj['version'] = cur_version
	f = file('src/project.manifest', 'w')
	f.write(json.dumps(obj, indent=4, sort_keys=True))
	f.close()
	f = file('src/version.manifest', 'r')
	obj = json.loads(f.read())
	f.close()
	obj['version'] = cur_version
	f = file('src/version.manifest', 'w')
	f.write(json.dumps(obj, indent=4, sort_keys=True))
	f.close()

	#remove packs
	if go_back_items > 0 :
		for tempVersion in go_back_items_arr :
			tempVersionTxt = os.sep.join([VERSION_DIR, tempVersion + '.txt'])
			tempVersionZip = os.sep.join([PACKAGE_DIR, tempVersion + '.zip'])
			print("delete file  : %s " % tempVersionTxt)
			print("delete file  : %s " % tempVersionZip)
			if os.path.exists(tempVersionTxt) :
				os.remove(tempVersionTxt)
			if os.path.exists(tempVersionZip) :
				os.remove(tempVersionZip)
		input("interrupt!")

	apks = os.listdir(os.sep.join(['publish', 'android']))
	for apk in apks:
		os.unlink(os.sep.join(['publish', 'android', apk]))
	cmd = 'cocos compile -p android -m release'#'cocos compile -p android -m release --compile-script 0'
	if os.system(cmd) != 0:
		print("Unable to build packet")
		sys.exit(1)
	apks = os.listdir(os.sep.join(['publish', 'android']))
	if len(apks) == 0:
		print("No apks")
		exit(1)

	apk_name = apks[0]
	infile = file(os.sep.join(['publish', 'android', apk_name]), 'rb')
	outfile = file(os.sep.join([PACKAGE_DIR, PACKET_NAME + '-' + cur_version + '.apk']), 'wb')
	while(True):
		data = infile.read(1024)
		if len(data) <= 0:
			break
		outfile.write(data)
	infile.close()
	outfile.close()

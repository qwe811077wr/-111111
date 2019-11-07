import sys,os,time,hashlib,json
SCRIPT_PATH = os.path.abspath(os.path.split(sys.argv[0])[0]);

if len(sys.argv) > 1:
    DIR = sys.argv[1]
else:
    DIR = os.path.abspath(os.path.join(SCRIPT_PATH, "../"))

CONFIGPATH = os.path.abspath(os.path.join(DIR, "otherCountrys/vi"))
PROJECT_MANIFEST = os.path.join(CONFIGPATH, "project.manifest")
VERSION_MANIFEST = os.path.join(CONFIGPATH, "version.manifest")
print DIR


def getFileMd5(filePath):
    pFile = open(filePath, 'r')
    data = pFile.read()
    pFile.close()
    return hashlib.md5(data).hexdigest()

sub_ver = time.strftime('%y%m%d%H%M%S')
line = file(os.path.join(CONFIGPATH, "version.txt")).readline()
main_version = line.split('\n')[0]
cur_version = main_version + '-' + sub_ver
print cur_version

command = 'sh %s %s'%(os.path.join(DIR, "Script/zipViRes.sh"), cur_version)
ret = os.system(command)
zipFilePath = os.path.join(DIR, "%s.zip"%cur_version)


def getVersions():
	ret = list()
	try:
		f = file(os.path.join(CONFIGPATH, "publish/versions.txt"), 'r')
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


if os.path.exists(zipFilePath):
    size = os.path.getsize(zipFilePath) *1.0/1024/1024
    md5 = getFileMd5(zipFilePath)
    versions = getVersions()
    version_item = list()
    version_item.append(cur_version)
    version_item.append(cur_version + '.apk')
    version_item.append(cur_version + '.zip')
    version_item.append(md5)
    version_item.append("android#vietnam#1.1.1")
    versions.append(version_item)
    assets = dict()
    f = file(os.path.join(CONFIGPATH, "publish/versions.txt"), 'w')
    for k in versions:
        if len(k) > 2:
            asset = dict()
            asset['path'] = k[2]
            asset['md5'] = k[3]
            asset['compressed'] = True
            asset['group'] = '1'
            if len(k) >= 5:
                asset['conditions'] = k[4]
            if os.path.exists(os.path.join(CONFIGPATH, "publish", k[2])):
                asset['size'] = os.path.getsize(os.path.join(CONFIGPATH, "publish", k[2])) * 1.0 / 1024 / 1024
            else:
                asset['size'] = size
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
else:
    print("error :: file not find ")






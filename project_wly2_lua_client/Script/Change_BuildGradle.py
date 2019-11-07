#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys, re
configFilePath = sys.argv[1]
value = sys.argv[2]


CUR_MATCH_STATUS = 1
if value == "true":
	VALUE_1 = "apply plugin: 'io.fabric'\n"
	VALUE_2 = "            keyAlias 'vegagame'\n"
	VALUE_3 = "            keyPassword '123456789'\n"
	VALUE_4 = "            storeFile file('../../keystore/vegagame2.keystore.jks')\n"
	VALUE_5 = "            storePassword '123456789'\n"
else:
	VALUE_1 = "//apply plugin: 'io.fabric'\n"
	VALUE_2 = "            keyAlias 'uqeekey'\n"
	VALUE_3 = "            keyPassword '2dxLua'\n"
	VALUE_4 = "            storeFile file('../../keystore/uqee.keystore')\n"
	VALUE_5 = "            storePassword '2dxLua'\n"

def match(str):
	global CUR_MATCH_STATUS
	if CUR_MATCH_STATUS == 1:
		pattern = ".*apply\s*plugin:\s*'\s*io.fabric\s*'.*"
		matchObj = re.match(pattern, str)
		if matchObj:
			print("==================")
			CUR_MATCH_STATUS = 2
			return VALUE_1
	if CUR_MATCH_STATUS == 2:
		pattern = ".*signingConfigs\s*{.*"
		matchObj = re.match(pattern, str)
		if matchObj:
			CUR_MATCH_STATUS = 3
			return
	if CUR_MATCH_STATUS == 3:
		pattern = ".*release\s*{.*"
		matchObj = re.match(pattern, str)
		if matchObj:
			CUR_MATCH_STATUS = 4
			return
	if CUR_MATCH_STATUS == 4:
		pattern = ".*keyAlias.*"
		matchObj = re.match(pattern, str)
		if matchObj:
			CUR_MATCH_STATUS = 5
			return VALUE_2
	if CUR_MATCH_STATUS == 5:
		pattern = ".*keyPassword.*"
		matchObj = re.match(pattern, str)
		if matchObj:
			CUR_MATCH_STATUS = 6
			return VALUE_3
	if CUR_MATCH_STATUS == 6:
		pattern = ".*storeFile\s*file.*"
		matchObj = re.match(pattern, str)
		if matchObj:
			CUR_MATCH_STATUS = 7
			return VALUE_4
	if CUR_MATCH_STATUS == 7:
		pattern = ".*storePassword.*"
		matchObj = re.match(pattern, str)
		if matchObj:
			CUR_MATCH_STATUS = 8
			return VALUE_5

	
pFile = open(configFilePath, "rU")
lines = pFile.readlines()
print(len(lines))

for k in range(0, len(lines)):
	str = match(lines[k])
	# print(lines[k])
	if str:
		lines[k] = str;

pFile.close()

pFile = open(configFilePath, "w")
pFile.writelines(lines)
pFile.close()
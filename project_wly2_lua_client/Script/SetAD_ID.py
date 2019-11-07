#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys, re
configFilePath = sys.argv[1]
value = sys.argv[2]

def match(str):
    pattern = ".*static\s*final\s*public\s*int\s*AD_ID\s*=.*"
    matchObj = re.match(pattern, str)
    if matchObj:
    	print("==================")
        return "		static final public int AD_ID = %s;\n"%value


pFile = open(configFilePath)
lines = pFile.readlines()

for k in range(0, len(lines)):
    # print(lines[k])
    str = match(lines[k])
    if str:
        lines[k] = str;

pFile.close()

pFile = open(configFilePath, "w")
pFile.writelines(lines)
pFile.close()
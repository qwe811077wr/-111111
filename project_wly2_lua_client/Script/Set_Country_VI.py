#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys, re
configFilePath = sys.argv[1]
# value = sys.argv[2]

def match(str):
    pattern = ".*config\.COUNTRY_CODE\s*=\s*config\.constant\.COUNTRY_CODE\..*"
    matchObj = re.match(pattern, str)
    if matchObj:
        return "config.COUNTRY_CODE = config.constant.COUNTRY_CODE.CODE_VIETNAM\n"


pFile = open(configFilePath)
lines = pFile.readlines()

for k in range(0, len(lines)):
    str = match(lines[k])
    if str:
        lines[k] = str;

pFile.close()

pFile = open(configFilePath, "w")
pFile.writelines(lines)
pFile.close()

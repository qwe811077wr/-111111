#!/usr/bin/env python
#coding=utf-8

import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import os
import os.path
import csv
import hashlib

root=os.environ["HOME"] + "/workspace/project_c/"
src_path = root + "res/"
dest_path = root + "res_temp/"
compressed_csv = root + "compressed.csv"

fileMap = dict()

#图片压缩批处理  
def compressImage(srcPath,dstPath):
    global fileMap

    for filename in os.listdir(srcPath):
        #如果不存在目的目录则创建一个，保持层级结构
        if not os.path.exists(dstPath):
            os.makedirs(dstPath)        

        #拼接完整的文件或文件夹路径
        srcFile=os.path.join(srcPath,filename)
        dstFile=os.path.join(dstPath,filename)

        #如果是文件就处理
        if os.path.isfile(srcFile) and filename.endswith(".png"):
            pary = srcFile.split(root)
            relaPath = pary[1]
            orgMd5 = fileMap.get(relaPath)
            newMd5 = getFileMd5(srcFile)
            if orgMd5 == newMd5:
                #print "srcFile:", srcFile, "md5:", orgMd5, " same"
                continue

            print "srcFile:", srcFile, "orgMd5:", orgMd5, ",newMd5:", newMd5
            #打开原图片缩小后保存，可以用if srcFile.endswith(".jpg")或者split，splitext等函数等针对特定文件压缩
            cmd = "pngquant -f --quality 50-80 " + srcFile + " --output " + dstFile
            #os.system(cmd.encode('utf-8'))
            os.system(cmd)
            print ("%-10s%s") % ("From:", srcFile)
            print ("%-10s%s") % ("To:", dstFile)
            if os.path.exists(dstFile):
                fileMap[relaPath] = getFileMd5(dstFile)

        #如果是文件夹就递归
        if os.path.isdir(srcFile):
            compressImage(srcFile,dstFile)

def getFileMd5(filePath):
    md5 = ""
    with open(filePath, 'rb') as f:
        md5 = hashlib.md5(f.read()).hexdigest()
    return md5
    
if __name__=='__main__':
    if os.path.exists(dest_path):
        os.system("rm -rf " + dest_path)
        os.system("mkdir " + dest_path)

    if not os.path.exists(src_path):
        print "未找到源路径！src_path:", src_path

    if not os.path.exists(compressed_csv):
        os.system("touch " + compressed_csv)

    with open(compressed_csv, "r") as f:
        cf = csv.reader(f)
        for s in cf:
            print s[0], s[1]
            fileMap[s[0]] = s[1]

    compressImage(src_path, dest_path)

    os.system("cp -r " + dest_path + "* " + src_path)
#    os.system("rm -rf " + dest_path)

    with open(compressed_csv, "w") as out:
        csv_write = csv.writer(out,dialect='excel')
        for k, v in fileMap.items():
            csv_write.writerow([k, v])

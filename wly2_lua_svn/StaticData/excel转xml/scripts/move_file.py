#coding=utf-8
import os, sys  ,shutil
  
if __name__ == '__main__':  
    #if len(sys.argv) != 3:  
    #    print 'help movie.py src dst'  
    #    sys.exit(-1)  
    cur_dir = sys.path[0]
    srcDir = os.path.realpath(cur_dir + '/../StaticData_Debug')
    dstDir = os.path.realpath(cur_dir + '/../StaticData')
    files = os.listdir(srcDir)  
    for file in files:  
        srcFile = srcDir + os.sep + file  
        dstFile = dstDir + os.sep + file  
        if os.path.isfile(srcFile):  
            print srcFile  
            #os.rename(srcFile, dstFile) 
            shutil.copyfile(srcFile, dstFile)
    sys.exit(0) 
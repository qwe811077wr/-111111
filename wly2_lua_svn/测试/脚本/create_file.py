####批量生成脚本文件####
#1.将文件中统一的内容写进py脚本对应位置
#2.将需要生成的文件名与需要插入的内容写进temp.txt，格式为“文件名 插入内容”
#3.生成的文件位置在files_sql路径下
#4.支持头尾相同，向中间插入内容。sql1为头，sql3为尾，sql2是可修改部分，根据需求自行调整
import os

file_content = open('temp.txt','r').readlines()
sql1 = "++++++++++++++\n"
sql2 = "-*-*-*-*-*-{0}-*-*-*-*-\n"
sql3 = "==============\n"
str_file = "E:\\Projects\\python\\createsql\\files_sql\\"

def create_file(name,cont):
    file_name = str_file + name + ".sql"
    
    if name in get_file_names():
        file_temp = open(file_name,'a')
        sql = sql2.format(cont)
        file_temp.write(sql)
        print(name + "2cd ok!")
    else:
        file_temp = open(file_name,'w+')
        sql = sql2.format(cont)
        file_temp.write(sql1 + sql)
        print(name + " 1ft ok!")

def ending():
    for name in get_file_names():
        file_name = str_file + name + ".sql"
        file_temp = open(file_name,'a')
        file_temp.write(sql3)
        print(name + " ok!end")

def get_file_names():
    file_names = []
    for dirpaths,dirnames,filenames in os.walk(str_file):
        for filename in filenames:
            if "." in filename:
                filename = filename.split(".")[0]
                file_names.append(filename)
    print(file_names)
    return file_names

for i in file_content:
    content = i.split(" ")
    create_file(content[0].strip(),content[1].strip())
ending()

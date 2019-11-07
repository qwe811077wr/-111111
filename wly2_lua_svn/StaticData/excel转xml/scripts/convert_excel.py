#coding=utf-8
import sys  
reload(sys)  
sys.setdefaultencoding('utf-8')
#print "len(sys.argv)"
#print len(sys.argv)
if len(sys.argv) > 2:
    tname = sys.argv[2]
    ttype = sys.argv[3]
    print "ttype"
    print ttype
else:
    tname = ""
import os
import shutil
import xlrd, libxml2
import re

def listExcels(path):
    ret = []
    for root, dirs, files in os.walk(path):
        for f in files:
            parts = f.split('.')
            if len(parts) == 2 and parts[1] == 'xlsx':
                p = root + '/' + f
                #print p  + "   " + root + "   " + f
                p = p[len(path):len(p)]
                if p[0] == '/':
                    p = p[1:len(p)]
                ret.append(p)
    return ret

def descContect(f):
    desc = ""
    xls = xlrd.open_workbook(f)
    #print f
    for table in xls.sheets():
        #print table.name
        if table.name == "$$desc":
            desc = unicode(table.cell(0, 0).value)
    return desc
    
def parse_xls(f):
    root = dict()
    xls = xlrd.open_workbook(f)
    if len(xls.sheets()) == 0:
        return root
    for table in xls.sheets():
        if table.ncols == 0 or table.name.startswith('$$'):
            continue
        fields = list()
        for i in xrange(table.ncols):
            fields.append(unicode(table.cell(0, i).value))
        items = list()
        for i in xrange(2, table.nrows):
            node = dict()
            for j in xrange(table.ncols):
            	if len(fields[j]) < 1 or fields[j].startswith('//'):
            		continue
                value = unicode(table.cell(i, j).value)
                if type(table.cell(i, j).value) == type(1.0):
                    value = table.cell(i, j).value
                    if value.is_integer():
                        value = str(int(value))
                    else:
                        value = str(value)
                node[fields[j]] = value
            items.append(node)
        root[table.name] = items
    for k, v in root.items():
        if k.startswith('node_'):
            name = k[5:]
            name = filter(lambda x:x not in '0123456789',name)
            name = re.sub(u"\\（.*?）|\\{.*?}|\\[.*?]|\\【.*?】", "", name.decode())
            name = re.sub(u"\\(.*?\\)|\\{.*?}|\\[.*?]", "", name)
            #print name
            if root.has_key(name):
                items = root[k]
                #del root[k]
                for node in items:
                    pnode = None
                    for t in root[name]:
                        if node['ref_ident'] == t['ident']:
                            pnode = t
                            break
                    if not pnode:
                        continue
                    if not node.has_key('node_name'):
                        continue
                    if not pnode.has_key(node['node_name']):
                        pnode[node['node_name']] = list()
                    pnode[node['node_name']].append(node)
                    print "f"
                    print f
                    if f.find("GeneralSupport") == -1:
                        del node['ref_ident']
                        del node['node_name']
    for k, v in root.items():
        for v1 in v:
            for k2, v2 in v1.items():
                if not k2.startswith('node['):
                    continue
                pos = k2.find('] ')
                if pos < 0:
                    continue
                name = k2[5:pos]
                fields = k2[pos + 2:].split(' ')
                items = v2.split(unicode('；'))
                if len(v2) == 0:
                    del v1[k2]
                    continue
                for item in items:
                    parts = item.split(unicode('、'))
                    if not v1.has_key(name):
                        v1[name] = list()
                    node = dict()
                    for i in xrange(len(parts)):
                        node[fields[i]] = parts[i]
                    v1[name].append(node)
                del v1[k2]
    return root



def contain_zh(word):
    zh_pattern = re.compile(u'[\u4e00-\u9fa5]+')
    '''
    判断传入字符串是否包含中文
    :param word: 待判断字符串
    :return: True:包含中文  False:不包含中文
    '''
    word = word.decode()
    global zh_pattern
    match = zh_pattern.search(word)

    return match

def print_to_xml(doc, root, name, data):
    for v in data:
        flag = 0
        node = libxml2.newNode(name)
        for k1, v1 in v.items():
            if k1 == "ident" and v1 == "":
                flag = 1
                break
            if k1 == "ident" and v1.startswith("//"):
                flag = 1
                break
            if k1 == "ref_ident" and v1 == "":
                flag = 1
                break
            if k1 == "ref_ident" and v1.startswith("//"):
                flag = 1
                break
            if k1 == "XML" and v1 == "0":
                flag = 1
                break
        if flag == 0:
            for k1, v1 in v.items():
                if isinstance(v1, list):
                    print_to_xml(doc, node, k1, v1)
                    continue
                if k1 == "XML":
                    continue
                if contain_zh(k1):
                    continue
                if k1 == 'CDATA':
                    node.addChild(doc.newCDataBlock(v1, len(v1.encode('utf-8'))))
                else:
                    node.newProp(k1, v1)
            root.addChild(node)

def serialToLua(v):
    ret = ''
    
    if isinstance(v, dict):
        data = ''
        for k in v.keys():
            if len(data) > 0:
                data = data + ','
            data = data + k + '=' + serialToLua(v[k])
        return '{' + data + '}'
    if isinstance(v, list):
        data = ''
        for k in v:
            if len(data) > 0:
                data = data + ','
            if k.has_key('ident'):
                num = k['ident']
                data = data +'['+ str(num) + ']' + '='+serialToLua(k)
            else:
                data = data + serialToLua(k)
        return '{' + data + '}'
    if isinstance(v,int):
        return str(v)
    elif isinstance(v,float):
        return str(v)
    else:
        return '"' + v + '"'

def delfiles(root):
    if not os.path.exists(root):
        os.makedirs(root)
        return
    for f in os.listdir(root):
        f = os.path.join(root, f)
        if os.path.isfile(f):
            os.remove(f)

def convert():
    cur_dir = sys.path[0]
    toxml = '-xml' in sys.argv
    tolua = '-lua' in sys.argv

    if not toxml and not tolua:
        return

    if toxml:
        xmldir = os.path.realpath(cur_dir + '/../StaticData_Debug')
        delfiles(xmldir)

    if tolua:
        luadir = os.path.realpath(cur_dir + '/../zh_cn/lua/data')
        delfiles(luadir)

    if os.path.isfile(cur_dir):
        cur_dir = os.path.dirname(cur_dir)
    data_path = os.path.realpath(cur_dir + '/../excel/excel_StaticData')
    files = listExcels(data_path)
    
    for f in files:
        if not f.startswith('__') and not f.startswith('~$'):
            root = f

            data = parse_xls(data_path + '/' + f)
            

            if toxml:
                doc = libxml2.parseDoc('<' + root.split('.')[0] + '/>')
                for k, v in data.items():
                    k = filter(lambda x:x not in '0123456789',k)
                    k = re.sub(u"\\（.*?）|\\{.*?}|\\[.*?]|\\【.*?】", "", k.decode())
                    k = re.sub(u"\\(.*?\\)|\\{.*?}|\\[.*?]", "", k)
                    if not k.startswith('node_'):
                        print_to_xml(doc, doc.getRootElement(), k, v)
                fname = os.path.realpath(xmldir) + '/' + f.split('.')[0] + ".xml"
                print "fname"
                print fname
                of = file(fname, 'w+')
                desc = descContect(data_path + '/' + f)
                with(of): 
                    of.write(doc.serialize('UTF-8', 1))
                    if len(desc) > 0:
                        of.write("<!--\n")
                        of.write(desc)
                        of.write("\n-->\n")
            if tolua:
                lua_txt = 'local ' + f.split('.')[0]  + '=' + serialToLua(data) + '\n' + 'return ' + f.split('.')[0]
                fname = os.path.realpath(luadir) + '/' + f.split('.')[0] + ".lua"
                #print fname
                of = file(fname, 'w+')
                with(of):
                    of.write(lua_txt)
                    
def singleConvert():
    cur_dir = sys.path[0]
    xmldir = os.path.realpath(cur_dir + '/../StaticData')
    root = tname.split('/')[-1] 
    data = parse_xls(tname)
    doc = libxml2.parseDoc('<' + root.split('.')[0] + '/>')
    for k, v in data.items():
        k = filter(lambda x:x not in '0123456789',k)
        k = re.sub(u"\\（.*?）|\\{.*?}|\\[.*?]|\\【.*?】", "", k.decode())
        k = re.sub(u"\\(.*?\\)|\\{.*?}|\\[.*?]", "", k)
        if not k.startswith('node_'):
            print_to_xml(doc, doc.getRootElement(), k, v)
    fname = os.path.realpath(xmldir) + '/' + root.split('.')[0] + ".xml"
    print fname
    of = file(fname, 'w+')
    desc = descContect(tname)
    with(of): 
        of.write(doc.serialize('UTF-8', 1))
        if len(desc) > 0:
            of.write("<!--\n")
            of.write(desc)
            of.write("\n-->\n")
    
    
def singleConvertLocal():
    cur_dir = sys.path[0]
    xmldir = os.path.realpath(cur_dir + '/../StaticData')
    data_path = os.path.realpath(cur_dir + '/../excel/excel_StaticData')
    root = tname.split('/')[-1] 
    data = parse_xls(data_path + '/' + root)
    doc = libxml2.parseDoc('<' + root.split('.')[0] + '/>')
    for k, v in data.items():
        k = filter(lambda x:x not in '0123456789',k)
        k = re.sub(u"\\（.*?）|\\{.*?}|\\[.*?]|\\【.*?】", "", k.decode())
        k = re.sub(u"\\(.*?\\)|\\{.*?}|\\[.*?]", "", k)
        if not k.startswith('node_'):
            print_to_xml(doc, doc.getRootElement(), k, v)
    fname = os.path.realpath(xmldir) + '/' + root.split('.')[0] + ".xml"
    print fname
    of = file(fname, 'w+')
    desc = descContect(data_path + '/' + root)
    with(of): 
        of.write(doc.serialize('UTF-8', 1))
        if len(desc) > 0:
            of.write("<!--\n")
            of.write(desc)
            of.write("\n-->\n")
        
    
    
    
if __name__ == '__main__':
    if tname == "":
        convert()
    else:
        if ttype == "1":
            singleConvertLocal()
        else:
            singleConvert()

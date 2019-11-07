#coding=utf-8
import sys  
reload(sys)  
sys.setdefaultencoding('utf-8')

import os
import shutil
import xlrd, libxml2
import re

def listExcels(path):
    ret = []
    for root, dirs, files in os.walk(path):
        for f in files:
            parts = f.split('.')
            if len(parts) == 2 and parts[1] == 'xls':
                p = root + '/' + f
                p = p[len(path):len(p)]
                if p[0] == '/':
                    p = p[1:len(p)]
                ret.append(p)
    return ret


def parse_row(f, mapRow):
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

        #table.name是子表名
        if table.name == "Map":
            node = dict()
            print "Map_" + str(int(table.cell(mapRow, 0).value))
            for j in xrange(table.ncols):
                if len(fields[j]) < 1 or fields[j].startswith('//'):
            		continue
                value = unicode(table.cell(mapRow, j).value) 
                if type(table.cell(mapRow, j).value) == type(1.0):
                    value = table.cell(mapRow, j).value

                    if value.is_integer():
                        value = str(int(value))
                    else:
                        value = str(value)

                node[fields[j]] = value
            items.append(node)
        else:
            for i in xrange(1, table.nrows):
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
                    #del node['ref_ident']
                    #del node['node_name']
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
    
def parse_chapter(f, beginRow, endRow):
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
        if table.name == "Troop":
            print "Troop_" + str(int((table.cell(beginRow, 0).value)/100))
            for i in xrange(beginRow, endRow + 1):
                node = dict()
                for j in xrange(table.ncols):
                    #print table.name + "..." + fields[j]
                    if len(fields[j]) < 1 or fields[j].startswith('//'):
                        continue
                    value = unicode(table.cell(i, j).value)  
                    if type(table.cell(i, j).value) == type(1.0):
                        value = table.cell(i, j).value
                        if value.is_integer():
                            value = str(int(value))
                        else:
                            value = str(value)
                    #if sname == "Troop_102":
                        #print table.name + "..." + fields[j] + "..." + value
                    node[fields[j]] = value
                items.append(node)
        else:
            for i in xrange(1, table.nrows):
                node = dict()
                for j in xrange(table.ncols):
                    #print table.name + "..." + fields[j]
                    if len(fields[j]) < 1 or fields[j].startswith('//'):
                        continue
                    value = unicode(table.cell(i, j).value)  
                    if type(table.cell(i, j).value) == type(1.0):
                        value = table.cell(i, j).value
                        if value.is_integer():
                            value = str(int(value))
                        else:
                            value = str(value)
                    #if sname == "Map_102":
                        #print table.name + "..." + fields[j] + "..." + value
                    node[fields[j]] = value
                items.append(node)
        root[table.name] = items
    for k, v in root.items():
        if k.startswith('node_'):
            name = k[5:]
            name = filter(lambda x:x not in '0123456789',name)
            name = re.sub(u"\\（.*?）|\\{.*?}|\\[.*?]|\\【.*?】", "", name.decode())
            name = re.sub(u"\\(.*?\\)|\\{.*?}|\\[.*?]", "", name)
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
                    #del node['ref_ident']
                    #del node['node_name']
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
    
def parse_xls(f):
    root = dict()
    xls = xlrd.open_workbook(f)
    sname = f[-13:-4]
    print sname
    #print xls.sheet_by_index(0).nrows
    if len(xls.sheets()) == 0:
        return root
    for table in xls.sheets():
        if table.ncols == 0:
            continue
        fields = list()
        for i in xrange(table.ncols):
            fields.append(unicode(table.cell(0, i).value))
        items = list()
        for i in xrange(1, table.nrows):
            node = dict()
            for j in xrange(table.ncols):
                #print table.name + "..." + fields[j]
            	if len(fields[j]) < 1 or fields[j].startswith('//'):
            		continue
                value = unicode(table.cell(i, j).value)  
                if type(table.cell(i, j).value) == type(1.0):
                    value = table.cell(i, j).value
                    if value.is_integer():
                        value = str(int(value))
                    else:
                        value = str(value)
                #if sname == "Map_102":
                    #print table.name + "..." + fields[j] + "..." + value
                node[fields[j]] = value
            items.append(node)
        root[table.name] = items
    for k, v in root.items():
        k = filter(lambda x:x not in '0123456789',k)
        k = re.sub(u"\\（.*?）|\\{.*?}|\\[.*?]|\\【.*?】", "", k.decode())
        k = re.sub(u"\\(.*?\\)|\\{.*?}|\\[.*?]", "", k)
        if k.startswith('node_'):
            name = k[5:]
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

def print_to_xml(root, name, data): 

    for v in data:
        node = libxml2.newNode(name)
        for k1, v1 in v.items():
            #print "k1"
            #print k1
            
            if isinstance(v1, list):
                print_to_xml(node, k1, v1)
                continue
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
        xmldir = os.path.realpath(cur_dir + '/../Map/Campaign')
        delfiles(xmldir)
        
    if tolua:
        luadir = os.path.realpath(cur_dir + '/../zh_cn/lua/data')
        delfiles(luadir)

    if os.path.isfile(cur_dir):
        cur_dir = os.path.dirname(cur_dir)
    data_path = os.path.realpath(cur_dir + '/../excel/excel_Map/Campaign')
    files = listExcels(data_path)
    for f in files:
        root = f.split('/')[-1]
        #print "f   root      "
        #print root[0:3]
        #root是文件名 
        #xlsname = f[-11:-8]
        #print "name  " + xlsname
        if root[0:3] == "Map":
            #data = parse_xls(data_path + '/' + f)
            xls = xlrd.open_workbook(data_path + '/' + f)
            #print "row num"
            #print xls.sheet_by_index(0).nrows
            for mapRow in range(1,xls.sheet_by_index(0).nrows):
                data = parse_row(data_path + '/' + f, mapRow)
                if toxml:
                    doc = libxml2.parseDoc('<' + "Map_" + str(int(xls.sheet_by_index(0).row(mapRow)[0].value)) + '/>')
                    #doc = libxml2.parseDoc('<' + root.split('.')[0] + '/>')
                    #print "split"
                    #print root.split('.')[0]
                    for k, v in data.items():
                        #print "k, v in data.items():"
                        #print k
                        #k = 子表名
                        if not k.startswith('node_'):
                            print_to_xml(doc.doc.getRootElement(),k, v)
                    fname = os.path.realpath(xmldir) + '/' + "Map_" + str(int(xls.sheet_by_index(0).row(mapRow)[0].value)) + ".xml"
                    #fname = os.path.realpath(xmldir) + '/' + f.split('.')[0] + ".xml"
                    #print f[-11:-1]
                    #print xls.sheet_by_index(0).row(mapRow)[0].value
                    #print fname
                    of = file(fname, 'w+')
                    with(of):
                        of.write(doc.serialize('UTF-8', 1))
                    
        else:
            if root[0:5] == "Troop":
                xls = xlrd.open_workbook(data_path + '/' + f)
                for mapRow in range(1,xls.sheet_by_index(0).nrows):
                    now_id = str(int(xls.sheet_by_index(0).row(mapRow)[0].value))
                    now_id = now_id[0:3]
                    if mapRow > 1:
                        old_id = str(int(xls.sheet_by_index(0).row(mapRow - 1)[0].value))
                        old_id = old_id[0:3]
                    else:
                        old_id = ""
                    if not int(mapRow) == int(xls.sheet_by_index(0).nrows) - 1:
                        next_id = str(int(xls.sheet_by_index(0).row(mapRow +1)[0].value))
                        next_id = next_id[0:3]
                    else:
                        next_id = ""
                    if old_id == "":
                        beginRow = 1
                    else:
                        if not old_id == now_id:
                            beginRow = mapRow
                    if not now_id == next_id or next_id == "":
                        endRow = mapRow
                        
                        data = parse_chapter(data_path + '/' + f, beginRow, endRow)

                        if toxml:
                            #tnum = str(int((xls.sheet_by_index(0).row(beginRow)[0].value)/100))
                            doc = libxml2.parseDoc('<Troop_' + now_id[0:3] + '/>')

                            for k, v in data.items():
                                if not k.startswith('node_'):
                                    print_to_xml(doc.doc.getRootElement(), k, v)
                            fname = os.path.realpath(xmldir) + "/Troop_" + now_id[0:3] + ".xml"
                            of = file(fname, 'w+')
                            with(of):
                                of.write(doc.serialize('UTF-8', 1))



if __name__ == '__main__':
    convert()

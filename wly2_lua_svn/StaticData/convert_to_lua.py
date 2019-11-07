#coding=utf-8
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import os
import shutil
import libxml2

def listXmls(path):
    ret = []
    for root, dirs, files in os.walk(path):
        for f in files:
            parts = f.split('.')
            if len(parts) == 2 and parts[1] == 'xml':
                p = root + '/' + f
#                print p  + "   " + root + "   " + f
                p = p[len(path):len(p)]
                if p[0] == '/':
                    p = p[1:len(p)]
                ret.append(p)
    return ret

def transferNode(node):
    obj = dict()
    if node.properties is not None:
        for p in node.properties:
            if p.type != 'attribute':
                continue
            obj[p.name] = unicode(p.content)
    if node.children and node.children.next is None and node.children.type == 'text':
        tmp_str = unicode(node.children.content.strip(' \n\r\t'))
        if len(tmp_str) > 0:
            obj['content'] = tmp_str
    children = dict()
    child = node.children
    while child is not None:
        if child.type == 'element':
            l = children.get(child.name)
            if l is None:
                l = list()
                children.update({child.name: l})
            l.append(transferNode(child))
        child = child.next
    for k in children:
        l = children[k]
        first_item = l[0]
        if type(first_item) != type(dict()):
            continue

        for k1 in first_item:
            is_int = True
            is_float = True
            for item in l:
                if type(item) != type(dict()):
                    continue
                if item.get(k1) is None:
                    continue
                if is_int:
                    try:
                        int(item[k1])
                    except:
                        is_int = False
                if not is_int and is_float:
                    try:
                        float(item[k1])
                    except:
                        is_float = False
                if not is_int and not is_float:
                    break
            if is_int:
                for item in l:
                    if item.get(k1) is None:
                        continue
                    item[k1] = int(item[k1])
            elif is_float:
                for item in l:
                    if item.get(k1) is None:
                        continue
                    item[k1] = float(item[k1])
    for k in children:
        #if len(children[k]) == 1:
        #    obj.update({k : children[k][0]})
        #    continue
        all_has_ident = True
        objs = dict()
        for v in children[k]:
            if not isinstance(v, dict):
                all_has_ident = False
                break
            if v.get('ident') is None:
                all_has_ident = False
                break
            try:
                ident = int(v.get('ident'))
                objs[ident] = v;
            except:
                all_has_ident = False
        if all_has_ident:
            obj.update({k : objs})
        else:
            obj.update({k : children[k]})
    return obj

def serialToLua(v, depth = None):
    ret = ''

    cur_fill = ('\n' + ('\t' * (depth - 1)) if depth is not None and depth > 0 else '')
    fill = '\t' * depth if depth is not None else ''
    if isinstance(v, dict):
        data = ''
        for k in v.keys():
            if len(data) > 0:
                data = data + ',' + '\n'
            if type(k) == type(int()):
                data = data + fill + '[' + str(k) + ']' + '=' + serialToLua(v[k], depth + 1 if depth is not None else None)
            else:
                data = data + fill +'[\'' + str(k) + '\']' + '=' + serialToLua(v[k], depth + 1 if depth is not None else None)
        return cur_fill + '{\n' + data + cur_fill + '}'
    if isinstance(v, list):
        data = ''
        for k in v:
            if len(data) > 0:
                data = data + ',' + "\n"
            if isinstance(k, dict) and k.has_key('ident'):
                num = k['ident']
                data = data +'['+ str(num) + ']' + '='+serialToLua(k, depth + 1 if depth is not None else None)
            else:
                data = data + serialToLua(k, depth + 1 if depth is not None else None)
        return cur_fill + '{\n' + data + cur_fill + '}'
    if isinstance(v,str) or isinstance(v, unicode):
        return '"' + v.replace('"', '\\"') + '"'
    else:
        return str(v)

def parseXml(f):
    data = dict()
    doc = libxml2.parseFile(f)
    root = doc.getRootElement()
    return root.name, transferNode(root)

def convert():
    cur_dir = sys.path[0]
    if os.path.isfile(cur_dir):
        cur_dir = os.path.dirname(cur_dir)

    xml_path = os.path.realpath(cur_dir + '/xml/' + sys.argv[1])
    lua_path = os.path.realpath(cur_dir + '/lua/' + sys.argv[1])
    files = listXmls(xml_path)
    for f in files:
        root = f.split('/')[-1]
        file_path = xml_path + '/' + f
        data = parseXml(file_path)
        lua_txt = 'local ' + data[0]  + '=' + serialToLua(data[1], 0) + '\n' + 'return ' + data[0]
        lua_file_path = lua_path + '/' + f.split('.')[0] + '.lua'
        dir_name = os.path.dirname(lua_file_path)
        if not os.path.exists(dir_name):
            os.makedirs(dir_name)
        of = file(lua_file_path, 'w+')
        with(of):
            of.write(lua_txt)
        print lua_file_path

def convertFile(f):
    cur_dir = sys.path[0]
    if os.path.isfile(cur_dir):
        cur_dir = os.path.dirname(cur_dir)

    xml_path = os.path.realpath(cur_dir + '/xml/' + sys.argv[1])
    lua_path = os.path.realpath(cur_dir + '/lua/' + sys.argv[1])
    root = f.split('/')[-1]
    file_path = xml_path + '/' + f
    data = parseXml(file_path)
    lua_txt = 'local ' + data[0]  + '=' + serialToLua(data[1], 0) + '\n' + 'return ' + data[0]
    lua_file_path = lua_path + '/' + f.split('.')[0] + '.lua'
    dir_name = os.path.dirname(lua_file_path)
    if not os.path.exists(dir_name):
        os.makedirs(dir_name)
    of = file(lua_file_path, 'w+')
    with(of):
        of.write(lua_txt)
    print lua_file_path

if __name__ == '__main__':
    if len(sys.argv) < 2:
        exit('Usage python convert_to_lua.py DIR')
    if len(sys.argv) == 2:
        convert()
    if len(sys.argv) == 3:
        convertFile(sys.argv[2])

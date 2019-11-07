#encode utf-8
import urllib
import json
from urllib.request import urlopen
from pprint import pprint

def send_URL(url):
    u = urlopen(url)
    response = json.loads(u.read().decode('utf-8'))
    return response

def controller(login_name):
    functions = {'get_information':"http://10.0.253.49:9231/rest/admin/account?type=3&value={0}",
                 'update_building':"http://10.0.253.49:9231/rest/admin/build?accid={0}&op=update&id={1}&level={2}",
                 'get_resource':"http://10.0.253.49:9231/rest/admin/role?accid={0}&op=update&res_str={1}%3B{2}%3B{3}",
                 'update_vipLV':"http://10.0.253.49:9231/rest/admin/role?accid={0}&op=update&VIP={1}"}
    information = send_URL(functions['get_information'].format(login_name))
    print("角色信息：")
    pprint(information['data'][0])
    accid = information['data'][0]['accid']
    print("\n1.修改建筑等级\n2.获取资源（Type.xml内物品）\n3.修改VIP等级（上限15）\n")
    while(1):
        argument = int(input("输入功能编号："))
        if argument == 1:
            building_id = input("建筑id：")
            building_lv = input("目标等级：")
            print(send_URL(functions['update_building'].format(accid,building_id,building_lv)))
        elif argument == 2:
            print("ident=0;name=无\nident=1;name=战功\nident=2;name=民心\nident=3;name=征收CD\nident=4;name=征收次数\nident=5;name=粮食\nident=7;name=将魂\nident=9;name=军令\nident=10;name=政绩\nident=11;name=军勋\nident=22;name=竞技场积分\nident=25;name=VIP经验值\nident=28;name=古城币\nident=29;name=试炼塔币\nident=101;name=银两\nident=102;name=元宝\nident=103;name=威望\n")
            print("ident=151;name=其他:其他物品、知己升级、装备洗炼、顿悟材料;file=material\nident=152;name=装备;file=items\nident=153;name=武将;file=generals\nident=155;name=品阶材料;file=advanceData\nident=156;name=洗练材料;file=attstones\n")
            type_ident = input("Type.xml中的ident：")
            num = input("数量：")
            if int(type_ident) < 150:
                print(send_URL(functions['get_resource'].format(accid,type_ident,num,0)))
            else:
                other_ident = input("file值指向表内ident：")
                print(send_URL(functions['get_resource'].format(accid,type_ident,num,other_ident)))
        elif argument == 3:
            vip_lv = input("目标等级：")
            print(send_URL(functions['update_vipLV'].format(accid,vip_lv)))
        else:
            print('参数错误')

if __name__ == "__main__":
    while(1):
        try:
            login_name = input("输入登录账号：")
            controller(login_name)
        except KeyError:
            print("账号错误，重新输入\n")

#coding=utf-8
__author__ = 'bhn'
import sys
sys.path.append('..')
from operate import Bridge
import time
'''
运行游戏->登录->选服->进入游戏
'''
img_path = 'login'
bridge = Bridge.Bridge()
class StartGame:
    def click(self, name, action, point_id = 0):
        bridge.click(name, action, img_path, point_id)
    def input_message(self,message):
        bridge.input_message(message)

    def open_geme(self):
        self.click("logo", "打开游戏")
        # 加载
        time.sleep(3)
    def start(self):
        self.click("sign_in","登录游戏")
        self.click("change_server","进入服务器列表")
        self.click("return","返回")
        self.click("change_server","进入服务器列表")
        self.click("server_list_1","切换服务器列表")
        self.click("server_intranet_3","选择测试服3服")
        self.click("sign_in","登录游戏")
        #加载
        time.sleep(3)
    def account_password(self, account_number = 10086, password = 123):
        self.click("account_number", "点击账号输入框")
        self.input_message(str(account_number))
        #self.click("password", "点击密码输入框")
        #self.input_message(str(password))
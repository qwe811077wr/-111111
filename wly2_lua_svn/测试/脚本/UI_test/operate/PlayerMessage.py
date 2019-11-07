#coding=utf-8
__author__ = 'bhn'
import sys

sys.path.append('..')
from operate import Bridge
import time

'''
主公信息
posation_id为点击位置编号：
1  2  3
   9
4  0  5
   10
6  7  8
'''
img_path = 'player_message'
bridge = Bridge.Bridge()

class PlayerMessage:
    def click(self, name, action, point_id = 0):
        bridge.click(name, action, img_path, point_id)
    def change_head_portrait(self):
        self.click("change_head_portait","点击更换头像")
    def choose_head_portrait(self):
        self.click("head_2","点击女头像")
        self.click("head_1", "点击男头像")
        self.click("head_2", "点击女头像")
    def setting(self):
        self.click("setting","点击设置")
    def change_account(self):
        self.click("change_account","点击切换账号")
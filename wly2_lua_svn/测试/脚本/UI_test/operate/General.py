#coding=utf-8
__author__ = 'bhn'
import sys

sys.path.append('..')
from operate import Bridge
import time

'''
武将信息界面
posation_id为点击位置编号：
1  2  3
   9
4  0  5
   10
6  7  8
'''
img_path = 'general'
bridge = Bridge.Bridge()


class General:
    def click(self, name, action, point_id=0):
        bridge.click(name, action, img_path, point_id)
    def epiphany_info(self):
        self.click("epiphany","切换")
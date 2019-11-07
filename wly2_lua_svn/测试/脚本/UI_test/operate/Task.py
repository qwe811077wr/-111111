#coding=utf-8
__author__ = 'bhn'
import sys

sys.path.append('..')
from operate import Bridge
import time

'''
任务弹窗
posation_id为点击位置编号：
1  2  3
   9
4  0  5
   10
6  7  8
'''
img_path = 'task'
bridge = Bridge.Bridge()


class Task:
    def click(self, name, action, point_id=0):
        bridge.click(name, action, img_path, point_id)
    def back(self):
        self.click("back","退回")
#coding=utf-8
__author__ = 'bhn'
import sys

sys.path.append('..')
from operate import Bridge
import time

'''
确认弹窗
posation_id为点击位置编号：
1  2  3
   9
4  0  5
   10
6  7  8
'''
img_path = 'verify'
bridge = Bridge.Bridge()

class Verify:
    def click(self, name, action, point_id = 0):
        bridge.click(name, action, img_path, point_id)
    def cancel_1(self):
        self.click("cancel_1","取消")
    def sure_1(self):
        self.click("sure_1", "确认")
    def cancel_2(self):
        self.click("cancel_2", "取消")
    def sure_2(self):
        self.click("sure_2", "确认")
    def dt_remind_1(self):
        self.click("dt_remind_1", "勾选不再提醒")
    def dt_remind_2(self):
        self.click("dt_remind_2", "取消勾选不再提醒")
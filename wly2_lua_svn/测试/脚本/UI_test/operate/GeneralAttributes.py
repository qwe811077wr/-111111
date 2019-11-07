#coding=utf-8
__author__ = 'bhn'
import sys

sys.path.append('..')
from operate import Bridge
import time

'''
武将属性
posation_id为点击位置编号：
1  2  3
   9
4  0  5
   10
6  7  8
'''
img_path = 'general_attributes'
bridge = Bridge.Bridge()


class GeneralAttributes:
    def click(self, name, action, point_id=0):
        bridge.click(name, action, img_path, point_id)
    def slide(self, ending_point, name, action, point_id=0):
        bridge.slide(ending_point, name, action, img_path, point_id)
    def change_troops(self):
        #滑块左(1215, 320)
        left_point = (1215, 320)
        #滑块右(1818, 320)
        right_point = (1810, 320)
        self.slide(left_point, "troops","调整兵力（减少）")
        self.slide(right_point, "troops","调整兵力（增加）")
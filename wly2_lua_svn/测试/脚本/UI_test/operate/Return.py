#coding=utf-8
__author__ = 'bhn'
import sys
sys.path.append('..')
from operate import Bridge
import time

'''
左上角返回按钮功能
'''
img_path = 'return'
class Return:
    def click(self, name, action, point_id = 0):
        bridge = Bridge.Bridge().click(name, action, img_path, point_id)
    def start(self):
        self.click("return","返回")
        #加载
        time.sleep(3)

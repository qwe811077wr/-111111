#coding=utf-8
__author__ = 'bhn'
import sys

sys.path.append('..')
from operate import Bridge
import time

'''
选择势力
posation_id为点击位置编号：
1  2  3
   9
4  0  5
   10
6  7  8
'''
img_path = 'choose_country'
bridge = Bridge.Bridge()
class ChooseCountry:
    def click(self, name, action, point_id = 0):
        bridge.click(name, action, img_path, point_id)
    def choose(self):
        self.click("wei","选择魏")
        self.click("wei_return","从魏返回",4)
        self.click("shu","选择蜀")
        self.click("shu_return","从蜀返回",4)
        self.click("wu","选择吴")
        self.click("wu_return","从吴返回",4)
        #self.click("random","选择随机")
    def choose_wei(self):
        self.click("wei", "选择魏")
        self.click("sure","确认")
        time.sleep(3)
    def choose_shu(self):
        self.click("shu", "选择蜀")
        self.click("sure", "确认")
        time.sleep(3)
    def choose_wu(self):
        self.click("wu", "选择吴")
        self.click("sure", "确认")
        time.sleep(3)
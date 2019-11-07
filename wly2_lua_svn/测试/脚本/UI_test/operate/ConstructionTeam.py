#coding=utf-8
__author__ = 'bhn'
import sys

sys.path.append('..')
from operate import Bridge
import time

'''
建筑队列弹窗
posation_id为点击位置编号：
1  2  3
   9
4  0  5
   10
6  7  8
'''
img_path = 'construction_team'
bridge = Bridge.Bridge()


class ConstructionTeam:
    def click(self, name, action, point_id=0):
        bridge.click(name, action, img_path, point_id)
    def _return(self):
        self.click("yes","关闭建筑队列弹窗",5)
    def get_construction_team(self):
        self.click("yes","开通新的建筑队",4)
    def open_construction_team(self):
        self.click("open","解锁建筑队")
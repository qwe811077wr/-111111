#coding=utf-8
__author__ = 'bhn'
import sys
sys.path.append('..')
from operate import Bridge
import time

'''
主城内菜单
posation_id为点击位置编号：
1  2  3
   9
4  0  5
   10
6  7  8
'''
img_path = 'main_city'
bridge = Bridge.Bridge()
class MainCity:
    def click(self, name, action, point_id = 0):
        bridge.click(name, action, img_path, point_id)
    def sidebar_task(self):
        self.click("sidebar_list_arrow2","侧边栏内任务箭头",2)
    def sidebar_technology(self):
        self.click("sidebar_list_arrow2","侧边栏内科技箭头",9)
    def sidebar_training(self):
        self.click("sidebar_list_arrow2","侧边栏内训练箭头")
    def sidebar_farmland(self):
        self.click("sidebar_list_arrow2", "侧边栏内农田箭头", 10)
    def sidebar_construction_team(self):
        self.click("sidebar_list_arrow2", "侧边栏内建筑队箭头", 7)
    def sidebar(self):
        self.click("sidebar_arrow_left","收起侧边栏",1)
        self.click("right_menu_arrow_right","收起右侧菜单",2)
        self.click("low_menu_arrow_right","收起底部菜单",4)
        self.click("sidebar_arrow_right","打开侧边栏",7)
        self.click("right_menu_arrow_left","打开右侧菜单", 8)
        self.click("low_menu_arrow_left","打开底部菜单", 4)
    def low_left_task(self):
        self.click("low_left_menu","左下角任务",1)
    def low_left_season(self):
        self.click("low_left_menu","左下角季节",6)
    def low_left_chat(self):
        self.click("low_left_menu","左下角聊天框",8)
    def player_message(self):
        self.click("head_portrait","点击头像")
    def add_gold(self):
        self.click("add_gold","点击+号")
    def building_technology(self):
        return 0
#coding=utf-8
__author__ = 'bhn'
import sys
sys.path.append('..')
from operate import Bridge
import time

'''
主菜单
'''
img_path = 'main_menu'
bridge = Bridge.Bridge()
class MainMenu:
    def click(self, name, action, point_id = 0):
        bridge.click(name, action, img_path, point_id)
    def enter_home(self):
        self.click("home", "进入府邸界面")
    def enter_legion(self):
        self.click("legion", "进入军团界面")
    def enter_formation(self):
        self.click("formation", "进入阵型界面")
    def enter_warehouse(self):
        self.click("warehouse","进入仓库界面")
    def enter_general(self):
        self.click("general","进入武将界面")
    def enter_instance(self):
        self.click("instance","进入副本界面")
    def enter_main_city(self):
        self.click("main_city","进入主城界面")
    def open_ranking(self):
        self.click("ranking","打开排行榜界面")
    def open_active(self):
        self.click("active","打开活动界面")
    def open_daily(self):
        self.click("daily","打开日常界面")
    def open_task(self):
        self.click("task","打开任务界面")
    def open_mail(self):
        self.click("mail","打开邮件界面")
    def enter_world(self):
        self.click("world","进入世界界面")
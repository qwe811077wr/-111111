#coding=utf-8
__author__ = 'bhn'
import sys

sys.path.append('..')
from lib import ClickEvent
import time

'''
调用点击事件
posation_id为点击位置编号：
1  2  3
   9
4  0  5
   10
6  7  8
'''
click_event = ClickEvent.ClickEvent()

class Bridge:
    def click(self, sprit_name, action, img_path, point_id=0):
        result = click_event.click_click(sprit_name, img_path, point_id)
        print(result[0] + '------' + action + '------匹配度：' + str(result[1]))
        if result[0] == 'success':
            time.sleep(0.5)
        elif result[0] == 'fail':
            exit(0)

    def input_message(self, message):
        click_event.input_message(message)
        time.sleep(0.5)
        print('输入文本内容：' + message)

    def slide(self, ending_point, sprit_name, action, img_path, point_id=0):
        result = click_event.slide_slide(ending_point,sprit_name,img_path,point_id)
        print(result[0] + '------' + action + '------匹配度：' + str(result[1]))
        if result[0] == 'success':
            time.sleep(0.5)
        elif result[0] == 'fail':
            exit(0)
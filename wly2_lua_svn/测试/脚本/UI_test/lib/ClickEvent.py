#coding=utf-8
__author__ = 'bhn'
import subprocess
import cv2
from lib import AdbCommands

'''
匹配图片，触发点击事件
posation_id为点击位置编号：
1  2  3
   9
4  0  5
   10
6  7  8
'''
adb = AdbCommands.AdbCommands()
class ClickEvent:
    def get_point(self, sprite,max_location ,point_id = 0):
        # 找到find_image的位置
        fi_h, fi_w = sprite.shape[:2]
        pointUpLeft = max_location
        pointUpCenter = (max_location[0] + (fi_w // 2), max_location[1])
        pointUpRight = (max_location[0] + fi_w, max_location[1])
        pointLowLeft = (max_location[0], max_location[1] + fi_h)
        pointLowCenter = (max_location[0] + (fi_w // 2), max_location[1] + fi_h)
        pointLowRight = (max_location[0] + fi_w, max_location[1] + fi_h)
        pointCenterLeft = (max_location[0], max_location[1] + (fi_h // 2))
        pointCenter = (max_location[0] + (fi_w // 2), max_location[1] + (fi_h // 2))
        pointCenter9 = (max_location[0] + (fi_w // 2), max_location[1] + (fi_h // 4))
        pointCenter10 = (max_location[0] + (fi_w // 2), max_location[1] + (fi_h * 3 // 4))
        pointCenterRight = (max_location[0] + fi_w, max_location[1] + (fi_h // 2))
        if point_id == 0:
            point = pointCenter
        elif point_id == 1:
            point = pointUpLeft
        elif point_id == 2:
            point = pointUpCenter
        elif point_id == 3:
            point = pointUpRight
        elif point_id == 4:
            point = pointCenterLeft
        elif point_id == 5:
            point = pointCenterRight
        elif point_id == 6:
            point = pointLowLeft
        elif point_id == 7:
            point = (pointLowCenter)
        elif point_id == 8:
            point = pointLowRight
        elif point_id == 9:
            point = pointCenter9
        elif point_id == 10:
            point = pointCenter10
        return point
    def match_match(self,sprite_name,img_path,point_id = 0):
        adb.get_screenshots()
        screenshot = cv2.imread("lib/screenshot/screenshot.jpg")
        sprite = cv2.imread("lib/sprite/" + img_path + "/" + sprite_name + ".png")
        #匹配算法，在screenshot中匹配到sprite
        result = cv2.matchTemplate(screenshot,sprite,cv2.TM_CCOEFF_NORMED)
        #计算最小匹配度、最大匹配度、最小匹配位置、最大匹配位置（左上原点，向右、向下为正）
        min_value,max_value,min_location,max_location = cv2.minMaxLoc(result)
        matching = round(max_value,3)
        if max_value < 0.75:
            x = "fail"
            return x,matching
        else:
            point = self.get_point(sprite, max_location, point_id)
            return point,matching

    def click_click(self,sprite_name,img_path,point_id = 0):
        result = self.match_match(sprite_name,img_path,point_id)
        matching = result[1]
        if result[0] == 'fail':
            x = "fail"
            return x, matching
        else:
            x = "success"
            point = result[0]
            adb.click(point)
            return x, matching

    def input_message(self, message):
        adb.input_message_text(message)

    def slide_slide(self,ending_point,sprite_name,img_path,point_id = 0):
        result = self.match_match(sprite_name,img_path,point_id)
        matching = result[1]
        if result[0] == 'fail':
            x = "fail"
            return x, matching
        else:
            x = "success"
            starting_point = result[0]
            adb.slide(starting_point, ending_point)
            print(starting_point)
            return x, matching

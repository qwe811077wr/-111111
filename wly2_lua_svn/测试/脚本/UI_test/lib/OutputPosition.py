#coding=utf-8
__author__ = 'bhn'
import subprocess
import cv2
import AdbCommands

adb = AdbCommands.AdbCommands()
def get_point(sprite_name,img_path):
    adb.get_screenshots()
    screenshot = cv2.imread("E:/openCV_test/UITest_OpenCV/lib/screenshot/screenshot.jpg")
    sprite = cv2.imread("E:/openCV_test/UITest_OpenCV/lib/sprite/" + img_path + "/" + sprite_name + ".png")
    #匹配算法，在screenshot中匹配到sprite
    result = cv2.matchTemplate(screenshot,sprite,cv2.TM_CCOEFF_NORMED)
    #计算最小匹配度、最大匹配度、最小匹配位置、最大匹配位置（左上原点，向右、向下为正）
    min_value,max_value,min_location,max_location = cv2.minMaxLoc(result)
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
    #画点
    cv2.circle(screenshot, pointCenterLeft, 2, (0, 255, 255), 10)
    cv2.circle(screenshot, pointCenter, 2, (255, 0, 255), 10)
    cv2.circle(screenshot, pointCenterRight, 2, (255, 255, 0), 10)
    print('左' + str(pointCenterLeft))
    print('右' + str(pointCenterRight))
    #显示点
    cv2.namedWindow("Image")
    cv2.imshow("Image", screenshot)
    cv2.waitKey(0)
    cv2.destroyAllWindows()


if __name__ == '__main__':
    get_point('troops','general_attributes')
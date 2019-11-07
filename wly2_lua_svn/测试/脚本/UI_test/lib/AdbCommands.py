#coding=utf-8
__author__ = 'bhn'
import subprocess

'''
adb命令->执行
'''
class AdbCommands:
    '''截图保存在手机内，再上传至电脑指定路径'''
    def get_screenshots(self):
        self.execution('adb shell screencap -p /storage/emulated/0/openCV/test/screenshot.jpg')
        self.execution('adb pull /storage/emulated/0/openCV/test/screenshot.jpg E:/openCV_test/UITest_OpenCV/lib/screenshot/')

    '''点击目标'''
    def click(self,point):
        self.execution('adb shell input tap ' + str(point[0]) + ' ' + str(point[1]))

    '''输入文本，回车确认关闭输入法'''
    def input_message_text(self,message):
        for i in range(10):
            #删除键
            self.execution('adb shell input keyevent 67')
        self.execution('adb shell input text \"' + message + '\"')
        #回车键
        self.execution('adb shell input keyevent 66')

    '''输入文本，点击返回键关闭输入法'''
    def input_message_textbox(self,message):
        for i in range(10):
            self.execution('adb shell input keyevent 67')
        self.execution('adb shell input text \"' + message + '\"')
        #返回键
        self.execution('adb shell input keyevent 4')

    '''模拟滑动'''
    def slide(self, starting_point, ending_point):
        self.execution('adb shell input swipe ' + str(starting_point[0]) + ' ' + str(starting_point[1]) + ' ' + str(ending_point[0]) + ' ' + str(ending_point[1]))

    '''执行adb命令'''
    def execution(self,cmd):
        subprocess.check_output(cmd)

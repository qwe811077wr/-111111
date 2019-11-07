#! /usr/bin/env python
# -*- coding: utf-8 -*-


import os
import socket
import threading
import time
import platform
from time import localtime, strftime

try:
    from watchdog.observers import Observer
    from watchdog.events import LoggingEventHandler
except ImportError:
    print("can not find watchdog module\ninstall watchdog module")

    if platform.system() == "Windows":
        os.system("pip install watchdog")
    elif platform.system() == "Darwin":
        os.system("sudo easy_install watchdog")
    else:
        print("please install watchdog by yourself")
        exit()
    from watchdog.observers import Observer
    from watchdog.events import LoggingEventHandler
 






changeFileDict = {}
mylock = threading.RLock()  

this_dir = os.path.dirname(os.path.realpath(__file__))
lua_source_dir = os.path.realpath(this_dir + "/../src/app")
# ccb_source_dir = os.path.realpath(this_dir + "/../res")
HOST = '127.0.0.1'
PORT = 2014
ADDR = (HOST, PORT)  

def log(msg):
    print(strftime("%Y-%m-%d %H:%M:%S", localtime()) + " " + msg)


class AutoSendHandler(LoggingEventHandler):
    def __init__(self):
        super(LoggingEventHandler, self).__init__()
        
    def on_any_event(self, event):
        print(event)
        if not (event.src_path.endswith(".lua") or event.src_path.endswith(".ccbi")):
            return
        if not changeFileDict.get(event.src_path):
            print(event.src_path)
            mylock.acquire()
            changeFileDict[event.src_path] = True
            mylock.release()
            print(changeFileDict)
  

class sendMsg(threading.Thread):
    """docstring for se"""
    def __init__(self):
        print("------------sendMsg-----------------")
        threading.Thread.__init__(self) 
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.settimeout(5)
        # self.sock.bind(ADDR)

    def run(self):
        while True:
            
            if len(changeFileDict) > 0:
                # print("--------------------1-----------------------")
                changeFile = ""
                for k in changeFileDict:
                    changeFile = changeFile + k +";"
                mylock.acquire()
                changeFileDict.clear()
                mylock.release()
                try:
                    # print("-------------------------------------------------------")
                    # log("send changeFile = %s" % (changeFile))
                    self.sock.sendto(changeFile, ADDR)
                    # log("wait for response ...")
                    # log("reply: " + self.sock.recv(8096))
                except socket.error, arg:
                    log("socket error: %s" % arg)
            
if __name__ == "__main__":
    log("listening to folder: " + lua_source_dir)
    sock = sendMsg()
    sock.daemon = True
    sock.start()
    observer = Observer()
    observer.daemon = True
    observer.schedule(AutoSendHandler(), lua_source_dir, recursive=True)
    # observer.schedule(AutoSendHandler(), ccb_source_dir, recursive=True)

    observer.start()
    # observer.join()
    while True:
        val = raw_input("put q to exit: ")
        if val == "q":
            exit()
        elif val:
            print("put q to exit: ")
        


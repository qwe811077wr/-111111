#coding=utf-8
__author__ = 'bhn'
from operate import StartGame,ChooseCountry
from operate import MainCity,MainMenu,PlayerMessage,ConstructionTeam,Task
from operate import GeneralAttributes
from operate import Verify,Return
import time

starting = StartGame.StartGame()
m_city = MainCity.MainCity()
_return = Return.Return()
m_menu = MainMenu.MainMenu()
con_team = ConstructionTeam.ConstructionTeam()
c_country = ChooseCountry.ChooseCountry()
task = Task.Task()
g_attributes = GeneralAttributes.GeneralAttributes()
class Conntroller:
    # 打开游戏，创建角色，进入游戏
    def start(self):
        starting.open_geme()
        starting.account_password('776611')
        starting.start()
        #选择势力
        c_country.choose()
        #确认势力
        c_country.choose_wu()

    # 主城菜单
    def main_city_menu(self):
        m_city.sidebar()
        m_city.sidebar_task()
        _return.start()
        m_city.sidebar_technology()
        _return.start()
        #main_city.sidebar_training()
        #main_city.sidebar_farmland()
        m_city.sidebar_construction_team()
        con_team._return()
        m_city.player_message()
        _return.start()
        m_city.low_left_task()
        task.back()
        #main_city.low_left_season()
        m_city.low_left_chat()
    # 建筑队
    def construction_team(self):
        con_team.get_construction_team()
        con_team.open_construction_team()
    #武将属性
    def general_attributes(self):
        g_attributes.change_troops()

c = Conntroller()
#c.start()
#c.main_city_menu()
c.general_attributes()
exit(0)

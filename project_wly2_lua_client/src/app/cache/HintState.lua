local HintState = class("HintState")

function HintState:ctor()
    self.status = {}
    self.RED_TYPE = {
        --主界面上的按钮红点
        MAIN_CITY_GENERALS          = 1,        --武将
        MAIN_CITY_WAREHOUSE         = 2,        --仓库
        MAIN_CITY_FORMATION         = 3,        --阵型
        MAIN_CITY_CROP              = 4,        --军团
        MAIN_CITY_BOSOM             = 5,        --府邸
        MAIN_CITY_RETAINER          = 6,        --关系

        MAIN_CITY_MAIL              = 31,        --邮件
        MAIN_CITY_TASK              = 32,        --任务
        MAIN_CITY_DAILY_ACTIVITY    = 33,        --日常
        MAIN_CITY_ACTIVITY          = 34,        --活动
        MAIN_CITY_RANK              = 35,        --排行
        MAIN_CITY_ACHIEVEMENT       = 36,        --福利

        --下边的宏作为除主界面外的子界面红点
        DAILY_TASK                  = 1001,       --日常任务
        ANCIENT                     = 1002,       --古城探秘
        FLY_NAIL                    = 1003,       --八门遁甲
        MAP_GUIDE                   = 1004,       --图鉴
        GENERALS_EQUIP              = 1005,       --装备可穿戴跟替换
        GENERALS_QUALITY            = 1006,       --品阶材料
        CROP_APPLY                  = 1007,       --军团申请
        ACHIEVEMENT_LEVEL           = 1008,       --探索之路
        ACHIEVEMENT_SIGN            = 1009,       --每日签到
        GENERALS_COMPOSE            = 1010,       --英魂合成界面
        GENERALS_INSIGHT            = 1011,       --武将顿悟
        ACHIEVEMENT_SEVEN           = 1012,       --七天狂欢
        GENERAL_ATTRIBUTE           = 1013,       --武将属性界面
        GENERAL_ARMS                = 1014,       --武将兵种界面
    }
end
return HintState
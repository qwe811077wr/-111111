local config = config or {}
config.servers = require('app.config.servers')
config.constant = require('app.config.constant')

config.APP_KEY = "13(*&@()9skkfs"
config.LOGIN_KEY = 'L@KF9m$04UO2(_RP?8ZU&9n'
config.SHARE_KEY = "68e0a2f2523397b"
config.STATIC_DATA_DIR = 'dataset_debug'
config.LANG = 'zh_cn'

config.res_addr = "http://s1.res.uqee.com/wly2_lua/resource"
config.live_download_path = cc.FileUtils:getInstance():getWritablePath() .. 'wly2_lua/live_download/'
config.battle_report_path = cc.FileUtils:getInstance():getWritablePath() .. 'wly2_lua/battle_report/'

config.OpenModule = require('app.config.OpenModule')

uq.config = config

local sdk = sdk or {}

sdk.platform 	= "vietnam"
sdk.platform_id = 1034
sdk.game_id 	= 53
sdk.game_tag 	= "test"
sdk.pay_url 	= ""
sdk.third_platform = sdk.platform
sdk.log_flag 	= 2 --1: 部落大乱斗 2: 萌新出击
sdk.open_pay 	= true

sdk.http_addr   = "http://gm-t2950.gaba.vn"
sdk.pay_url   	= sdk.http_addr .. "/rest/partner/yijie/mengxin/pay"
sdk.http_push_addr = "http://g.uqee.com" -- 外网个推推送
sdk.uqee_stat_addr = "http://www.uqee.com" -- 游奇上报url
sdk.uqee_stat_key = "MUFHzqClVnO8_7J5nsSwdYuGEu34pLlDtm9COByd"

uq.sdk = sdk

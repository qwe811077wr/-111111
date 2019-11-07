local sdk = sdk or {}

sdk.platform 	= "iclock"
sdk.platform_id = 1047
sdk.game_id 	= 53
sdk.game_tag 	= "iclock"
sdk.pay_url 	= ""
sdk.third_platform = "linghou"
sdk.log_flag 	= 2 --1: 部落大乱斗 2: 萌新出击
sdk.open_pay 	= true
sdk.ad_id = 442

sdk.http_addr   = "http://g.api.gamemorefun.com"
sdk.pay_url   	= sdk.http_addr .. "/rest/partner/morefun/mengxin/pay"
sdk.http_push_addr = "http://g.uqee.com" -- 外网个推推送
sdk.uqee_stat_addr = "http://www.uqee.com" -- 游奇上报url
sdk.uqee_stat_key = "MUFHzqClVnO8_7J5nsSwdYuGEu34pLlDtm9COByd"

uq.sdk = sdk

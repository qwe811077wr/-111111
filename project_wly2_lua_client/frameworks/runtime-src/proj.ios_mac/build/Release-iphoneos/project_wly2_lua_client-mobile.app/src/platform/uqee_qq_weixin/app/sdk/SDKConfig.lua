local sdk = sdk or {}

sdk.platform 	= "uqee"
sdk.ad_id = 450
sdk.platform_id = 15
sdk.game_id 	= 53
sdk.game_tag 	= "mx2"
sdk.pay_url 	= ""
sdk.third_platform = sdk.platform
sdk.log_flag 	= 2 --1: 部落大乱斗 2: 萌新出击
sdk.open_pay 	= true

sdk.http_addr   = "http://g.api.uqee.com"
sdk.pay_url   	= sdk.http_addr .. "/rest/partner/yijie/mengxin/pay"
sdk.http_push_addr = "http://g.uqee.com" -- 外网个推推送
sdk.uqee_stat_addr = "http://www.uqee.com" -- 游奇上报url
sdk.uqee_stat_key = "MUFHzqClVnO8_7J5nsSwdYuGEu34pLlDtm9COByd"

sdk.uqee_http_addr = "http://www.uqee.com"

sdk.HandlerType = {}

sdk.Cmd = "action"
sdk.CmdString = {}
sdk.CmdString.INIT	 	 		= "Init"
sdk.CmdString.LOGIN 	 		= "Login"
sdk.CmdString.LOGOUT 	 		= "Logout"
sdk.CmdString.WXLOGIN 	 		= "WXLogin"
sdk.CmdString.QQLOGIN 	 		= "QQLogin"
sdk.CmdString.WXLOGINRESP 	 	= "WXLoginResp"
sdk.CmdString.QQLOGINRESP 	 	= "QQLoginResp"
sdk.CmdString.SUBMITDATA 		= "SubmitData"
sdk.CmdString.MORE 		 		= "More"
sdk.CmdString.EXIT 		 		= "GameExit"
sdk.CmdString.PAY 		 		= "GameCharge"
sdk.CmdString.UQEEPAY 		 	= "ShowPayUrl"
sdk.CmdString.SWITCHUSER 		= "SwitchAccount"

-- sdk param
sdk.Param = {}
sdk.Param.ErrorCode 			= "error_code"
sdk.Param.UserType 				= "user_type"
sdk.Param.OpenId 				= "open_id"
sdk.Param.ServerSign 			= "server_sign"
sdk.Param.Timestamp 			= "timestamp"
sdk.Param.LoginName 			= "login_name"
sdk.Param.RoleId 				= "role_id"
sdk.Param.RoleName 				= "role_name"
sdk.Param.RoleLevel 			= "role_level"
sdk.Param.CreateTime 			= "create_time"
sdk.Param.LevelMTime 			= "level_m_time"
sdk.Param.ServerUId 			= "server_uid"
sdk.Param.ServerId 				= "server_id"
sdk.Param.ServerName 			= "server_name"
sdk.Param.CorpName 				= "corp_name"
sdk.Param.Diamond 				= "diamond"
sdk.Param.Vip 					= "vip"
sdk.Param.SubmitType 			= "submit_type"

sdk.Param.Sex 					= "role_sex"
sdk.Param.Amount 				= "amount"
sdk.Param.ProductId 			= "product_id"
sdk.Param.ProductName 			= "product_name"
sdk.Param.ProductDesc 			= "product_desc"
sdk.Param.ExPercent 			= "exchange_percent"
sdk.Param.PayNum				= "pay_num"
sdk.Param.PayUrl				= "pay_url"
sdk.Param.Url 					= "url"

uq.sdk = sdk

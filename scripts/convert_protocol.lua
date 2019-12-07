require("utils")
require("cfg")
protocol_const = {}
protocol_map = {}
local root = PROJECT_PATH .. "protocol/"

local invaildFlag = {
	["void"]=true,
	["size_t"]=true,
	["typedef"]=true,
	["+"]=true,
	["sizeof"]=true,
}

local structFieldMap = {
	Packet_C2S_Login = {
		ticket="String"
	},
	Packet_C2S_ExternalAccountGiftPay = {
		giftTicket = "String"
	},
}
local charStruct = {
	Packet_S2C_TechnologyLoad = {
		techInfo = "TechInfo"
	},

	Packet_S2C_ChatMsg = {
		content = "ChatContent"
	},

	Packet_C2S_ChatMsg = {
		content = "ChatContent"
	},
	Packet_S2C_ChallengeName = {
		challData = "ChallengerInfo"
	},
	Packet_S2C_CupBattleInfo = {
		cupBattleData = "ChallengeBattleInfo"
	}
}
local constCont = [[protocol_const = {}
]]
local enumCont = "protocol_enum = {}\n"
local structCont = [[protocol_struct = {}
protocol_struct.ChatContent = {
    type = { type="Short", },
    contLen = { type="Short", unisgned="U"},
    cont = { type="String", length=-1 },
    fields = {"type","contLen","cont"}
}
protocol_struct.TechInfo = {
    ident = { type="Short", unisgned="U" },
    level = { type="Short", unisgned="U"},
    fields = {"ident","level"}
}
]]
--修复 使用int做为string长度
local fixedString = {
	Packet_S2C_CreateCrops = {["boardContent"]=true, ["declareContent"] = true}
}
--修复协议名称与结构体中定义的名称不一致
--[Struct转换后的协义名]=.h文件定义的协义名
local protocolMap = {
	["S_2_C_DRAW_MONTHLY_REWARD"] = "S_2_C_DRAW_MONTHLY_REWARD",
	["C_2_S_WORLD_CITY_BUY_PREPARATION_ARMY_STATUS"] = "C_2_S_WORLD_CITY_BUY_RESERVE_ARMY_STATUS",
	["C_2_S_READ_MAIL"] = "C_2_S_READL_MAIL",
	["C_2_S_ACCOUNT_CANCEL_F_C_M"] = "C_2_S_ACCONT_CANCEL_FCM",
	["C_2_S_ACCOUNT_NEW_BIE"] = "C_2_S_ACCOUNT_NEWBIE",
	["C_2_S_AREA_GET_MAX_SEQ_NO"] = "C_2_S_AREA_GETMAXSEQNO",
	["C_2_S_AREA_MOVE_CITY"] = "C_2_S_AREA_MOVECITY",
	["C_2_S_CITY_INFOS"] = "C_2_S_CITY_GETINFOS",
	["C_2_S_CITY_INFO"] = "C_2_S_CITY_GETINFO",
	["C_2_S_CITY_BUILD_TIME"] = "C_2_S_CITY_GETBUILDTIME",
	["C_2_S_CITY_LVL_UP"] = "C_2_S_CITY_LVLUP",
	["C_2_S_DEL_ALL_MAIL"] = "C_2_S_DEL_ALLMAIL",
	["C_2_S_ADD_WARE_HOUSE_NUM"] = "C_2_S_ADD_WAREHOUSE_NUM",
	["C_2_S_SALE_EQUIPMENT_FROM_WARE_HOUSE"] = "C_2_S_SALE_EQUIPMENT_FROM_WAREHOUSE",
	["C_2_S_STORE_REWARD"] = "C_2_S_RECEIVE_STORE_REWARD",
	["C_2_S_LOAD_WARE_HOUSE_NUM"] = "C_2_S_LOAD_WAREHOUSE_NUM",
	["C_2_S_LOAD_ALL_CROPS_MEMBER_ID"] = "C_2_S_LOAD_CROPS_MEMBER_ID",
	["C_2_S_LOAD_ALL_CROPS_APPLY_MEMBER_ID"] = "C_2_S_LOAD_CROPS_APPLY_MEMBER_ID",
	["C_2_S_LOAD_OFFICIAL_POSITION"] = "C_2_S_LOAD_OFFICIALPOSITION",
	["C_2_S_BUY_ILLEGAL_MARKET_FOOD"] = "C_2_S_BUY_ILLEGALMARK_FOOD",
	["C_2_S_DELETE_C_D_TIME"] = "C_2_S_DELETE_CD_TIME",
	["C_2_S_DRAW_ACHIEVEMENT_REWARD"] = "C_2_S_DRAW_ACHIEVE_REWARD",
	["C_2_S_PARTOL_NPC_REWARD"] = "C_2_S_PATROL_NPC_REWARD",
	["C_2_S_SHOW_MUTI_NPC_BATTLE"] = "C_2_S_MUTI_NPC_BATTLE_SHOW",
	["C_2_S_CLOSE_MUTI_NPC_BATTLE"] = "C_2_S_MUTI_NPC__BATTLE_CLOSE",
	["C_2_S_CREATE_NPC_MUTI_BATTLE"] = "C_2_S_MUTI_NPC_BATTLE_CREATE",
	["C_2_S_JION_MUTI_NPC_BATTLE"] = "C_2_S_MUTI_NPC_BATTLE_JION",
	["C_2_S_CHANGE_MUTI_NPC_BATTLE"] = "C_2_S_MUTI_NPC_BATTLE_ORER_CHANGE",
	["C_2_S_KICK_MUTI_NPC_BATTLE_PLAYER"] = "C_2_S_MUTI_NPC_BATTLE_PLAYER_KICK",
	["C_2_S_HUNTING_ANIMAL_GET_AWAY"] = "C_2_S_HUNTING_ANIMAL_GETAWAY",
}
local structMap = "protocol_map = {}\n"

--动态长度协议修复 
local lenFixed = ",Packet_S2C_TowerNpcGuide,Packet_S2C_ActivityPayRewardAppStoreInfo,Packet_S2C_GeneralSchoolProjectInfo,Packet_S2C_MedalInfo,Formation_Info,Packet_S2C_PlayJarRecord,Packet_S2C_PatrolReward,Packet_S2C_MailListIds,Packet_S2C_PatrolNPCInfo,Packet_S2C_PeerLocalServerId,Packet_S2C_FilterWordList,Packet_S2C_FilterWordDelete,Packet_S2C_BosomFriendNpcInfo,Packet_S2C_EliteCardsInfo,Packet_S2C_EliteAttackNum,"
function formatLine( line )
	line = string.trim(line)
	line = string.gsub(line, "[%s]+", " ")

	if #line>0 then					
		local firstChar = string.sub(line, 1)
		if firstChar~="#" and firstChar~="/" then
			return line
		end
	end
	return ""
end
function getBody( start, lines ) 
	local body = {}
	local flag = -1
	local skip = 0
	local ignore = 0
	local include = false
	for k=start, #lines do
		skip = skip + 1
		local line = formatLine(lines[k])

		if #line>0 then
			local begins = string.split(line, "{")
			local ends = string.split(line, "}")
			local tmp = ""
			if k>start then
				tmp = line
			end
			local expr = string.split( begins[1], " ")

			if flag>0 and (expr[1] == "struct" or expr[1]=="enum") then
				include = true
			end
			if #begins>1 then
				if flag==-1 then
					flag = 1
				else
					flag = flag + 1
					ignore = ignore + 1
				end
				--tmp = begins[#begins]
			end
			if #ends>1 then
				flag = flag - 1
				ignore = ignore - 1 
				if include then
					tmp = line
				elseif #begins==1 then
					tmp = ends[1]
				else tmp = ""
				end
				
			end
			if #tmp>0 and (ignore<=0 or include==true) then
				if not include or (#begins==1 or expr[1] == "struct" or expr[1]=="enum" ) then
					table.insert( body, tmp )
				end
			else
				if string.find(line, "type[%s]*=[%s]*S_2_")~=nil or string.find(line, "type[%s]*=[%s]*C_2_S")~=nil then
					tmp = string.gsub(line, "type[%s]*=[%s]*", "//")
					table.insert( body, tmp )					
				end
			end
			if #ends>1 then			
				include = false
			end
			if flag==0 then
				break;
			end
		end
	end
	return body, skip
end

function enumToConst(body, obj) 
	local val = 0
	for i=1, #body do
		local line = string.split(body[i], ",")[1]
		line = string.split(line, "//")[1]
		local expr = string.split(line, "=")
		if #expr>1 then
			valStr = tonumber(expr[2])
			if not valStr then
				--非数字
				valStr = expr[2]
			else 
				--数字
				val = valStr
				valStr = nil
			end
		end
		for j,v in ipairs(expr) do 
			if v=="=" and j<#expr then
				val = tonumber(string.split(expr[j+1],"/")[1])
				break
			end
		end

		if valStr then
			obj[ string.trim(expr[1]) ] = loadstring("return " .. string.trim(valStr)) ()
		else
			obj[ string.trim(expr[1]) ] = val
		end
		-- constCont = constCont .. "protocol_const." .. expr[1]  .. " = " .. (valStr or val) .. "\n"
		if not valStr then
			val = val + 1
		end
	end

	return obj
end

function getEnumObj(body) 
	local cont = "{\n"
	local val = 0
	for i=1, #body do
		local line = string.split(body[i], ",")[1]
		line = string.split(line, "//")[1]
		local expr = string.split(line, " ")
		for j,v in ipairs(expr) do 
			if v=="=" and j<#expr then
				val = tonumber(string.split(expr[j+1],"/")[1])
				break
			end
		end
		cont = cont .. "    " .. expr[1]  .. " = " .. val .. ",\n"
		val = val + 1
	end
	cont = cont .. "}\n"

	return cont
end

function getStructObj(body, structName) 	
	local cont = "{\n"
	local skipLine = 0
	local children = {}
	local const = {}
	local protocol = nil

	local fields = ""
	local lastType = ""
	local enumObj = {
		NETWORK_MAX_PACKET_BYTE = -1
	}

	for i=1, #body do	
		if i>=skipLine then	
			local line = string.split(body[i], ";")[1]
			local parts = string.split(line, "//")
			line = parts[1]
			if #parts>1 then
				local tmp = string.trim(parts[2])
				if #tmp>5 then
					local prefix = string.sub(tmp, 1, 5)
					if prefix=="C_2_S" or prefix=="S_2_C" or prefix=="S_2_S" then
						protocol = string.split( tmp, " ")[1]
					end
				end
			end
			local expr = ""
			local t = string.sub(line, #line-1)
			if t=="()" or t=="{}" then
				expr = ""				
			else 
				expr = string.split(line, " ")
			end
			if #expr>1 then
				local unsigned = false
				if expr[1]=="unsigned" then
					unsigned = true
					table.remove(expr, 1)
				end
				if expr[1]=="long" then
					table.remove(expr, 1)
				end
				local fieldType = ""
				local len = nil
				local clazz = nil
				local ignore = false
				local isArray = false
				if #expr>=2 then
					local arr = string.split( expr[2], "%[" )
					if #arr>1 then
						expr[2] = arr[1]
						isArray = true

						if string.find( lenFixed, "," .. structName .. ",")~=nil then
							len = "-1"
						else
							len = string.sub( arr[2], 1, #arr[2]-1 )
							if #len==0 then
								len = "-1"
							elseif not tonumber(len) then
								len = string.split( len, "::")
								local lenName = string.trim(len[#len])

								if enumObj[lenName]~=nil then
									len = enumObj[lenName]
								else
									len = "protocol_const." ..  lenName								
								end
							end
						end
					end
				end
				if invaildFlag[expr[1]] then
					ignore = true
				elseif string.find(line, "sizeof")~=nil then
					ignore = true
				elseif expr[1]=="char" then
					if isArray and lastType=="short" then
						fieldType = "String"
					else
						local fix = fixedString[structName]
						if fix and fix[expr[2]] then
							fieldType = "String"
						else
							fieldType = "Char"
						end
					end
				elseif expr[1]=="std::string" then
					fieldType = "String"
				elseif expr[1]=="short" then
					fieldType = "Short"
				elseif expr[1]=="int" or expr[1]=="Version" then
					fieldType = "Int"
				elseif expr[1]=="double" then
					fieldType = "Double"
				elseif expr[1]=="float" then
					fieldType = "Float"
				elseif expr[1]=="long" then
					fieldType = "LongLong"
				elseif expr[1]=="bool" then
					fieldType = "Char"
				elseif expr[1]=="static" then
					if expr[2]=="size_t" then
					else
						for j,v in ipairs(expr) do 
							if v=="=" and j<#expr then
								const[#const+1] = expr[j-1] .. " = " .. string.split(expr[j+1],";")[1]
								break
							end
						end
					end
					ignore = true
				elseif expr[1]=="struct" then	
					ignore = true			
					local subBody, skip = getBody( i, body )
					skipLine = i + skip
					children[expr[2]] = getStructObj(subBody, expr[2])					
				elseif expr[1]=="enum" then	
					ignore = true			
					local enumBody, skip = getBody( i, body )
					skipLine = i + skip
					enumObj = enumToConst( enumBody, enumObj )
				else
					fieldType = "obj"
					clazz = expr[1]
				end
				lastType = expr[1]

				if not ignore then 
					if not expr[2] then
						fieldType = "Int"
						expr[2] = expr[1]
					end
					local fieldMap = structFieldMap[structName]
					if fieldMap and fieldMap[expr[2]] then
						fieldType = fieldMap[expr[2]]
					end
					if charStruct[structName] and charStruct[structName][expr[2]] then
						len = -1
						fieldType = "obj"
						clazz = charStruct[structName][expr[2]]
					end
					fields = fields .. "\"" .. expr[2] .. "\","

					local define = expr[2] .. " = { type=\"" .. fieldType .. "\", "
					if len then
					 	define = define .. "length=" .. len .. ", "
					end
					if clazz then
					 	define = define  .. "clazz=\"" .. clazz .. "\", "
					end 
					if unsigned then
						define = define  .. "unisgned=\"U\""
					end
					define = define .. "},\n"	

					if structName=="Packet_S2C_CreateCrops" and expr[2]=="cropsName" then
						--大坑，这个注释掉，但写数据时有写
						define = define .. "    cropsId2 = { type=\"Int\", unisgned=\"U\"},\n"	
						fields = fields .. "\"cropsId2\","						
					end

					cont = cont .. "    " .. define
				end	
			end
		end
	end
	cont = cont .. "    fields = {" .. fields .. "}\n}\n"
	if protocol==nil and structName and string.find(structName, "Packet_")~=nil then
		local arr = string.split(structName, "_" )

		if arr[2]=="C2S" then
			protocol = "C_2_S"
		elseif arr[2]=="S2C" then
			protocol = "S_2_C"
		end
		if protocol and arr[3] then					
			local name = arr[3]
			for k=4, #arr do
				name = name .. arr[k]
			end
			for k=1, #name do
				local c = string.sub(name, k, k)

				if string.find(c, "%u")~=nil then
					protocol = protocol .. "_" .. c
				else
					protocol = protocol .. string.upper(c)
				end
			end
		end
	end
	return cont, children, const, protocol
end

for file in lfs.dir(root) do
	if not isDir(root..file) then
		local fileName, fileType = getFileType(root..file)
		if fileType=="h" then
			local cont = loadText(root..file)
			
			local lines = string.split(cont, "[\r\n]+")
			local skipLine = 0
			local ignore = false
			for k=1,#lines do				
				if k>=skipLine then
					local line = formatLine(lines[k])
					if #line>=2 then
						if string.sub(line, 1, 2 )=="/*" then
							ignore = true
						end
						if string.sub(line, #line-1 )=="*/" then
							ignore = false
						end
					end
					if not ignore and #line>0 then						
						line = string.split(line, ";")[1]
						local parts = string.split(line, " ")
						if parts[1]=="const" then
							for m,flag in ipairs(parts) do
								local constName = nil
								if #flag>2 then
									if flag[1]=="=" then
										parts[m] = string.sub(flag, 2)
										table.insert(parts, m, "=" )
										flag = "="
									elseif flag[#flag] == "=" then
										constName = string.sub(flag, 1, #flag-1)
										parts[m] = "="
										flag = "="
									end
								end
								if flag=="=" then
									if m==#parts then
										if k>=#lines then
											break;
										end
										parts[m+1] = string.split( formatLine( lines[k+1] ), ";" )[1]
									end
									if not constName then
										constName = parts[m-1]
									end
									constCont = constCont .. "protocol_const." .. constName .. " = "
									local rightVal = ""
									for n=m+1, #parts do
										if #parts[n]>1 then
											local tmp = string.split(parts[n], "%+")[1]
											if #tmp>1 and not tonumber(tmp) then
												parts[n] = "protocol_const." .. parts[n]
											end
										end
										rightVal = rightVal .. parts[n] .. " "
									end

									protocol_const[constName] = loadstring("return " .. rightVal)()
									constCont = constCont .. rightVal .. " --" .. protocol_const[constName] .. "\n"
									break;
								end
							end
						elseif parts[1]=="enum" then
							local body, skip = getBody( k, lines )
							skipLine = k + skip
							enumCont = enumCont .. "protocol_enum." .. string.split(parts[2], "{")[1] .. " = " .. getEnumObj(body)
						elseif parts[1]=="struct" then
							local body, skip = getBody( k, lines )
							skipLine = k + skip
							local name = string.split(parts[2], "{")[1]
							name = string.split( name, ":" )[1]

							local structs, children, const, protocol = getStructObj(body, name)

							if protocol then
								if protocolMap[protocol] then
									protocol = protocolMap[protocol]
								end
								structMap = structMap .. "protocol_map[protocol_const." .. protocol ..  "] = protocol_struct." .. name .. "\n"
								protocol_map[name] = protocol

								-- print(structCont, protocol, protocol_const[protocol])
								structCont = structCont .. "--protocol_const." .. protocol .. "=" .. protocol_const[protocol] .. "\n"
							end

							structCont = structCont .. "protocol_struct." .. name .. " = " .. structs
							for j,v in ipairs(const) do								
								constCont = constCont .. "protocol_const." .. v .. "\n"
							end
							for j,v in pairs(children) do
								structCont = structCont .. "protocol_struct." .. j ..  " = " .. v
							end
						end
					end
				end
			end
			print(#lines)
		end
	end
end


saveTo(PROJECT_PATH.."src/app/network/protocol/protocol_const.lua", constCont .. "return protocol_const")
-- saveTo(PROJECT_PATH.."src/app/network/protocol/protocol_enum.lua", enumCont .. "return protocol_enum")
saveTo(PROJECT_PATH.."src/app/network/protocol/protocol_struct.lua", structCont .. "return protocol_struct")
saveTo(PROJECT_PATH.."src/app/network/protocol/protocol_map.lua", structMap .. "return protocol_map")

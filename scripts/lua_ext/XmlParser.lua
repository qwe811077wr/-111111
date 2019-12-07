---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- xml.lua - XML parser for use with the Corona SDK.
--
-- version: 1.2
--
-- CHANGELOG:
--
-- 1.2 - Created new structure for returned table
-- 1.1 - Fixed base directory issue with the loadFile() function.
--
-- NOTE: This is a modified version of Alexander Makeev's Lua-only XML parser
-- found here: http://lua-users.org/wiki/LuaXml
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

local _M = {}

function _M.newParser()

	local XmlParser = {};

	function XmlParser:toXmlString(value)
		value = string.gsub(value, "&", "&amp;"); -- '&' -> "&amp;"
		value = string.gsub(value, "<", "&lt;"); -- '<' -> "&lt;"
		value = string.gsub(value, ">", "&gt;"); -- '>' -> "&gt;"
		value = string.gsub(value, "\"", "&quot;"); -- '"' -> "&quot;"
		value = string.gsub(value, "([^%w%&%;%p%\t% ])", function(c)
			return string.format("&#x%X;", string.byte(c))
		end);
		return value;
	end

	function XmlParser:fromXmlString(value)
		value = string.gsub(value, "&#x([%x]+)%;", function(h)
			return string.char(tonumber(h, 16))
		end);
		value = string.gsub(value, "&#([0-9]+)%;", function(h)
			return string.char(tonumber(h, 10))
		end);
		value = string.gsub(value, "&quot;", "\"");
		value = string.gsub(value, "&apos;", "'");
		value = string.gsub(value, "&gt;", ">");
		value = string.gsub(value, "&lt;", "<");
		value = string.gsub(value, "&amp;", "&");
		return value;
	end

	function XmlParser:parseArgs(node, s)
		string.gsub(s, "([%w_:-]+)=([\"'])(.-)%2", function(w, _, a)
			--print("@@@@@@@@@@@@ " .. tostring(w) .. "=" .. tostring(a))
			node:addProperty(w, self:fromXmlString(a))
		end)
	end

	function XmlParser:parseNode(s)
		local ni, j, label, xarg, empty = string.find(s, "^([%w_:-]+)(.-)(%/?)$")
		local lNode = self:newNode(label)
		self:parseArgs(lNode, xarg)
		return empty, lNode
	end

	function XmlParser:parseXmlText(xmlText)
		local i, j, k = 1, 1, 1
		local nodes = {}
		local top = self:newNode()
		table.insert(nodes, top)
		while true do
			j, k = string.find(xmlText, "<", i)
			if not j then break end

			local text = string.sub(xmlText, i, j - 1);
			if not string.find(text, "^%s*$") then
				local lVal = (top:value() or "") .. self:fromXmlString(text)
				nodes[#nodes]:setValue(lVal)
				i = j
			end

			local x = string.sub(xmlText, k+1, k+1)
			if (x == "?") then
				j, k = string.find(xmlText, "%?>", i)
				j = j + 1
			elseif (x == "!") then
				local cdataStart = string.sub(xmlText, k+2, k+8)
				if (cdataStart == "[CDATA[") then
					local idx = k+9
					j, k = string.find(xmlText, "]]>", i)
					local cdataText = string.sub(xmlText, idx, j-1)
					top:setValue((top:value() or "")..cdataText)
					j = j + 2
				else
					j, k = string.find(xmlText, "-->", i)
					j = j + 2
					--error("should be <![[ but was "..cdataStart)
				end
			elseif (x == "/") then
				i = j + 2
				j, k = string.find(xmlText, ">", i)
				local value = string.sub(xmlText, i, j-1)
				local toclose = table.remove(nodes)

				top = nodes[#nodes]
				if #nodes < 1 then
					error("XmlParser: nothing to close with " .. value)
				end
				if toclose:name() ~= value then
					error("XmlParser: trying to close " .. toclose:name() .. " with " .. value)
				end
				top:addChild(toclose)
			else
				i = j + 1
				j, k = string.find(xmlText, ">", i)
				local name = string.sub(xmlText, i, j-1)
				local empty, lNode = self:parseNode(name)
				if (empty == "/") then
					top:addChild(lNode)
				else
					table.insert(nodes, lNode)
					top = lNode
				end
			end
			i = j + 1
		end
        local text = string.sub(xmlText, i);
        if #nodes > 1 then
            error("XmlParser: unclosed " .. nodes[#nodes]:name())
        end
		return top
	end

	function XmlParser:loadFile(path)
		--local path = cc.FileUtils:getInstance():fullPathForFilename(xmlFilename)
		local hFile, err = io.open(path, "r");

		if hFile and not err then
			local xmlText = hFile:read("*a"); -- read file content
			io.close(hFile);
			return self:parseXmlText(xmlText), nil;
		else
			print(err)
			return nil
		end
	end

	function XmlParser:toXmlStr( node, block )
		block = block or ""
		
		local tmp = block.."<" .. node:name()
		local props = node:properties()
		for k,p in ipairs(props) do
			tmp = tmp .. " " .. p.name .. "=\"" .. p.value .. "\"" 
		end

		local children = node:children()
		if #children>0 then
			tmp = tmp .. ">\n"
			for k,c in ipairs(children) do
				tmp = tmp .. self:toXmlStr(c, block .. "    ")
			end
		else
			block  = ""
			local val = node:value()

			if val and #val>0 then
				tmp = tmp .. ">" .. val
			else
				tmp = tmp .. "/>\n"
				return tmp
			end
		end
		tmp = tmp .. block .."</" .. node:name() .. ">\n"
		return tmp
	end
	function XmlParser:save(xml, path, header)
		local text = ""
		if header~=false then
			text = '<?xml version="1.0" encoding="utf-8"?>\n'
		end

		text = text .. self:toXmlStr( xml:children()[1] )

		local file = io.open(path, "w+t")
		file:write(text)
		file:flush()
		file:close()
	end

	function XmlParser:newNode(name)
		local node = {}
		node.___value = nil
		node.___name = name
		node.___children = {}
		node.___props = {}

		function node:value() return self.___value end
		function node:setValue(val) self.___value = val end
		function node:name() return self.___name end
		function node:setName(name) self.___name = name end
		function node:children() return self.___children end
		function node:numChildren() return #self.___children end
		function node:addChild(child)
			if self[child:name()] ~= nil then
				-- if type(self[child:name()].name) == "function" then
				-- 	local tempTable = {}
				-- 	table.insert(tempTable, self[child:name()])
				-- 	self[child:name()] = tempTable
				-- end
				table.insert(self[child:name()], child)
			else
				self[child:name()] = {child}
			end
			table.insert(self.___children, child)
		end

		function node:properties() return self.___props end
		function node:numProperties() return #self.___props end
		function node:addProperty(name, value)
			local lName = "@" .. name
			if self[lName] ~= nil then
				for k,v in ipairs(self.___props) do
					if v.name==name then
						v.value = value
						break
					end
				end
			else
				table.insert(self.___props, { name = name, value = value })
			end
			self[lName] = value
		end

		return node
	end
	return XmlParser
end

return _M
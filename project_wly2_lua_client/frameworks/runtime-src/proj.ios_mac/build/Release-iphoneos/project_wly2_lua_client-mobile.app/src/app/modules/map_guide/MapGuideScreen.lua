local MapGuideScreen = class("MapGuideScreen", require('app.base.PopupBase'))

MapGuideScreen.RESOURCE_FILENAME = "map_guide/MapGuideScreen.csb"
MapGuideScreen.RESOURCE_BINDING = {
    ["Panel_1"]                         = {["varname"] = "_panel"},
    ["Panel_1/Button_3"]                ={["varname"] = "_btnAll", ["events"] = {{["event"] = "touch",["method"] = "_onBtnAll"}}},
    ["Panel_1/Panel_select"]            ={["varname"] = "_panelSelect"},
    ["Panel_1/Image_bg1"]               ={["varname"] = "_bgImg1"},
    ["Panel_1/Image_bg2"]               ={["varname"] = "_bgImg2"},
    ["Panel_1/label_des"]               ={["varname"] = "_desLabel"},
}

function MapGuideScreen:ctor(name, args)
    args._isStopAction = true
    MapGuideScreen.super.ctor(self, name, args)
    self._curSelectArray = {}
    for k, v in pairs(args.array) do
        self._curSelectArray[k] = v
    end
    self._isAllSelect = true
    self._selectArray = {}
    self._posX, self._posY = self._panelSelect:getPosition()
    self._selectSize = self._panelSelect:getContentSize()
end

function MapGuideScreen:init()
    self:parseView()
    self:centerView()
    self:initUi()
    self:updateDialog()
end

function MapGuideScreen:_onBtnAll(event)
    if event.name ~= "ended" then
        return
    end
    self._isAllSelect = not self._isAllSelect
    for k, v in pairs(self._curSelectArray) do
        self._curSelectArray[k] = self._isAllSelect
    end
    self:updateDialog()
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.MAP_GUIDE_INFO)
    if view then
        view:updateSelectItem(self._curSelectArray)
    end
end

function MapGuideScreen:initUi()
    self._btnAll:setPressedActionEnabled(true)
    local select_array = string.split(StaticData['Illustration'].Info[1].selectAttributeType, ",")
    self._panelSelect:removeSelf()
    local pos_x = self._posX
    local pos_y = self._posY
    local index = 1
    for k, v in pairs(self._curSelectArray) do
        local select = self._panelSelect:clone()
        self._panel:addChild(select)
        select:setPosition(cc.p(pos_x, pos_y))
        if index % 2 == 0 then
            pos_x = self._posX
            pos_y = pos_y - self._selectSize.height
        else
            pos_x = self._posX + self._selectSize.width
        end
        index = index + 1
        select:getChildByName("Image_8"):setTag(tonumber(k))
        select:getChildByName("Image_8"):setTouchEnabled(true)
        select:getChildByName("Image_8"):addClickEventListenerWithSound(function(sender)
            local tag = sender:getTag()
            self._curSelectArray[tag] = not self._curSelectArray[tag]
            self:updateDialog()
            local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.MAP_GUIDE_INFO)
            if view then
                view:updateSelectItem(self._curSelectArray)
            end
        end)
        table.insert(self._selectArray, select)
    end
    local select_num = math.floor((#select_array + 1) / 2 )
    self._bgImg1:setContentSize(cc.size(self._bgImg1:getContentSize().width, self._bgImg1:getContentSize().height + select_num * self._selectSize.height))
    self._bgImg2:setContentSize(cc.size(self._bgImg2:getContentSize().width, self._bgImg2:getContentSize().height + select_num * self._selectSize.height))
    index = 1
    for k, v in ipairs(select_array) do
        local type_xml = StaticData['types'].Effect[1].Type[tonumber(v)]
        local panel = self._selectArray[index]
        panel:setVisible(true)
        panel:getChildByName("label_des"):setString(type_xml.name)
        index = index + 1
    end
end

function MapGuideScreen:updateDialog()
    self:checkSelectState()
    for k, v in ipairs(self._selectArray) do
        local tag = v:getChildByName("Image_8"):getTag()
        v:getChildByName("Image_12"):setVisible(self._curSelectArray[tag])
    end
end

function MapGuideScreen:checkSelectState()
    self._isAllSelect = true
    for k, v in pairs(self._curSelectArray) do
        if not v then
            self._isAllSelect = false
        end
    end
    if self._isAllSelect then
        self._desLabel:setString(StaticData['local_text']['map.guide.des18'])
    else
        self._desLabel:setString(StaticData['local_text']['map.guide.des17'])
    end
end

function MapGuideScreen:dispose()
    MapGuideScreen.super.dispose(self)
end
return MapGuideScreen
local MapGuideAttr = class("MapGuideAttr", require('app.base.PopupBase'))

MapGuideAttr.RESOURCE_FILENAME = "map_guide/MapGuideAttr.csb"
MapGuideAttr.RESOURCE_BINDING = {
    ["Panel_1"]             = {["varname"] = "_panel"},
    ["Panel_1/btn_close"]   ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
}

function MapGuideAttr:ctor(name, args)
    MapGuideAttr.super.ctor(self, name, args)
    self._curattrLabelArray = {}
end

function MapGuideAttr:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
end

function MapGuideAttr:initUi()
    self._btnClose:setPressedActionEnabled(true)
    for i = 1 ,9 ,1 do
        local node = self._panel:getChildByName("Node_" .. i)
        node:setVisible(false)
        table.insert(self._curattrLabelArray, node)
    end
    local data = uq.cache.illustration.illustration_info
    local attr_array = {}
    for k, v in ipairs(data.items) do
        local info = StaticData['Illustration'].Illustration[v.id]
        if info and v.state == 2 then
            local attr_ids = string.split(info.attribute, ";")
            for k2, v2 in ipairs(attr_ids) do
                local attr = string.split(v2, ",")
                if attr_array[tonumber(attr[1])] == nil then
                    attr_array[tonumber(attr[1])] = 0
                end
                attr_array[tonumber(attr[1])] = attr_array[tonumber(attr[1])] + tonumber(attr[2])
            end
        end
    end
    local info_attr = {}
    for k, v in pairs(attr_array) do
        local info = {}
        info.id = tonumber(k)
        info.num = v
        table.insert(info_attr, info)
    end
    table.sort(info_attr, function(a, b)
        return a.id < b.id
    end)
    for k, v in pairs(info_attr) do
        local type_xml = StaticData['types'].Effect[1].Type[v.id]
        self._curattrLabelArray[k]:setVisible(true)
        self._curattrLabelArray[k]:getChildByName("label_des"):setString(string.format(StaticData["local_text"]["map.guide.des"], type_xml.name))
        self._curattrLabelArray[k]:getChildByName("label_num"):setString("+" .. uq.cache.generals:getNumByEffectType(v.id, v.num))
    end
end

function MapGuideAttr:dispose()
    MapGuideAttr.super.dispose(self)
end
return MapGuideAttr
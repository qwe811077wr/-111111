local RankView = class("RankView", require('app.modules.common.BaseViewWithHead'))

RankView.RESOURCE_FILENAME = "rank/RankView.csb"
RankView.RESOURCE_BINDING = {
    ["Button_1"]         = {["varname"] = "_btn1",["events"] = {{["event"] = "touch",["method"] = "onChannelChange"}}},
    ["Button_1_0"]       = {["varname"] = "_btn2",["events"] = {{["event"] = "touch",["method"] = "onChannelChange"}}},
    ["Button_1_1"]       = {["varname"] = "_btn5",["events"] = {{["event"] = "touch",["method"] = "onChannelChange"}}},
    ["Button_1_2"]       = {["varname"] = "_btn6",["events"] = {{["event"] = "touch",["method"] = "onChannelChange"}}},
    ["Panel_1"]          = {["varname"] = "_panelBg"},
    ["node_rank"]        = {["varname"] = "_nodeRank"},
    ["node_crop"]        = {["varname"] = "_nodeCrop"},
    ["image_crop"]       = {["varname"] = "_imgCrop"},
    ["txt_desc_1"]       = {["varname"] = "_txtDesc1"},
    ["txt_desc_2"]       = {["varname"] = "_txtDesc2"},
    ["txt_desc_3"]       = {["varname"] = "_txtDesc3"},
    ["img_select"]       = {["varname"] = "_imgSelect"},
    ["node_left_middle"] = {["varname"] = "_nodeLeftMiddle"},
}

function RankView:init()
    self._rankList = {}
    self._curChannel = uq.config.constant.RANK_TYPE.FIGHT

    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:centerView()
    self:parseView()
    self:setTitle(uq.config.constant.MODULE_ID.RANK)
    self:createList()

    self:refreshChannel()
    self:requestData(self._curChannel)
    self:adaptBgSize()
    self:adaptNode()
end

function RankView:onCreate()
    RankView.super.onCreate(self)

    self._cropInfoEvent = Protocol.S_2_C_LOAD_CROP_RANK_INFO .. tostring(self)
    network:addEventListener(Protocol.S_2_C_LOAD_CROP_RANK_INFO, handler(self, self._onRankInfoEnd), self._cropInfoEvent)

    network:addEventListener(Protocol.S_2_C_LOAD_RANK_INFO, handler(self, self._onRankInfo), '_onRankInfo')
    network:addEventListener(Protocol.S_2_C_LOAD_RANK_BEGIN, handler(self, self._onRankInfoBegin), '_onRankInfoBegin')
    network:addEventListener(Protocol.S_2_C_LOAD_RANK_END, handler(self, self._onRankEnd), '_onRankEnd')

    self:setInfo()
end

function RankView:setInfo()
    self._nodeRank:getChildByName('txt_name'):setString(uq.cache.role.name)

    local res_head = uq.getHeadRes(uq.cache.role.img_id, uq.cache.role.img_type)
    self._nodeRank:getChildByName('panel_head'):getChildByName('img_head'):loadTexture(res_head)

    self._nodeCrop:getChildByName('contry_bg'):loadTexture(uq.cache.role:getCountryBg(uq.cache.role.country_id))
    self._nodeCrop:getChildByName('country_name'):setString(uq.cache.role:getCountryShortName())

    if uq.cache.role.cropsId > 0 then
        self._nodeRank:getChildByName('txt_crop'):setString(uq.cache.role.crop_name)
        self._nodeCrop:getChildByName('crop_name'):setString(uq.cache.role.crop_name)
        local icon_bg, head_icon = uq.cache.crop:getCropIcon()
        self._nodeCrop:getChildByName('crop_head'):setTexture(head_icon)
        self._nodeRank:getChildByName('crop_head'):setTexture(head_icon)

        local my_info = uq.cache.crop:getMyCropInfo()
        self._nodeCrop:getChildByName('leader_name'):setString(my_info.leader_name)
    else
        self._nodeRank:getChildByName('txt_crop'):setString(StaticData['local_text']['label.none'])
        self._nodeCrop:getChildByName('leader_name'):setString(StaticData['local_text']['label.none'])
        self._nodeCrop:getChildByName('crop_name'):setString(StaticData['local_text']['label.none'])
    end
end

function RankView:onExit()
    network:removeEventListenerByTag(self._cropInfoEvent)
    network:removeEventListenerByTag('_onRankInfo')
    network:removeEventListenerByTag('_onRankInfoBegin')
    network:removeEventListenerByTag('_onRankEnd')

    RankView.super:onExit()
end

function RankView:_onRankInfoBegin(msg)
    self._rankList[self._curChannel] = {}
    self._rankList[self._curChannel].self_info = {msg.data.myRank, msg.data.myValue}
end

function RankView:_onRankEnd(msg)
    self:refreshRankList()
end

function RankView:_onRankInfo(msg)
    for k, item in ipairs(msg.data.rankInfo) do
        table.insert(self._rankList[self._curChannel], item)
    end
end

function RankView:refreshRankList()
    if self._curChannel == uq.config.constant.RANK_TYPE.CROP then
        self._panelBg:setContentSize(cc.size(1169, 435))
        self._panelBg:setPosition(cc.p(146, 133))
        self._listView:setViewSize(cc.size(1169, 421))
        self._listView:setPosition(cc.p(0, 7))
    else
        self._panelBg:setContentSize(cc.size(1169, 410))
        self._panelBg:setPosition(cc.p(146, 159))
        self._listView:setViewSize(cc.size(1169, 396))
        self._listView:setPosition(cc.p(0, 7))
    end
    self._listView:reloadData()

    if self._rankList[self._curChannel].self_info[1] == 0 then
        self._nodeRank:getChildByName('txt_rank'):setString(StaticData['local_text']['rank.out'])
        self._nodeCrop:getChildByName('txt_rank'):setString(StaticData['local_text']['rank.out'])
    else
        self._nodeRank:getChildByName('txt_rank'):setString(self._rankList[self._curChannel].self_info[1])
        self._nodeCrop:getChildByName('txt_rank'):setString(self._rankList[self._curChannel].self_info[1])
    end
    self._nodeRank:getChildByName('txt_value'):setString(self._rankList[self._curChannel].self_info[2])
    self._nodeCrop:getChildByName('txt_value'):setString(self._rankList[self._curChannel].self_info[2])
end

function RankView:requestData(channel)
    self._rankList[channel] = {}

    if channel == uq.config.constant.RANK_TYPE.CROP then
        network:sendPacket(Protocol.C_2_S_LOAD_CROP_RANK_INFO, {rank_type = channel})
    else
        local data = {
            rankType = channel,
            pageId = 1
        }
        network:sendPacket(Protocol.C_2_S_LOAD_RANK_INFO, data)
    end
end

function RankView:_onRankInfoEnd(evt)
    local data = evt.data
    self._rankList[data.rank_type] = data.rank_info
    table.sort(self._rankList[data.rank_type], function(item1, item2)
        return item1.value > item2.value
    end)

    self._rankList[data.rank_type].self_info = {data.my_rank, data.my_value}

    self:refreshRankList()
end

function RankView:createList()
    local viewSize = self._panelBg:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelBg:addChild(self._listView)
end

function RankView:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1

    if self._curChannel == uq.config.constant.RANK_TYPE.CROP then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_DETAIL, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        local rank_data = self._rankList[self._curChannel][index]
        local crop_data = {
            id = rank_data.crop_id,
            name = rank_data.crop_name,
            country_id = rank_data.country_id,
            head_id = rank_data.crop_icon,
            leader_name = rank_data.player_name,
            level = rank_data.value
        }
        panel:setData(crop_data, index)
    else
        local data = {
            id = self._rankList[self._curChannel][index].id
        }
        network:sendPacket(Protocol.C_2_S_LOAD_ROLE_INFO_BY_ID, data)
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
end

function RankView:cellSizeForTable(view, idx)
    if self._curChannel == uq.config.constant.RANK_TYPE.CROP then
        return 1169, 65
    else
        return 1169, 115
    end
end

function RankView:numberOfCellsInTableView(view)
    if self._rankList[self._curChannel] then
        return #self._rankList[self._curChannel]
    else
        return 0
    end
end

function RankView:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("rank.RankItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setIndex(index)
    cell_item:setData(self._rankList[self._curChannel][index], self._curChannel)

    local width, height = self:cellSizeForTable(view, idx)
    if self._curChannel == uq.config.constant.RANK_TYPE.CROP then
        cell_item:setPosition(cc.p(width / 2, height / 2))
    else
        cell_item:setPosition(cc.p(width / 2, height / 2 - 25))
    end
    return cell
end

function RankView:onChannelChange(event)
    if event.name == "ended" then
        local index = 1
        for i = 1, 6 do
            if event.target == self['_btn' .. i] then
                index = i
                break
            end
        end
        self._curChannel = index
        self:refreshChannel()
        self:requestData(self._curChannel)
    end
end

function RankView:refreshChannel()
    for i = 1, 6 do
        if self['_btn' .. i] then
            self['_btn' .. i]:setEnabled(true)
        end
    end
    local cur_btn = self['_btn' .. self._curChannel]
    cur_btn:setEnabled(false)

    self._imgSelect:runAction(cc.RotateBy:create(0.15, -180))
    self._imgSelect:setPositionY(cur_btn:getPositionY())

    if self._curChannel == uq.config.constant.RANK_TYPE.CROP then
        self._txtDesc1:setString(StaticData['local_text']['crop.main.title2'])
        self._txtDesc2:setString(StaticData['local_text']['crop.government.des6'])
    else
        self._txtDesc1:setString(StaticData['local_text']['label.player.name'])
        self._txtDesc2:setString(StaticData['local_text']['crop.main.title2'])
    end

    self._nodeRank:setVisible(true)
    self._imgCrop:setVisible(false)
    self._nodeCrop:setVisible(false)
    if self._curChannel == uq.config.constant.RANK_TYPE.LEVEL then
        self._txtDesc3:setString(StaticData['local_text']['label.player.level'])
    elseif self._curChannel == uq.config.constant.RANK_TYPE.FIGHT then
        self._txtDesc3:setString(StaticData['local_text']['label.player.power'])
    elseif self._curChannel == uq.config.constant.RANK_TYPE.GESTE then
        self._txtDesc3:setString(StaticData['local_text']['rank.prestige'])
    elseif self._curChannel == uq.config.constant.RANK_TYPE.CROP then
        self._txtDesc3:setString(StaticData['local_text']['label.player.level'])
        self._nodeRank:setVisible(false)
        self._imgCrop:setVisible(true)
        self._nodeCrop:setVisible(true)
    end
end

return RankView
local SoldierLine = class("SoldierLine", require('app.base.ChildViewBase'))

function SoldierLine:onCreate()
    SoldierLine.super.onCreate(self)
    self:setLocalZOrder(uq.ui.MapScene.ObjectZOrder.LINE)
    self._lineArray = {}
    self:setLocalZOrder(101)
end

function SoldierLine:initLine(cur_pos, dest_pos)
    self._normal = cc.pNormalize(cc.pSub(dest_pos, cur_pos))
    local angle = math.atan2(self._normal.y, self._normal.x) * 180 / math.pi

    self._firstNode = cc.CSLoader:createNode('world/SoldierLine.csb')
    self:addChild(self._firstNode)
    self._firstNode:getChildByName('panel_line'):getChildByName("sprite_line"):setTexture(self._imgPath)
    self._firstNode:setPosition(cur_pos)
    self._lineArray[1] = self._firstNode
    self._firstNode:setRotation(-angle)

    self._lineWidth = self._firstNode:getChildByName('panel_line'):getContentSize().width - 10
    self._lineHeight = self._firstNode:getChildByName('panel_line'):getContentSize().height
    self._lineNum = math.ceil(cc.pGetDistance(cur_pos, dest_pos) / self._lineWidth)

    for i = 2, self._lineNum do
        self._lineArray[i] = cc.CSLoader:createNode('world/SoldierLine.csb')
        self:addChild(self._lineArray[i])
        self._lineArray[i]:getChildByName('panel_line'):getChildByName("sprite_line"):setTexture(self._imgPath)
        local off_x = cur_pos.x + self._normal.x * self._lineWidth * (i - 1)
        local off_y = cur_pos.y + self._normal.y * self._lineWidth * (i - 1)

        self._lineArray[i]:setPosition(cc.p(off_x, off_y))
        self._lineArray[i]:setRotation(-angle)
    end

    local off_width = cc.pGetDistance(cur_pos, dest_pos) % self._lineWidth
    if off_width > 0 then
        self._lineArray[#self._lineArray]:getChildByName('panel_line'):setContentSize(cc.size(off_width, self._lineHeight))
    end
end

function SoldierLine:initData(path, img_path)
    self._imgPath = img_path or "img/world/s03_000661.png"
    for i = 1, #path - 1, 1 do
        self:initLine(path[i], path[i + 1])
    end
end

return SoldierLine
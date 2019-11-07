local GeneralsStarNode = class("GeneralsStarNode", require('app.base.ChildViewBase'))

GeneralsStarNode.RESOURCE_FILENAME = "generals/GeneralStarItem.csb"
GeneralsStarNode.RESOURCE_BINDING = {
    ["Panel_2"]      = {["varname"]="_panel"},
}

function GeneralsStarNode:onCreate()
    GeneralsStarNode.super.onCreate(self)
    self._nodeArray = {}
    for i = 1, 5 do
        local star = self._panel:getChildByName("Node_" .. i):getChildByName("img_star")
        star:setVisible(false)
        table.insert(self._nodeArray, star)
    end
end

function GeneralsStarNode:setData(star_num)
    for i = 1, star_num, 1 do
        self._nodeArray[i]:setVisible(true)
    end
    for i = star_num + 1, 5, 1 do
        self._nodeArray[i]:setVisible(false)
    end
end

return GeneralsStarNode
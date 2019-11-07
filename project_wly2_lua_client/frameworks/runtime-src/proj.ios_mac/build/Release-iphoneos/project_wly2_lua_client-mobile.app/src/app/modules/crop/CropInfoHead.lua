local RankInfoHead = class("RankInfoHead", require('app.base.ChildViewBase'))

RankInfoHead.RESOURCE_FILENAME = "rank/RankInfoHead.csb"
RankInfoHead.RESOURCE_BINDING = {
    ["LTTX03_0002_2"]         = {["varname"] = "_spriteHead"},
}

function RankInfoHead:onCreate()
    RankInfoHead.super.onCreate(self)

end

function RankInfoHead:setData(general_id)
    local xml_data = StaticData['general'][general_id]
    if xml_data then
        self._spriteHead:setTexture('img/common/general_head/' .. xml_data.icon)
    end
end

return RankInfoHead
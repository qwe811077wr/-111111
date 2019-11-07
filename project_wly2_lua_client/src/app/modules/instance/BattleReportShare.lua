local BattleReportShare = class("BattleReportShare", require("app.base.PopupBase"))

BattleReportShare.RESOURCE_FILENAME = "instance/BattleReportShare.csb"

BattleReportShare.RESOURCE_BINDING  = {
    ["Button_1"]              ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onBtnClose"}}},
    ["Button_2"]              ={["varname"] = "_btnShare",["events"] = {{["event"] = "touch",["method"] = "onBtnShare"}}},
    ["CheckBox_1"]            ={["varname"]="_checkbox1",["events"]={{["event"]="touch",["method"]="onCheckBoxChange"}}},
    ["CheckBox_2"]            ={["varname"]="_checkbox2",["events"]={{["event"]="touch",["method"]="onCheckBoxChange"}}},
    ["CheckBox_3"]            ={["varname"]="_checkbox3",["events"]={{["event"]="touch",["method"]="onCheckBoxChange"}}},
}

function BattleReportShare:ctor(name, args)
    BattleReportShare.super.ctor(self, name, args)
    self._curType = 0
    self._report = {}
    self._rewards = {}
end

function BattleReportShare:init()
    self:setLayerColor()
    self:centerView()
end

function BattleReportShare:setReportInfo(report, rewards)
    self._report = report
    self._rewards = rewards
end

function BattleReportShare:onCheckBoxChange(event)
    if event.name ~= "ended" then
        return
    end
    if event.target == self["_checkbox" .. self._curType + 1] then
        return
    end
    for i = 1, 3 do
        local is_show = event.target == self["_checkbox" .. i]
        if is_show then
            self._curType = i - 1
        end
        self["_checkbox" .. i]:setEnabled(is_show == false)
    end
end

function BattleReportShare:onBtnClose(event)
    if event.name == "ended" then
        self:runCloseAction()
    end
end

function BattleReportShare:onBtnShare(event)
    if event.name == "ended" then
        uq.BattleReport:getInstance():shareReport(self._report, uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD + self._curType, 1, self._rewards)
        self:runCloseAction()
    end
end

return BattleReportShare
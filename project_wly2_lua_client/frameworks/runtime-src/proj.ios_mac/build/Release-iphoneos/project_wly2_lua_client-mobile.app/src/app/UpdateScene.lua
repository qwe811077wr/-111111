local UpdateScene = class("UpdateScene", function()
    return display.newScene("UpdateScene")
end)

function UpdateScene:ctor(asset_manager)
    self:enableNodeEvents()
    self._assertManager = asset_manager
    self:initView()
end

function UpdateScene:initView()
    local update_view = cc.CSLoader:createNode("ui/login/UpdateView.csb")
    self._bar = update_view:getChildByName('loadbar')
    self._barLight = update_view:getChildByName('bar_light')
    self._txtTip = update_view:getChildByName('Text_2')
    self._imgBg = update_view:getChildByName('img_bg_adapt')
    self._imgBg:setContentSize(cc.size(display.width, display.height))

    update_view:setAnchorPoint(cc.p(0.5, 0.5))
    update_view:setPosition(cc.p(display.width / 2, display.height / 2))

    self:addChild(update_view)

    self._imgBg:setAnchorPoint(cc.p(0.5, 0.5))
    local scale_x, scale_y = display.width / CC_DESIGN_RESOLUTION.width, display.height / CC_DESIGN_RESOLUTION.height
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_WIDTH" then
        -- self._imgBg:setScale(scale_y)
    else
        self._imgBg:setScale(scale_x)
    end
    local node_pos = self._imgBg:getParent():convertToNodeSpace(cc.p(display.width / 2, display.height / 2))
    self._imgBg:setPosition(node_pos)
    self._txtTip:setString('')

    if not self._assertManager:getLocalManifest():isLoaded() then
        self:updateError()
    else
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(handler(self, self.assertUpdate))))
    end
end

function UpdateScene:assertUpdate()
    local listener = cc.EventListenerAssetsManagerEx:create(self._assertManager, handler(self, self._onUpdataEvent))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
    self._assertManager:update()
end

function UpdateScene:onExit()
    self._assertManager:release()
end

function UpdateScene:setPercent(percent)
    self._bar:setPercent(percent)
    self._barLight:setPositionX(272 + 737 * percent / 100)
end

function UpdateScene:jumpToDownload()
    self._txtTip:setString('')
    self:setPercent(100)
    self:alert('old version, download again', false, function()
        --jump url
        uq.SdkHelper:getInstance():exit()
    end)
end

function UpdateScene:updateError()
    self._txtTip:setString('')
    self:setPercent(100)
    self:alert('update error', false, function()
        --jump url
        uq.SdkHelper:getInstance():exit()
    end)
end

function UpdateScene:updateSuccess()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        require("app.MyApp"):run()
    end)))
end

function UpdateScene:_onUpdataEvent(event)
    local eventCode = event:getEventCode()
    print('UpdateScene:_onUpdataEvent', eventCode)
    if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
        if self._txtTip then
            self._txtTip:setString('no version file')
        end
        self:alert('no version file')
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND then
        local assert_id = event:getAssetId()
        self._assertManager:setWaitToUpDate(false)
        local old_version = self._assertManager:getLocalManifest():getVersion()
        local new_verson = self._assertManager:getRemoteManifest():getVersion()
        --进行版本比对
        local big_old_version = string.split(old_version, '-')[1]
        local big_new_version = string.split(new_verson, '-')[1]
        print('big_old_version', big_old_version, big_new_version)
        if big_old_version ~= big_new_version then
            self:jumpToDownload()
        else
            self._assertManager:setWaitToUpDate(true)
            self._assertManager:downloadManifest()
        end
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
        local assert_id = event:getAssetId()
        local title = ''
        if assert_id == '@version' then
            title = 'version.file'
        else
            title = 'project.file'
        end
        print('assert_id', assert_id)
        local message = event:getMessage()
        local percent = event:getPercent()
        local file_percent = event:getPercentByFile()
        local speed = self._assertManager:speed()
        local total = self._assertManager:totalDownloadNum()
        local cur = self._assertManager:totalDownloadedNum()

        if self._txtTip then
            if total > 0 then
                local str_info = string.format('progress: %d/%d, speed: %dkb/s', cur, total, speed / 1024)
                self._txtTip:setString(str_info)
            else
                self._txtTip:setString('downloading...' .. title)
            end
        end
        self:setPercent(percent)
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DECOMPRESS or
           eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then
        self._txtTip:setString('update faild')
        self:alert('update faild')
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.DECOMPRESS_PROGRESSION then
        local file_percent = event:getPercentByFile()
        self._txtTip:setString('decompressing...')
        self:setPercent(file_percent)
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or
           eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
        self:updateError()
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then
        self:setPercent(100)
        self._txtTip:setString('already updated')
        self:updateSuccess()
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
        self:setPercent(100)
        self._txtTip:setString('update success')
        self:updateSuccess()
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
        self:updateError()
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED then
    else
        self:updateError()
    end
end

function UpdateScene:alert(msg, show_cancel, ok_handler)
    local confirm = cc.CSLoader:createNode("ui/common/ConfirmNoSelect.csb")
    self:addChild(confirm)
    confirm:setPosition(cc.p(display.width / 2, display.height / 2))

    local label = ccui.Text:create()
    label:setFontSize(24)
    label:setFontName("font/hwkt.ttf")
    label:setString(msg)
    local panel = confirm:getChildByName('Panel_1')
    label:setPosition(cc.p(panel:getContentSize().width / 2, panel:getContentSize().height / 2))
    panel:addChild(label)

    local btn_ok = confirm:getChildByName("Button_2_0")
    btn_ok:setPressedActionEnabled(true)
    btn_ok:addClickEventListener(function(sender)
        if ok_handler then
            ok_handler()
        end
    end)

    local btn_cancel = confirm:getChildByName('Button_2')
    btn_cancel:setPressedActionEnabled(true)
    btn_cancel:addClickEventListener(function(sender)
        confirm:removeFromParent()
    end)

    if not show_cancel then
        btn_cancel:setVisible(false)
        btn_ok:setPosition(cc.p(0, -99))
    end

    local btn_ok = confirm:getChildByName("Button_1")
    btn_ok:setVisible(false)
end

return UpdateScene
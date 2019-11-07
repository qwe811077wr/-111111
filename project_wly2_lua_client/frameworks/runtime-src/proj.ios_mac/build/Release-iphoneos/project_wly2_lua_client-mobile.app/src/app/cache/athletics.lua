local athletics = class("athletics")

function athletics:ctor()
    self.athletics_info = nil
    self.store_info = nil
    network:addEventListener(Protocol.S_2_C_ENTER_ATHLETICS, handler(self, self._athleticsEnter))
    network:addEventListener(Protocol.S_2_C_ATHLETICS_STORE_INFO_LOAD, handler(self, self._athleticsStoreInfoLoad))
    network:addEventListener(Protocol.S_2_C_ATHLETICS_DRAW_RANK_REWARD, handler(self, self._athleticsDrawRankReward))
    network:addEventListener(Protocol.S_2_C_ATHLETICS_EXCHANGE_ITEM, handler(self, self._athleticsExchangeItem))
    network:addEventListener(Protocol.S_2_C_ATHLETICS_REFRESH_STORE, handler(self, self._athleticsRefreshStore))
end

function athletics:_athleticsRefreshStore(evt)
    uq.log("_athleticsRefreshStore  ",evt.data)
    if evt.data.ret == 0 then
        uq.fadeInfo(StaticData["local_text"]["ancient.city.shop.refresh.success"])
        self.store_info.refresh_num = self.store_info.refresh_num + 1
        network:sendPacket(Protocol.C_2_S_ATHLETICS_STORE_INFO_LOAD, {})
    end
end

function athletics:_athleticsEnter(evt)
    --uq.log("_athleticsEnter  ",evt.data)
    self.athletics_info = evt.data
end

function athletics:_athleticsDrawRankReward(evt)
    uq.log("_athleticsDrawRankReward  ",evt.data)
    for k,v in pairs(self.store_info.rank_rwds) do
        if v.id == evt.data.id then
            v.num = v.num - evt.data.num
            break
        end
    end
    services:dispatchEvent({name = "onAthleticsDrawRankReward",data = evt.data})

    local xml_data = StaticData['arena_store']['ArenaReward'][evt.data.id]
    uq.cache.ancient_city:showReward(xml_data, evt.data.num)
end

function athletics:_athleticsExchangeItem(evt)
    uq.log('_athleticsExchangeItem-----', evt.data)
    for k,v in pairs(self.store_info.items) do
        if v.id == evt.data.id then
            v.num = v.num - evt.data.num
            break
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ATHLETICS_EXCHANGEITEM,data = evt.data})

    local xml_data = StaticData['arena_store']['ArenaStore'][evt.data.id]
    uq.cache.ancient_city:showReward(xml_data, evt.data.num)
end

function athletics:_athleticsStoreInfoLoad(evt)
    uq.log("_athleticsStoreInfoLoad  ",evt.data)
    self.store_info = evt.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ATHLETICS_STORE_INFO_LOAD})
end

return athletics
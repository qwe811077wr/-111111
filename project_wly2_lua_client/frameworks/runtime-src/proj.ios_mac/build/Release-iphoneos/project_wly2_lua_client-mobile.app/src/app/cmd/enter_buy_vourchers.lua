local cmd = {}

function cmd.run()
    local xml_data = StaticData['item_appoint'].BuyCard[1]
    local info = {
        item_info = xml_data.buyOneWhat,
        coin_info = xml_data.buyOneCard,
        discount_info = xml_data.buyTenCard,
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_BOUGHT_VOUCHERS, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = info})
end

return cmd
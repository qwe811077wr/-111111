local MapImage = class("MapImage", require('app.base.ChildViewBase'))

function MapImage:onCreate()
    MapImage.super.onCreate(self)

    self._initScale = uq.config.constant.MAP_IMAGE_SCALE
    self._screenScale = self._initScale
    self._screenSize = cc.size(display.width * self._screenScale, display.height * self._screenScale)
    self._imageInfo = {}
    self._imageCollect = {}
    self._textureInfo = {}

    self._retainTime = 15
    self._timerFlag = 'timer_flag' .. tostring(self)
    uq.TimerProxy:addTimer(self._timerFlag, handler(self, self.timer), 3, -1)
    --uq.log('self:convertToNodeSpace(display.center)', self:convertToNodeSpace(display.center))
end

function MapImage:onExit()
    uq.TimerProxy:removeTimer(self._timerFlag)
    MapImage.super.onExit(self)
end

function MapImage:timer()
    for index, img in pairs(self._imageCollect) do
        if os.time() - img.retain_time >= self._retainTime then
            local index_x = (img.block_index - 1) % self._blockWidth
            local index_y = math.floor((img.block_index - 1) / self._blockWidth)
            img:removeSelf()
            table.remove(self._imageCollect, index)

            local image_path = string.format('map/%s/%d_%d.png', self._imagePath, index_y, index_x)
            display.removeImage(image_path)
        end
    end

    for index, time in ipairs(self._textureInfo) do
        if time and time > 0 then
            if os.time() - time >= self._retainTime then
                local index_x = (index - 1) % self._blockWidth
                local index_y = math.floor((index - 1) / self._blockWidth)
                local image_path = string.format('map/%s/%d_%d.png', self._imagePath, index_y, index_x)
                display.removeImage(image_path)
                self._textureInfo[index] = nil
            end
        end
    end
end

function MapImage:setData(map_id, map_scale)
    local map_config = StaticData['map_config'][map_id]
    if not map_config then
        return
    end
    self._blockSize = map_config.blocksize
    self._screenScale = self._initScale / map_scale
    self._screenSize = cc.size(display.width * self._screenScale, display.height * self._screenScale)

    local size_info = string.split(map_config.value, ',')
    self._blockWidth = tonumber(size_info[2])
    self._blockHeight = tonumber(size_info[1])
    self._imageWidth = map_config.x
    self._imageHeight = map_config.y
    self._imagePath = map_config.path
    self._totalNum = self._blockWidth * self._blockHeight

    local x, y = self:getParent():getPosition()
    local center_pos = cc.p(-x / map_scale, -y / map_scale) --初始化中心点
    self:updateInfo(center_pos)
    --self:drawTest(center_pos)
end

function MapImage:drawTest(center_pos)
    self._drawMeshNode = cc.DrawNode:create()
    self:addChild(self._drawMeshNode, 100)
    self._drawMeshNode:setLineWidth(2)

    for i = 1, self._blockHeight do
        for j = 1, self._blockWidth do
            local x = (j - 1) * self._blockSize - self._imageWidth / 2
            local y = self._imageHeight - i * self._blockSize - self._imageHeight / 2

            local label = ccui.Text:create()
            label:setString((i - 1) * self._blockWidth + j)
            label:setFontSize(26)
            label:setFontName("font/hwkt.ttf")
            label:setTextColor(display.COLOR_BLUE)
            label:setPosition(cc.p(x + self._blockSize / 2, y + self._blockSize / 2))
            self:addChild(label, 101)
            self._drawMeshNode:drawRect(cc.p(x, y), cc.p(x + self._blockSize, y + self._blockSize), cc.c4b(0, 1.0, 0, 1.0))
        end
    end

    self._drawRectNode = cc.DrawNode:create()
    self:addChild(self._drawRectNode, 102)
    self._drawRectNode:setLineWidth(2)

    local screen_rect = cc.rect(center_pos.x - display.width / 2, center_pos.y - display.height / 2, display.width, display.height)
    self._drawRectNode:drawRect(cc.p(screen_rect.x + 10, screen_rect.y + 10), cc.p(screen_rect.x + screen_rect.width - 10, screen_rect.y + screen_rect.height - 10), cc.c4b(1.0, 0, 0, 1.0))
    self._drawRectNode:setPosition(center_pos)
end

function MapImage:moveMap(pt)
    local center_pos = self:convertToNodeSpace(display.center)
    self:updateInfo(center_pos)

    if self._drawRectNode then
        self._drawRectNode:setPosition(center_pos)
    end
end

function MapImage:setBlockImage(index)
    local index_x = (index - 1) % self._blockWidth
    local x = index_x * self._blockSize
    x = x - self._imageWidth / 2

    local index_y = math.floor((index - 1) / self._blockWidth)
    local y = self._imageHeight - (index_y + 1) * self._blockSize
    if y < 0 then
        y = 0
    end
    y = y - self._imageHeight / 2

    local img = nil
    if #self._imageCollect > 0 then
        img = self._imageCollect[#self._imageCollect]
        table.remove(self._imageCollect, #self._imageCollect)
    else
        img = ccui.ImageView:create()
        img:setAnchorPoint(0, 0)
        self:addChild(img)
    end
    img:setPosition(cc.p(x, y))
    img.block_index = index
    self._imageInfo[index] = img
    local image_path = string.format('map/%s/%d_%d.png', self._imagePath, index_y, index_x)

    --异步加载
    -- img:setVisible(false)
    -- local function loadEnd(texture)
    --     if self._textureInfo then
    --         local parts = string.split(texture:getPath(), '/')
    --         parts = string.split(parts[#parts], '.')
    --         parts = string.split(parts[1], '_')
    --         local block_index = tonumber(parts[1]) * self._blockWidth + tonumber(parts[2]) + 1
    --         if img.block_index == block_index then
    --             img:setVisible(true)
    --             img:loadTexture(texture:getPath())
    --             self._textureInfo[block_index] = -1
    --         end
    --     end
    -- end
    -- display.loadImage(image_path, loadEnd)

    img:setVisible(true)
    img:loadTexture(image_path)
    self._textureInfo[index] = -1

    return img
end

function MapImage:isAvailableBlock(index, left, right, bottom, top)
    return index >= left and index <= right and index >= bottom and index <= top
end

function MapImage:updateInfo(center_pos)
    local screen_rect = cc.rect(center_pos.x - self._screenSize.width / 2, center_pos.y - self._screenSize.height / 2, self._screenSize.width, self._screenSize.height)
    local block_x_left = math.floor((screen_rect.x + self._imageWidth / 2) / self._blockSize) + 1
    local block_x_right = math.ceil((screen_rect.x + screen_rect.width + self._imageWidth / 2) / self._blockSize)
    local block_y_bottom = math.floor((self._imageHeight / 2 - screen_rect.y - screen_rect.height) / self._blockSize) + 1
    local block_y_top = math.ceil((self._imageHeight / 2 - screen_rect.y) / self._blockSize)

    block_x_left   = block_x_left < 1 and 1 or block_x_left
    block_x_right  = block_x_right > self._blockWidth and self._blockWidth or block_x_right
    block_y_top    = block_y_top > self._blockHeight and self._blockHeight or block_y_top
    block_y_bottom = block_y_bottom < 1 and 1 or block_y_bottom
    --uq.log('block size', block_x_left, block_x_right, block_y_bottom, block_y_top, screen_rect)
    --获取可收集区块
    for index, img in pairs(self._imageInfo) do
        if img then
            local x, y = img:getPosition()
            local size = img:getContentSize()
            local img_rect = cc.rect(x, y, size.width, size.height)
            if not cc.rectIntersectsRect(img_rect, screen_rect) and not self:isAvailableBlock(index, block_x_left, block_x_right, block_y_bottom, block_y_top) then
                --uq.log('rectIntersectsRect', index, img_rect)
                img.retain_time = os.time()
                table.insert(self._imageCollect, img)
                self._imageInfo[index] = nil
                self._textureInfo[index] = os.time()
            end
        end
    end

    local matrix = {}
    for index_y = block_y_bottom, block_y_top do
        local line = {}
        for index_x = block_x_left, block_x_right do
            local index = index_x + (index_y - 1) * self._blockWidth
            table.insert(line, index)
        end
        table.insert(matrix, line)
    end
    local order = self:spiralOrder(matrix)

    for i = #order, 1, -1 do
        if not self._imageInfo[order[i]] then
            self:setBlockImage(order[i])
        end
    end
end

function MapImage:spiralOrder(matrix)
    local res = {}
    local m = #matrix
    local n = #matrix[1]
    local x = 1
    local y = 1

    while m > 0 and n > 0 do
        if m == 1 then
            for i = 1, n do
                table.insert(res, matrix[x][y])
                y = y + 1
            end
            break
        elseif n == 1 then
            for j = 1, m do
                table.insert(res, matrix[x][y])
                x = x + 1
            end
            break
        end

        for i = 1, n - 1 do
            table.insert(res, matrix[x][y])
            y = y + 1
        end

        for i = 1, m - 1 do
            table.insert(res, matrix[x][y])
            x = x + 1
        end

        for i = 1, n - 1 do
            table.insert(res, matrix[x][y])
            y = y - 1
        end

        for i = 1, m - 1 do
            table.insert(res, matrix[x][y])
            x = x - 1
        end

        x = x + 1
        y = y + 1
        m = m - 2
        n = n - 2
    end
    return res
end

function MapImage:getContentSize()
    return cc.size(self._imageWidth, self._imageHeight)
end

function MapImage:getMapRectImage(map_id, center_pos, scale)
    local map_config = StaticData['map_config'][map_id]
    local screen_size = scale / map_config.normal
    local size_info = string.split(map_config.value, ',')
    local block_width = tonumber(size_info[2])
    local block_height = tonumber(size_info[1])
    local image_width = map_config.x
    local image_height = map_config.y
    local block_size = map_config.blocksize
    local screen_size = cc.size(display.width * screen_size, display.height * screen_size)
    local screen_rect = cc.rect(center_pos.x - screen_size.width / 2, center_pos.y - screen_size.height / 2, screen_size.width, screen_size.height)
    local block_x_left = math.floor((screen_rect.x + image_width / 2) / block_size) + 1
    local block_x_right = math.ceil((screen_rect.x + screen_rect.width + image_width / 2) / block_size)
    local block_y_bottom = math.floor((image_height / 2 - screen_rect.y - screen_rect.height) / block_size) + 1
    local block_y_top = math.ceil((image_height / 2 - screen_rect.y) / block_size)

    local left   = block_x_left < 1 and 1 or block_x_left
    local right  = block_x_right > block_width and block_width or block_x_right
    local top    = block_y_top > block_width and block_height or block_y_top
    local bottom = block_y_bottom < 1 and 1 or block_y_bottom
    --uq.log('MapImage:getMapRectImage', left, right, top, bottom)
    local images = {}
    for index_y = bottom, top do
        for index_x = left, right do
            local image_path = string.format('map/%s/%d_%d.png', map_config.path, index_y - 1, index_x - 1)
            table.insert(images, image_path)
        end
    end
    return images
end

function MapImage:scaleCallback(scale)
    self._screenScale = self._initScale / scale
    self._screenSize = cc.size(display.width * self._screenScale, display.height * self._screenScale)
    local center_pos = self:convertToNodeSpace(display.center)
    self:updateInfo(center_pos)
end

return MapImage
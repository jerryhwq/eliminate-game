local BlockSprite = require('BlockSprite')
local MenuScene = require('MenuScene')

local WIN_WIDTH = cc.Director:getInstance():getWinSize().width
local WIN_HEIGHT = cc.Director:getInstance():getWinSize().height
local BLOCK_WIDTH = 64
local BLOCK_HEIGHT = 68

local GameLayer = class('GameLayer', function()
    return cc.Layer:create()
end)

function GameLayer:ctor()

    self.selected = nil
    self.blocks = {}
    for i = 1, 8 do
        self.blocks[i] = {}
    end
    self.canPlay = false

    self:registerScriptHandler(function(event)
        if event == 'enter' then
            self:onEnter()
        end
    end)

end

function GameLayer:createNewBlock(x, y)
    local block = BlockSprite.createRandomBlock()
    block:setPosition(self:getAbsoluteLocation(cc.p(x, y)))
    return block
end

function GameLayer:initLayer()
    -- 添加背景
    local background = ccui.Scale9Sprite:create('background.png')
    background:setPosition(WIN_WIDTH / 2, WIN_HEIGHT / 2)
    background:setContentSize(cc.size(WIN_WIDTH, WIN_HEIGHT))
    self:addChild(background)

    self:initClippingNode()
    self:initBackgroundNode()

    -- 添加返回按钮
    local backMenuItem = cc.MenuItemFont:create('返回')
    backMenuItem:setFontSizeObj(32)
    local function backMenuItemHandler(sender)
        self:backToMenu()
    end
    backMenuItem:registerScriptTapHandler(backMenuItemHandler)

    -- 添加返回按钮菜单
    local backMenu = cc.Menu:create()
    backMenu:setPosition(50, WIN_HEIGHT - 40)
    backMenu:setAnchorPoint(cc.p(0, 1))
    backMenu:addChild(backMenuItem)
    self:addChild(backMenu)
    self:initBlocks()

end

function GameLayer:backToMenu()
    local menuScene = MenuScene:create()
    cc.Director:getInstance():replaceScene(menuScene)
end

function GameLayer:initBlocks()
    for i = 1, 8, 1 do
        for j = 1, 8, 1 do
            while true do
                local block = self:createNewBlock(i, j)
                self.blocks[i][j] = block
                local isOk = true
                if i >= 3 then
                    local tempBlock1 = self.blocks[i - 1][j]
                    local tempBlock2 = self.blocks[i - 2][j]
                    if block:hasSameType(tempBlock1) and block:hasSameType(tempBlock2) then
                        isOk = false
                    end
                end
                if j >= 3 then
                    local tempBlock1 = self.blocks[i][j - 1]
                    local tempBlock2 = self.blocks[i][j - 2]
                    if block:hasSameType(tempBlock1) and block:hasSameType(tempBlock2) then
                        isOk = false
                    end
                end
                if isOk then
                    self.clippingNode:addChild(block)
                    break
                end
            end
        end
    end
end

-- 遮住游戏在游戏区域外的方块
function GameLayer:initClippingNode()
    local clippingLayerNode = cc.Node:create()
    local clippingLayer = cc.LayerColor:create(cc.c3b(0, 0, 0), BLOCK_WIDTH * 8, BLOCK_HEIGHT * 8)
    clippingLayerNode:setAnchorPoint(0, 0)
    clippingLayerNode:setPosition(WIN_WIDTH / 2 - BLOCK_WIDTH * 4, WIN_HEIGHT / 2 - BLOCK_HEIGHT * 4)
    clippingLayerNode:addChild(clippingLayer)

    self.clippingNode = cc.ClippingNode:create(clippingLayerNode)
    self:addChild(self.clippingNode)
end

-- 游戏区域背景
function GameLayer:initBackgroundNode()
    self.backgroundNode = cc.DrawNode:create()
    self.backgroundNode:drawSolidRect(cc.p(0, 0), cc.p(BLOCK_WIDTH * 8, BLOCK_HEIGHT * 8), cc.c4b(0, 0, 0, 0.5))
    self.backgroundNode:setAnchorPoint(0, 0)
    self.backgroundNode:setPosition(WIN_WIDTH / 2 - BLOCK_WIDTH * 4, WIN_HEIGHT / 2 - BLOCK_HEIGHT * 4)
    self.clippingNode:addChild(self.backgroundNode)
end

function GameLayer:onEnter()
    self:initLayer()
    self:initEvent()
    self.canPlay = true
end

function GameLayer:initEvent()
    local touchEventListener = cc.EventListenerTouchOneByOne:create()
    local tempLoc
    local function onTouchBegan(touch)
        tempLoc = self:getRelativeLocation(touch:getLocation())
        return true
    end
    local function onTouchEnded(touch)
        if not self.canPlay then
            return
        end
        local loc = self:getRelativeLocation(touch:getLocation())
        -- 在区域外
        if not (self:hasBlock(tempLoc) and self:hasBlock(loc)) then
            return
        end
        local sprite = self.blocks[tempLoc.x][tempLoc.y]
        if self:isSameBlock(loc, tempLoc) then
            -- 起点和终点相同，认为是点击
            if not self.selected then
                -- 当前没有选中，选中
                self.selected = tempLoc
                sprite:select()
            elseif self:isSameBlock(loc, self.selected) then
                -- 和当前选中方块相同，取消选择
                self.selected = nil
                sprite:deselect()
            elseif self:isNeighborBlock(loc, self.selected) then
                -- 和当前选中方块是相邻方块，交换
                local block = self.blocks[self.selected.x][self.selected.y]
                block:deselect()
                local tempSelect = self.selected
                self.selected = nil
                self:trySwap(loc, tempSelect)
            else
                -- 取消选择之前的方块，并把当前的选中
                local block = self.blocks[self.selected.x][self.selected.y]
                block:deselect()
                self.selected = loc
                block = self.blocks[tempLoc.x][tempLoc.y]
                block:select()
            end
        elseif self:isNeighborBlock(loc, tempLoc) then
            -- 起点和终点不同，且为相邻方块
            if not self.selected then
                -- 如果当前没有选中，则交换，否则忽略
                self:trySwap(loc, tempLoc)
            end
        end
    end
    touchEventListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    touchEventListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(touchEventListener, self)

    local keyboardEventListener = cc.EventListenerKeyboard:create()

    local function onKeyPressed(keyCode)
        if keyCode == cc.KeyCode.KEY_BACK then
            self:backToMenu()
        end
    end

    keyboardEventListener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    eventDispatcher:addEventListenerWithSceneGraphPriority(keyboardEventListener, self)

end

function GameLayer:trySwap(p1, p2)
    -- 禁用触摸事件，交换成功/失败后需要还原
    self.canPlay = false
    local function callback()
        -- 假设为交换成功后坐标与方块的对应
        local block2 = self.blocks[p1.x][p1.y]
        local block1 = self.blocks[p2.x][p2.y]
        if block1.type == block2.type then
            -- 类型相同，交换失败，还原
            self:swap(p1, p2, function()
                self.canPlay = true
            end)
            return
        end
        -- 计算交换后是否可消除
        local r1 = self:tryClearBlock(p1)
        local r2 = self:tryClearBlock(p2)
        -- 均不可交换，换回
        if not (r1 or r2) then
            self:swap(p1, p2, function()
                self.canPlay = true
            end)
            return
        end
        audio.playSound('clear.mp3')
        self:fallAllColumns()
    end
    self:swap(p1, p2, callback)
end

-- 落下并添加新方块，同时负责清除
function GameLayer:fallAllColumns()
    for i = 1, 8, 1 do
        self:fallOneColumn(i)
    end
    local canContinue = true
    local function clear()
        for i = 1, 8 do
            for j = 1, 8 do
                local r = self:tryClearBlock(cc.p(i, j))
                if r then
                    canContinue = false
                end
            end
            if canContinue then
                self.canPlay = true
            else
                audio.playSound('clear.mp3')
                self:fallAllColumns()
            end
        end
    end
    performWithDelay(self, clear, 0.8)
end

function GameLayer:fallOneColumn(i)
    local newSpriteNum = 0
    -- 遍历一列
    for j = 1, 8, 1 do
        local sprite = self.blocks[i][j]
        -- 如果不存在就从上方下落
        if not sprite then
            local time
            local k = j + 1
            while k <= 8 do
                sprite = self.blocks[i][k]
                -- 如果上方有可用方块，就从上方下落
                if sprite then
                    time = k - j
                    self.blocks[i][k] = nil
                    break
                end
                k = k + 1
            end
            -- 如果上方没有可用方块，就加载新的
            if k == 9 then
                sprite = BlockSprite.createRandomBlock()
                sprite:setPosition(self:getAbsoluteLocation(cc.p(i, newSpriteNum + 9)))
                newSpriteNum = newSpriteNum + 1
                time = newSpriteNum + 8 - j
                self.clippingNode:addChild(sprite)
            end
            self.blocks[i][j] = sprite
            local move = cc.MoveTo:create(0.1 * time, self:getAbsoluteLocation(cc.p(i, j)))
            sprite:runAction(move)
        end
    end
end

-- 检测
function GameLayer:tryClearBlock(p)
    local sprite = self.blocks[p.x][p.y]
    if not sprite then
        return false
    end
    local result = false
    local sameTypeUpBlock = p.y
    local sameTypeDownBlock = p.y
    -- 上下、左右
    for i = p.y + 1, 8, 1 do
        local tempSprite = self.blocks[p.x][i]
        if sprite:hasSameType(tempSprite) then
            sameTypeUpBlock = i
        else
            break
        end
    end
    for i = p.y - 1, 1, -1 do
        local tempSprite = self.blocks[p.x][i]
        if sprite:hasSameType(tempSprite) then
            sameTypeDownBlock = i
        else
            break
        end
    end
    local count = sameTypeUpBlock - sameTypeDownBlock
    if count >= 2 then
        for i = sameTypeDownBlock, p.y - 1 do
            self:removeOneBlock(cc.p(p.x, i))
        end
        for i = p.y + 1, sameTypeUpBlock, 1 do
            self:removeOneBlock(cc.p(p.x, i))
        end
        if count >= 3 then
            self:replaceSpecialBlock(p, 'line')
        else
            self:removeOneBlock(p)
        end
        result = true
    end
    if result then
        return true
    end
    local sameTypeLeftBlock = p.x
    local sameTypeRightBlock = p.x
    for i = p.x - 1, 1, -1 do
        local tempSprite = self.blocks[i][p.y]
        if sprite:hasSameType(tempSprite) then
            sameTypeLeftBlock = i
        else
            break
        end
    end
    for i = p.x + 1, 8, 1 do
        local tempSprite = self.blocks[i][p.y]
        if sprite:hasSameType(tempSprite) then
            sameTypeRightBlock = i
        else
            break
        end
    end
    count = sameTypeRightBlock - sameTypeLeftBlock
    if count >= 2 then
        for i = sameTypeLeftBlock, p.x - 1, 1 do
            self:removeOneBlock(cc.p(i, p.y))
        end
        for i = p.x + 1, sameTypeRightBlock, 1 do
            self:removeOneBlock(cc.p(i, p.y))
        end
        if count >= 3 then
            self:replaceSpecialBlock(p, 'column')
        else
            self:removeOneBlock(p)
        end
        result = true
    end
    return result
end

function GameLayer:removeOneBlock(p)
    local tempSprite = self.blocks[p.x][p.y]
    tempSprite:removeSelf()
    self.blocks[p.x][p.y] = nil
end

function GameLayer:replaceSpecialBlock(p, state)
    local sprite = self.blocks[p.x][p.y]
    local spriteType = sprite.type
    local x, y = sprite:getPosition()
    self:removeOneBlock(p)
    local newSprite = BlockSprite:create(spriteType, state)
    newSprite:setPosition(x, y)
    self.clippingNode:addChild(newSprite)
    self.blocks[p.x][p.y] = newSprite
end

-- 交换两个方块
function GameLayer:swap(p1, p2, callback)
    local block1 = self.blocks[p1.x][p1.y]
    local block2 = self.blocks[p2.x][p2.y]
    self.blocks[p1.x][p1.y] = block2
    self.blocks[p2.x][p2.y] = block1
    block1:moveTo(self:getAbsoluteLocation(p2))
    block2:moveTo(self:getAbsoluteLocation(p1), callback)
end

-- 判断对应位置是否有方块
function GameLayer:hasBlock(p)
    return self.blocks[p.x] and self.blocks[p.y]
end

-- 判断方块是否是相邻方块
function GameLayer:isNeighborBlock(p1, p2)
    if p1.x == p2.x then
        return p1.y == p2.y - 1 or p1.y == p2.y + 1
    elseif p1.y == p2.y then
        return p1.x == p2.x - 1 or p1.x == p2.x + 1
    end
    return false
end

-- 判断方块是否是同一方块
function GameLayer:isSameBlock(p1, p2)
    return p1.x == p2.x and p1.y == p2.y
end

-- 绝对坐标转相对坐标
function GameLayer:getRelativeLocation(location)
    local loc = self.backgroundNode:convertToNodeSpaceAR(location)
    local x = math.ceil(loc.x / BLOCK_WIDTH)
    local y = math.ceil(loc.y / BLOCK_HEIGHT)
    return cc.p(x, y)
end

-- 相对坐标转绝对坐标
function GameLayer:getAbsoluteLocation(p)
    return self.backgroundNode:convertToWorldSpaceAR(cc.p((p.x - 1) * BLOCK_WIDTH, (p.y - 1) * BLOCK_HEIGHT))
end

return GameLayer

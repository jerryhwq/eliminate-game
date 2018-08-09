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

    self:registerScriptHandler(function(event)
        if event == 'enter' then
            self:onEnter()
        end
    end)

end

function GameLayer:createNewBlock(x, y)
    local sprite = BlockSprite.createRandomBlock()
    sprite:setPosition(self:getAbsoluteLocation(cc.p(x, y)))
    self.clippingNode:addChild(sprite)
    self.blocks[x][y] = sprite
end

function GameLayer:initLayer()
    -- 添加背景
    local background = ccui.Scale9Sprite:create('background.png')
    background:setPosition(cc.p(WIN_WIDTH / 2, WIN_HEIGHT / 2))
    background:setContentSize(cc.size(WIN_WIDTH, WIN_HEIGHT))
    self:addChild(background)

    self:initClippingNode()
    self:initBackgroundNode()

    -- 添加返回按钮
    local backMenuItem = cc.MenuItemFont:create('返回')
    backMenuItem:setFontSizeObj(32)
    local function backMenuItemHandler(sender)
        local menuScene = MenuScene:create()
        cc.Director:getInstance():replaceScene(menuScene)
    end
    backMenuItem:registerScriptTapHandler(backMenuItemHandler)

    -- 添加返回按钮菜单
    local backMenu = cc.Menu:create()
    backMenu:setPosition(cc.p(50, WIN_HEIGHT - 40))
    backMenu:setAnchorPoint(cc.p(0, 1))
    backMenu:addChild(backMenuItem)
    self:addChild(backMenu)

    -- 初始化方块
    for i = 1, 8 do
        for j = 1, 8 do
            self:createNewBlock(i, j)
        end
    end
end

-- 遮住游戏在游戏区域外的方块
function GameLayer:initClippingNode()
    local clippingLayerNode = cc.Node:create()
    local clippingLayer = cc.LayerColor:create(cc.c3b(0, 0, 0), BLOCK_WIDTH * 8, BLOCK_HEIGHT * 8)
    clippingLayerNode:setAnchorPoint(0, 0)
    clippingLayerNode:setPosition(cc.p(WIN_WIDTH / 2 - BLOCK_WIDTH * 4, WIN_HEIGHT / 2 - BLOCK_HEIGHT * 4))
    clippingLayerNode:addChild(clippingLayer)

    self.clippingNode = cc.ClippingNode:create(clippingLayerNode)
    self:addChild(self.clippingNode)
end

-- 游戏区域背景
function GameLayer:initBackgroundNode()
    self.backgroundNode = cc.DrawNode:create()
    self.backgroundNode:drawSolidRect(cc.p(0, 0), cc.p(BLOCK_WIDTH * 8, BLOCK_HEIGHT * 8), cc.c4b(0, 0, 0, 0.5))
    self.backgroundNode:setAnchorPoint(0, 0)
    self.backgroundNode:setPosition(cc.p(WIN_WIDTH / 2 - BLOCK_WIDTH * 4, WIN_HEIGHT / 2 - BLOCK_HEIGHT * 4))
    self.clippingNode:addChild(self.backgroundNode)
end

function GameLayer:onEnter()
    self:initLayer()
    self:initEvent()
end

function GameLayer:initEvent()
    self.eventListener = cc.EventListenerTouchOneByOne:create()
    local tempLoc
    local function onTouchBegan(touch)
        tempLoc = self:getRelativeLocation(touch:getLocation())
        return true
    end
    local function onTouchEnded(touch)
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
    self.eventListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    self.eventListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.eventListener, self)
end

function GameLayer:trySwap(p1, p2)
    -- 禁用触摸事件，交换成功/失败后需要还原
    self:getEventDispatcher():removeEventListener(self.eventListener)
    local function callback()
        -- 假设为交换成功后坐标与方块的对应
        local block2 = self.blocks[p1.x][p1.y]
        local block1 = self.blocks[p2.x][p2.y]
        if block1.type == block2.type then
            -- 类型相同，交换失败，还原
            self:swap(p1, p2, function()
                self:initEvent()
            end)
            return
        end
        -- 计算交换后是否可消除
        local r1 = self:tryClearBlock(p1)
        local r2 = self:tryClearBlock(p2)
        -- 均不可交换，换回
        if not (r1 and r2) then
            self:swap(p1, p2, function()
                self:initEvent()
            end)
            return
        end
        -- 清除block1相关的方块
        if r1 then
            for i, v in pairs(r1) do
                local sprite = self.blocks[v[1]][v[2]]
                --sprite:removeSelf()
            end
        end
        -- 清除block2相关的方块
        if r2 then
            for i, v in pairs(r2) do
                local sprite = self.blocks[v[1]][v[2]]
                --sprite:removeSelf()
            end
        end
        self:fall()
    end
    self:swap(p1, p2, callback)
end

-- 落下并添加新方块
function GameLayer:fall()
end

-- 检测
function GameLayer:tryClearBlock(p)
    return nil
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

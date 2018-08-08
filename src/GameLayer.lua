local MenuScene = require('MenuScene')
local BlockSprite = require('BlockSprite')

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
        elseif event == 'exit' then
            self:onExit()
        end
    end)

end

function GameLayer:createNewBlock(x, y)
    local sprite = BlockSprite.createRandomBlock()
    sprite:setPosition(self:getAbsoluteLocation(cc.p(x, y)))
    self:addChild(sprite)
    self.blocks[x][y] = sprite
end

function GameLayer:initLayer()
    -- 添加背景
    local background = ccui.Scale9Sprite:create('background.png')
    background:setPosition(cc.p(WIN_WIDTH / 2, WIN_HEIGHT / 2))
    background:setContentSize(cc.size(WIN_WIDTH, WIN_HEIGHT))
    self:addChild(background)

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

    -- 创建背景
    self.backgroundNode = cc.DrawNode:create()
    self.backgroundNode:drawSolidRect(cc.p(0, 0), cc.p(BLOCK_WIDTH * 8, BLOCK_HEIGHT * 8), cc.c4b(0, 0, 0, 0.5))
    self.backgroundNode:setAnchorPoint(0, 0)
    self.backgroundNode:setPosition(cc.p(WIN_WIDTH / 2 - BLOCK_WIDTH * 4, WIN_HEIGHT / 2 - BLOCK_HEIGHT * 4))
    self:addChild(self.backgroundNode)

    --初始化方块
    for i = 1, 8 do
        for j = 1, 8 do
            self:createNewBlock(i, j)
        end
    end
end

function GameLayer:onEnter()
    display.loadSpriteFrames('cat.plist', 'cat.png')
    display.loadSpriteFrames('chicken.plist', 'chicken.png')
    display.loadSpriteFrames('bear.plist', 'bear.png')
    display.loadSpriteFrames('frog.plist', 'frog.png')
    display.loadSpriteFrames('horse.plist', 'horse.png')
    display.loadSpriteFrames('fox.plist', 'fox.png')
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
        local sprite = self.blocks[tempLoc.x][tempLoc.y]
        if not sprite then
            return
        end
        if self:isSameBlock(loc, tempLoc) then
            if not self.selected then
                self.selected = tempLoc
                sprite:select()
            elseif self:isSameBlock(loc, self.selected) then
                self.selected = nil
                sprite:deselect()
            elseif self:isNeighborBlock(loc, self.selected) then
                local block = self.blocks[self.selected.x][self.selected.y]
                block:deselect()
                local tempSelect = self.selected
                self.selected = nil
                self:trySwap(loc, tempSelect)
            else
                local block = self.blocks[self.selected.x][self.selected.y]
                block:deselect()
                self.selected = loc
                block = self.blocks[tempLoc.x][tempLoc.y]
                block:select()
            end
        elseif self:isNeighborBlock(loc, tempLoc) then
            if not self.selected then
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

function GameLayer:swap(p1, p2, callback)
    local block1 = self.blocks[p1.x][p1.y]
    local block2 = self.blocks[p2.x][p2.y]
    self.blocks[p1.x][p1.y] = block2
    self.blocks[p2.x][p2.y] = block1
    callback = callback or function()
    end
    local move = cc.MoveTo:create(0.5, self:getAbsoluteLocation(p1))
    local seq = cc.Sequence:create(move, cc.CallFunc:create(callback))
    block1:runAction(cc.MoveTo:create(0.5, self:getAbsoluteLocation(p2)))
    block2:runAction(seq)
end

function GameLayer:isNeighborBlock(p1, p2)
    if p1.x == p2.x then
        return p1.y == p2.y - 1 or p1.y == p2.y + 1
    elseif p1.y == p2.y then
        return p1.x == p2.x - 1 or p1.x == p2.x + 1
    else
        return false
    end
end

function GameLayer:isSameBlock(p1, p2)
    return p1.x == p2.x and p1.y == p2.y
end

function GameLayer:getRelativeLocation(location)
    local loc = self.backgroundNode:convertToNodeSpaceAR(location)
    local x = math.ceil(loc.x / BLOCK_WIDTH)
    local y = math.ceil(loc.y / BLOCK_HEIGHT)
    return cc.p(x, y)
end

function GameLayer:getAbsoluteLocation(p)
    return self.backgroundNode:convertToWorldSpaceAR(cc.p((p.x - 1) * BLOCK_WIDTH, (p.y - 1) * BLOCK_HEIGHT))
end

function GameLayer:onExit()
    display.removeSpriteFrames('cat.plist')
    display.removeSpriteFrames('chicken.plist')
    display.removeSpriteFrames('bear.plist')
    display.removeSpriteFrames('frog.plist')
    display.removeSpriteFrames('horse.plist')
end

return GameLayer

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
    self:getEventDispatcher():removeEventListener(self.eventListener)
    local block1 = self.blocks[p1.x][p1.y]
    local block2 = self.blocks[p2.x][p2.y]
    self.blocks[p1.x][p1.y] = block2
    self.blocks[p2.x][p2.y] = block1
    local move = cc.MoveTo:create(0.5, self:getAbsoluteLocation(p1))
    local function callback()
        self:initEvent()
    end
    local seq = cc.Sequence:create(move, cc.CallFunc:create(callback))
    block1:runAction(cc.MoveTo:create(0.5, self:getAbsoluteLocation(p2)))
    block2:runAction(seq)
    cclog('try to swap (%d, %d) and (%d, %d)', p1.x, p1.y, p2.x, p2.y)
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

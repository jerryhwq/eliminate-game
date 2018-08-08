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
    sprite:setPosition(self.backgroundNode:convertToWorldSpace(cc.p((x - 1) * BLOCK_WIDTH, (y - 1) * BLOCK_HEIGHT)))
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
            local sprite = self.blocks[i][j]
            sprite:select()
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
    local listener = cc.EventListenerTouchOneByOne:create()
    local function onTouchBegan(touch, event)
        local loc = self.backgroundNode:convertToNodeSpaceAR(touch:getLocation())
        local x = math.ceil(loc.x / BLOCK_WIDTH)
        local y = math.ceil(loc.y / BLOCK_HEIGHT)
        local sprite = self.blocks[x][y]
        if sprite then
            sprite:deselect()
        end
        return true
    end
    local function onTouchEnded(touch, event)
        local loc = self.backgroundNode:convertToNodeSpaceAR(touch:getLocation())
        local x = math.ceil(loc.x / BLOCK_WIDTH)
        local y = math.ceil(loc.y / BLOCK_HEIGHT)
        cclog('(%d, %d)', x, y)
    end
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameLayer:onExit()
    display.removeSpriteFrames('cat.plist')
    display.removeSpriteFrames('chicken.plist')
    display.removeSpriteFrames('bear.plist')
    display.removeSpriteFrames('frog.plist')
    display.removeSpriteFrames('horse.plist')
end

return GameLayer

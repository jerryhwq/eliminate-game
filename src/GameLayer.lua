local MenuScene = require('MenuScene')
local BlockSprite = require('BlockSprite')

local WIN_WIDTH = cc.Director:getInstance():getWinSize().width
local WIN_HEIGHT = cc.Director:getInstance():getWinSize().height

local GameLayer = class('GameLayer', function()
    return cc.Layer:create()
end)

function GameLayer:ctor()

    self.selected = nil
    self.data = {}
    for i = 1, 8 do
        self.data[i] = {}
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
    sprite:setPosition(self.backgroundNode:convertToWorldSpace(cc.p((x - 1) * 64, (y - 1) * 68)))
    self:addChild(sprite)
    self.data[x][y] = sprite
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
    self.backgroundNode:drawSolidRect(cc.p(0, 0), cc.p(64 * 8, 68 * 8), cc.c4b(0, 0, 0, 0.5))
    self.backgroundNode:setAnchorPoint(0, 0)
    self.backgroundNode:setPosition(cc.p(WIN_WIDTH / 2 - 64 * 4, WIN_HEIGHT / 2 - 68 * 4))
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
end

function GameLayer:onExit()
    display.removeSpriteFrames('cat.plist')
    display.removeSpriteFrames('chicken.plist')
    display.removeSpriteFrames('bear.plist')
    display.removeSpriteFrames('frog.plist')
    display.removeSpriteFrames('horse.plist')
end

return GameLayer

local winSize = cc.Director:getInstance():getWinSize()

local blocks = {
    'bear', 'cat', 'fox', 'frog', 'horse', 'chicken'
}

-- 随机生成方块
local function getRandomBlockName()
    return blocks[math.random(1, #blocks)]
end

local GameScene = class('GameScene', function()
    return cc.Scene:create()
end)

function GameScene:ctor()

    self:registerScriptHandler(function(event)
        if event == 'enter' then
            self:onEnter()
        elseif event == 'enterTransitionFinish' then
            self:onEnterTransitionFinish()
        elseif event == 'exitTransitionStart' then
            self:onExitTransitionStart()
        elseif event == 'exit' then
            self:onExit()
        elseif event == 'cleanup' then
            self:cleanup()
        end
    end)

    self.selected = nil

    cc.SpriteFrameCache:getInstance():addSpriteFrames('cat.plist')
    cc.SpriteFrameCache:getInstance():addSpriteFrames('chicken.plist')
    cc.SpriteFrameCache:getInstance():addSpriteFrames('bear.plist')
    cc.SpriteFrameCache:getInstance():addSpriteFrames('frog.plist')
    cc.SpriteFrameCache:getInstance():addSpriteFrames('horse.plist')
    cc.SpriteFrameCache:getInstance():addSpriteFrames('fox.plist')
end

function GameScene.create()
    local scene = GameScene.new()
    scene:addChild(scene:createLayer())
    return scene
end

function GameScene:createLayer()
    cclog('GameScene init')
    local layer = cc.Layer:create()

    -- 添加背景
    local background = ccui.Scale9Sprite:create('background.png')
    background:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
    background:setContentSize(winSize)
    layer:addChild(background)

    -- 添加返回按钮
    local backMenuItem = cc.MenuItemFont:create('返回')
    backMenuItem:setFontSizeObj(32)
    backMenuItem:registerScriptTapHandler(function(sender)
        local MenuScene = require('menu_scene')
        local menuScene = MenuScene:create()
        cc.Director:getInstance():replaceScene(menuScene)
    end)

    -- 添加返回按钮菜单
    local backMenu = cc.Menu:create()
    backMenu:setPosition(cc.p(50, winSize.height - 40))
    backMenu:setAnchorPoint(cc.p(0, 1))
    backMenu:addChild(backMenuItem)

    layer:addChild(backMenu)

    -- 创建背景
    local drawNode = cc.DrawNode:create()
    drawNode:drawSolidRect(cc.p(0, 0), cc.p(64 * 8, 68 * 8), cc.c4b(0, 0, 0, 0.5))
    drawNode:setAnchorPoint(0, 0)
    drawNode:setPosition(cc.p(winSize.width / 2 - 64 * 4, winSize.height / 2 - 68 * 4))
    layer:addChild(drawNode)

    local BlockSprite = require('block_sprite')
    --初始化方块
    self.data = {}
    for i = 0, 7 do
        self.data[i] = {}
        for j = 0, 7 do
            local sprite = BlockSprite.create(getRandomBlockName(), 'selected')
            sprite:setAnchorPoint(0, 0)
            sprite:setPosition(drawNode:convertToWorldSpace(cc.p(i * 64, j * 68)))
            layer:addChild(sprite)
            self.data[i][j] = sprite
        end
    end

    return layer
end

function GameScene:onEnter()
end

function GameScene:onEnterTransitionFinish()
end

function GameScene:onExitTransitionStart()
end

function GameScene:onExit()
end

function GameScene:cleanup()
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile('cat.plist')
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile('chicken.plist')
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile('bear.plist')
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile('frog.plist')
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile('horse.plist')
end

return GameScene

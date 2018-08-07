local MenuScene = class('MenuScene', function()
    return cc.Scene:create()
end)

function MenuScene:ctor()
end

function MenuScene.create()
    local scene = MenuScene.new()
    scene:addChild(scene:createLayer())
    return scene
end

function MenuScene:createLayer()
    cclog('MenuScene init')
    local layer = cc.Layer:create()
    local menu = cc.Menu:create()

    -- 添加开始游戏按钮
    local startMenuItem = cc.MenuItemFont:create('开始游戏')
    startMenuItem:setFontSizeObj(64)
    startMenuItem:registerScriptTapHandler(function(sender)
        local GameScene = require('game_scene')
        local gameScene = GameScene.create()
        cc.Director:getInstance():replaceScene(gameScene)
    end)
    menu:addChild(startMenuItem)

    -- 如果不为iOS平台则添加退出游戏按钮
    if (cc.PLATFORM_OS_IPHONE ~= targetPlatform) and (cc.PLATFORM_OS_IPAD ~= targetPlatform) then
        local quitMenuItem = cc.MenuItemFont:create('退出游戏')
        quitMenuItem:registerScriptTapHandler(function()
            cc.Director:getInstance():endToLua()
        end)
        menu:addChild(quitMenuItem)
    end

    menu:alignItemsVertically()
    layer:addChild(menu)

    return layer
end

return MenuScene

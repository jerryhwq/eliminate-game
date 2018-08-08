local MenuLayer = class('MenuLayer', function()
    return cc.Layer:create()
end)

function MenuLayer:ctor()

    self:registerScriptHandler(function(event)
        if event == 'enter' then
            self:onEnter()
        elseif event == 'exit' then
            self:onExit()
        end
    end)

end

function MenuLayer:initLayer()
    local menu = cc.Menu:create()
    menu:alignItemsVertically()
    self:addChild(menu)

    -- 添加开始游戏按钮
    local startMenuItem = cc.MenuItemFont:create('开始游戏')
    startMenuItem:setFontSizeObj(64)
    local function startMenuItemHandler(sender)
        local GameScene = require('GameScene')
        local gameScene = GameScene.create()
        cc.Director:getInstance():replaceScene(gameScene)
    end
    startMenuItem:registerScriptTapHandler(startMenuItemHandler)
    menu:addChild(startMenuItem)

    -- 如果不为iOS平台则添加退出游戏按钮
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE ~= targetPlatform) and (cc.PLATFORM_OS_IPAD ~= targetPlatform) then
        local quitMenuItem = cc.MenuItemFont:create('退出游戏')
        local function quitMenuItemHandler()
            cc.Director:getInstance():endToLua()
        end
        quitMenuItem:registerScriptTapHandler(quitMenuItemHandler)
        menu:addChild(quitMenuItem)
    end
end

function MenuLayer:onEnter()
    self:initLayer()
end

function MenuLayer:onExit()

end

return MenuLayer
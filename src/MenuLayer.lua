local MenuLayer = class('MenuLayer', function()
    return cc.Layer:create()
end)

local TARGET_PLATFORM = cc.Application:getInstance():getTargetPlatform()

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
    self:addChild(menu)

    -- 开始游戏按钮
    local startMenuItem = cc.MenuItemFont:create('开始游戏')
    startMenuItem:setFontSizeObj(64)
    local function startMenuItemHandler(sender)
        local GameScene = require('GameScene')
        local gameScene = GameScene:create()
        cc.Director:getInstance():replaceScene(gameScene)
    end
    startMenuItem:registerScriptTapHandler(startMenuItemHandler)
    menu:addChild(startMenuItem)

    -- 退出游戏按钮
    local quitMenuItem = cc.MenuItemFont:create('退出游戏')
    local function quitMenuItemHandler()
        self:exitGame()
    end
    quitMenuItem:registerScriptTapHandler(quitMenuItemHandler)
    menu:addChild(quitMenuItem)

    -- 如果是iOS平台则隐藏退出游戏按钮
    if (cc.PLATFORM_OS_IPHONE == TARGET_PLATFORM) or (cc.PLATFORM_OS_IPAD == TARGET_PLATFORM) then
        quitMenuItem:setVisible(false)
    end

    menu:alignItemsVertically()

end

function MenuLayer:exitGame()
    if (cc.PLATFORM_OS_IPHONE ~= TARGET_PLATFORM) and (cc.PLATFORM_OS_IPAD ~= TARGET_PLATFORM) then
        cc.Director:getInstance():endToLua()
    end
end

function MenuLayer:initEvent()

    local keyboardEventListener = cc.EventListenerKeyboard:create()

    local function onKeyPressed(keyCode)
        if keyCode == cc.KeyCode.KEY_BACK then
            self:exitGame()
        end
    end
    keyboardEventListener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(keyboardEventListener, self)

end

function MenuLayer:onEnter()
    self:initLayer()
    self:initEvent()
end

function MenuLayer:onExit()

end

return MenuLayer

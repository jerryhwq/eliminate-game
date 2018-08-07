cc.FileUtils:getInstance():setPopupNotify(false)

winSize = cc.Director:getInstance():getWinSize()
targetPlatform = cc.Application:getInstance():getTargetPlatform()

require 'cocos.init'

cclog = function(...)
    print(string.format(...))
end

local function main()
    math.randomseed(os.time())
    local director = cc.Director:getInstance()
    director:setDisplayStats(true)
    director:setAnimationInterval(1.0 / 60)
    local MenuScene = require('menu_scene')
    local menuScene = MenuScene.create()
    if director:getRunningScene() then
        director:replaceScene(menuScene)
    else
        director:runWithScene(menuScene)
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end

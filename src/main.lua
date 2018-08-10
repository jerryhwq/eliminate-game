cc.FileUtils:getInstance():setPopupNotify(false)

require 'config'
require 'cocos.init'

cc.exports.cclog = function(...)
    print(string.format(...))
end

local function initAudio()
    audio.setMusicVolume(1)
    audio.preloadMusic('backgroun.mp3')
    audio.preloadSound('clear.mp3')
end

local function main()
    math.randomseed(os.time())
    initAudio()
    local director = cc.Director:getInstance()
    local MenuScene = require('MenuScene')
    local menuScene = MenuScene:create()
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

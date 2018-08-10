local GameLayer = require('GameLayer')

local GameScene = class('GameScene', function()
    return cc.Scene:create()
end)

function GameScene:ctor()
    self:registerScriptHandler(function(event)
        if event == 'enter' then
            self:onEnter()
        elseif event == 'enterTransitionFinish' then
            self:onEnterTransitionFinish()
        elseif event == 'exit' then
            self:onExit()
        elseif event == 'exitTransitionStart' then
            self:onExitTransitionStart()
        end
    end)
end

function GameScene:loadSpriteFrames()
    display.loadSpriteFrames('cat.plist', 'cat.png')
    display.loadSpriteFrames('chicken.plist', 'chicken.png')
    display.loadSpriteFrames('bear.plist', 'bear.png')
    display.loadSpriteFrames('frog.plist', 'frog.png')
    display.loadSpriteFrames('horse.plist', 'horse.png')
    display.loadSpriteFrames('fox.plist', 'fox.png')
end

function GameScene:unloadSpriteFrames()
    display.removeSpriteFrames('cat.plist')
    display.removeSpriteFrames('chicken.plist')
    display.removeSpriteFrames('bear.plist')
    display.removeSpriteFrames('frog.plist')
    display.removeSpriteFrames('horse.plist')
end

function GameScene:onEnter()
    self:loadSpriteFrames()
    self:addChild(GameLayer:create())
end

function GameScene:onEnterTransitionFinish()
    audio.playMusic('background.mp3', true)
end

function GameScene:onExitTransitionStart()
    audio.stopMusic()
end

function GameScene:onExit()
    self:unloadSpriteFrames()
end

return GameScene

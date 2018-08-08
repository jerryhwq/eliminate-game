local MenuScene = class('MenuScene', function()
    return cc.Scene:create()
end)

local MenuLayer = require('MenuLayer')

function MenuScene:ctor()
end

function MenuScene.create()
    local scene = MenuScene.new()
    scene:addChild(MenuLayer.new())
    return scene
end

return MenuScene

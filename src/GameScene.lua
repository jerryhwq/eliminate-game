local GameScene = class('GameScene', function()
    return cc.Scene:create()
end)

local GameLayer = require('GameLayer')

function GameScene.create()
    local scene = GameScene.new()
    scene:addChild(GameLayer.new())
    return scene
end

return GameScene

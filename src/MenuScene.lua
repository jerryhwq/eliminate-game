local MenuLayer = require('MenuLayer')

local MenuScene = class('MenuScene', function()
    return cc.Scene:create()
end)

function MenuScene:ctor()
    self:registerScriptHandler(function(event)
        if event == 'enter' then
            self:onEnter()
        end
    end)
end

function MenuScene:onEnter()
    self:addChild(MenuLayer:create())
end

return MenuScene

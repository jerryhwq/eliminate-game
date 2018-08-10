local BLOCKS = {
    'bear', 'cat', 'fox', 'frog', 'horse', 'chicken'
}

local function generateFrameName(type, state, num)
    return string.format('%s_%s_%04d', type, state, num)
end

local BlockSprite = class('BlockSprite', function(type, state)
    return cc.Sprite:createWithSpriteFrameName(generateFrameName(type, state, 0))
end)

function BlockSprite:ctor(type, state)
    self.type = type
    self.state = state
    self:setAnchorPoint(0, 0)
    self.animFrames = {}

    self:registerScriptHandler(function(event)
        if event == 'enter' then
            self:onEnter()
        end
    end)
end

function BlockSprite:onEnter()
    local frameNum
    if self.state == 'selected' then
        frameNum = 35
    elseif self.state == 'column' then
        frameNum = 23
    elseif self.state == 'line' then
        frameNum = 23
    end
    for i = 1, frameNum, 1 do
        self.animFrames[i] = display.newSpriteFrame(generateFrameName(self.type, self.state, i - 1))
    end
end

function BlockSprite:select()
    local animation = display.newAnimation(self.animFrames, 0.055)
    animation:setRestoreOriginalFrame(true)
    self.animation = self:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
end

function BlockSprite:deselect()
    if self.animation then
        self:stopAction(self.animation)
        self.animation = nil
        self:setSpriteFrame(display.newSpriteFrame(generateFrameName(self.type, self.state, 0)))
    end
end

function BlockSprite:moveTo(p, callback)
    callback = callback or function()
    end
    local move = cc.MoveTo:create(0.5, p)
    self:select()
    local finalCallback = function()
        self:deselect()
        callback()
    end
    local seq = cc.Sequence:create(move, cc.CallFunc:create(finalCallback))
    self:runAction(seq)
end

function BlockSprite.createRandomBlock()
    return BlockSprite:create(BLOCKS[math.random(1, #BLOCKS)], 'selected')
end

function BlockSprite:hasSameType(sprite)
    return sprite and sprite.type == self.type
end

return BlockSprite

local BLOCKS = {
    'bear', 'cat', 'fox', 'frog', 'horse', 'chicken'
}

local BlockSprite = class('BlockSprite', function(type, state)
    return cc.Sprite:createWithSpriteFrameName(string.format('%s_%s_%04d', type, state, 0))
end)

function BlockSprite:ctor()
    self.x = 0
    self.y = 0
end

function BlockSprite:select()
    local animFrames = {}
    for i = 1, 34, 1 do
        local frame = display.newSpriteFrame(string.format('%s_%s_%04d', self.type, self.state, i - 1))
        animFrames[i] = frame
    end
    local animation = display.newAnimation(animFrames, 0.055)
    animation:setRestoreOriginalFrame(false)
    self.animation = self:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
end

function BlockSprite:deselect()
    if self.animation then
        self:stopAction(self.animation)
        self.animation = nil
        self:setSpriteFrame(display.newSpriteFrame(string.format('%s_%s_%04d', self.type, self.state, 0)))
    end
end

function BlockSprite.create(type, state)
    local sprite = BlockSprite.new(BLOCKS[type], state)
    sprite:setAnchorPoint(0, 0)
    sprite.type = BLOCKS[type]
    sprite.state = state
    return sprite
end

function BlockSprite.createRandomBlock()
    return BlockSprite.create(math.random(1, #BLOCKS), 'selected')
end

function BlockSprite:setLocation(x, y)
    self.x = x
    self.y = y
end

return BlockSprite

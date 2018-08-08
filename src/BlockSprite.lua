local BLOCKS = {
    'bear', 'cat', 'fox', 'frog', 'horse', 'chicken'
}

local BlockSprite = class('BlockSprite', function(type, state)
    return cc.Sprite:createWithSpriteFrameName(string.format('%s_%s_%04d', BLOCKS[type], state, 0))
end)

function BlockSprite:ctor()
    self.x = 0
    self.y = 0
end

function BlockSprite.create(type, state)
    local sprite = BlockSprite.new(type, state)
    sprite:setAnchorPoint(0, 0)
    sprite.type = type
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

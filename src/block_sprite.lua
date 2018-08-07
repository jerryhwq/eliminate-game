local BlockSprite = class('BlockSprite', function(frameName)
    return cc.Sprite:createWithSpriteFrameName(frameName)
end)

function BlockSprite:ctor()
    self.x = 0
    self.y = 0
end

function BlockSprite.create(blockName, state)
    local sprite = BlockSprite.new(string.format('%s_%s_%s', blockName, state, '0000'))
    sprite.blockName = blockName
    sprite.state = state
    return sprite
end

function BlockSprite:setLocation(x, y)
    self.x = x
    self.y = y
end

return BlockSprite

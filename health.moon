collisionMasks = require "build.collisionMasks"
Entity = require "build.entity"

{graphics: graphics} = love

class Health extends Entity
  new: (@x, @y, @width=24, @height=24, @amountOfHealth=math.random(45, 70)) =>
    super @x, @y, {@width, @height}, "dynamic"
    @fixture\setFilterData collisionMasks.items, collisionMasks.solid + collisionMasks.player + collisionMasks.items, 0
    @sprite = graphics.newImage "sprites/health_pack.png"
    @sprite\setFilter "nearest", "nearest"
  getHealth: =>
    if not @body\isDestroyed!
      return @amountOfHealth
  draw: (x, y) =>
    local drawX, drawY
    if not @body\isDestroyed! 
      if not x and not y
        drawX = @body\getX! - @width / 2
        drawY = @body\getY! - @height / 2
      else
        drawX = x - @width / 2
        drawY = y - @height / 2
      graphics.setColor 255, 255, 255
      graphics.draw @sprite, drawX, drawY, 0, 2, 2

return Health
collisionMasks = require "build.collisionMasks"
Entity = require "build.entity"

{graphics: graphics} = love

getSign = () ->
  return math.random(0, 1) == 0 and -1 or 1

class Gold extends Entity
  new: (@x, @y, @width=8, @height=8, @value=5, @linearForce=getSign! * math.random(22, 34)) =>
  --   super @x, @y, {@width, @height}, "static"

  -- new: (@x, @y, @width=8, @height=8) =>
    super @x, @y, {@width, @height}, "dynamic", "rectangle"
    @fixture\setFilterData collisionMasks.items, collisionMasks.solid + collisionMasks.player, 0
    @body\applyLinearImpulse @linearForce, 100

  getValue: =>
    return @value

  draw: (x, y) =>
    local drawX, drawY
    if not @body\isDestroyed! 
      if not x and not y
        drawX = @body\getX! - @width / 2
        drawY = @body\getY! - @height / 2
      else
        drawX = x - @width
        drawY = y - @height
      graphics.setColor 255, 255, 0
      graphics.rectangle "fill", drawX, drawY, @width, @height

return Gold
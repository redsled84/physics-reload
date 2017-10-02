Entity = require "entity"

class Bullet extends Entity
  new: (@x, @y, @goalX, @goalY, @speed, @width, @height, @damage) =>
    super @x, @y, {@width, @height}, "dynamic", "circle"
    -- @fixture\setFilterData 1, 0, 0
    @calculateDirections!
    @body\setBullet true

    @fixture\setFilterData 1, 4, 0

  calculateDirections: =>
    @dx = @goalX - @x
    @dy = @goalY - @y
    @distance = math.sqrt math.pow(@goalX - @x, 2) + math.pow(@goalY - @y, 2)
    @directionX = (@dx) / @distance
    @directionY = (@dy) / @distance

  fire: =>
    @body\setLinearVelocity @directionX * @speed, @directionY * @speed

return Bullet
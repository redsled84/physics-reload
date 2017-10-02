Entity = require "entity"

class Bullet extends Entity
  new: (@x, @y, @goalX, @goalY, @speed, @width, @height, @damage) =>
    super @x, @y, {5, 12}, "dynamic", "rectangle"
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

    @body\setAngle math.atan2(@dy, @dx) + math.pi / 2

  fire: =>
    @body\setLinearVelocity @directionX * @speed, @directionY * @speed


return Bullet
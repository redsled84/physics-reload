import atan2, sqrt, pow, pi from math
Entity = require "entity"

class Bullet extends Entity
  new: (@x, @y, @goalX, @goalY, @speed, @width, @height, @damage) =>
    super @x, @y, {3, 7}, "dynamic", "rectangle"
    @calculateDirections!

    -- @fixture\setFilterData 1, 0, 0
    @body\setFixedRotation false
    @body\setBullet true

    @fixture\setFilterData 1, 4, 0

  calculateDirections: =>
    @dx = @goalX - @x
    @dy = @goalY - @y
    @distance = sqrt pow(@goalX - @x, 2) + pow(@goalY - @y, 2)
    @directionX = (@dx) / @distance
    @directionY = (@dy) / @distance

    @body\setAngle math.atan2(@dy, @dx) + math.pi / 2

  fire: =>
    @calculateDirections!
    @body\setAngle atan2(@dy, @dx) + pi / 2
    @body\setLinearVelocity @directionX * @speed * 10, @directionY * @speed * 10


return Bullet
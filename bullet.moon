import atan2, sqrt, pow, pi from math

collisionMasks = require "build.collisionMasks"
Entity = require "build.entity"

class Bullet extends Entity
  new: (@x, @y, @goalX, @goalY, @speed, @width, @height, @damage) =>
    super @x, @y, {@width, @height}, "dynamic", "rectangle"
    @calculateDirections!

    -- @fixture\setFilterData 1, 0, 0
    @body\setFixedRotation false
    @body\setBullet true

    @fixture\setFilterData collisionMasks.bullet, collisionMasks.solid, 0

  calculateDirections: =>
    @dx = @goalX - @x
    @dy = @goalY - @y
    @distance = sqrt pow(@goalX - @x, 2) + pow(@goalY - @y, 2)
    @directionX = (@dx) / @distance
    @directionY = (@dy) / @distance

    @body\setAngle atan2(@dy, @dx) + math.pi / 2

  fire: =>
    @calculateDirections!
    @body\setAngle atan2(@dy, @dx) + pi / 2
    @body\setLinearVelocity @directionX * @speed, @directionY * @speed


return Bullet
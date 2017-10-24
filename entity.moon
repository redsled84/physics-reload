collisionMasks = require "build.collisionMasks"

{physics: physics, graphics: graphics} = love

class Entity
  new: (@x, @y, @shapeArgs, @bodyType="static", @shapeType="rectangle") =>
    @body = physics.newBody world, @x, @y, @bodyType

    if @shapeType == "rectangle"
      @shape = physics.newRectangleShape @shapeArgs[1], @shapeArgs[2]
    elseif @shapeType == "circle"
      @shape = physics.newCircleShape @shapeArgs[1]
    elseif @shapeType == "polygon"
      @shape = physics.newPolygonShape @shapeArgs

    @fixture = physics.newFixture @body, @shape
    @fixture\setUserData self
    @fixture\setFilterData collisionMasks.solid, collisionMasks.player + collisionMasks.bulletHurtPlayer + collisionMasks.bulletHurtEnemy + collisionMasks.walker, 0

    @normal = {}

  setNormal: (normal) =>
    @normal = normal

  draw: (colors) =>
    if not @body\isDestroyed!
      if colors
        graphics.setColor unpack colors
      else
        graphics.setColor 10, 10, 10, 140
      if @shapeType ~= "circle"
        graphics.polygon "fill", @body\getWorldPoints @shape\getPoints!
      else
        graphics.circle "fill", @body\getX!, @body\getY!, @shape\getRadius!

  destroy: =>
    @body\destroy!

return Entity
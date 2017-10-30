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
    elseif @shapeType == "segment"
      @shape = physics.newEdgeShape @x, @y, @shapeArgs[1], @shapeArgs[2]

    @fixture = physics.newFixture @body, @shape
    @fixture\setUserData self
    @body\setUserData self
    if @shapeType ~= "segment"
      @fixture\setFilterData collisionMasks.solid, collisionMasks.player +
      collisionMasks.bulletHurtPlayer +
      collisionMasks.bulletHurtEnemy +
      collisionMasks.walker +
      collisionMasks.items, 0
      
      @normal = {}
      @gold = {}
      @nGold = math.random 3, 10
    else
      @fixture\setFilterData 0, 0, 0

  setNormal: (normal) =>
    @normal = normal

  draw: (colors) =>
    if not @body\isDestroyed!
      if colors
        graphics.setColor unpack colors
      else
        graphics.setColor 10, 10, 10, 140
      if @shapeType == "segment"
        graphics.line @x, @y, @shapeArgs[1], @shapeArgs[2]
        return
      if @shapeType ~= "circle"
        graphics.polygon "fill", @body\getWorldPoints @shape\getPoints!
      else
        graphics.circle "fill", @body\getX!, @body\getY!, @shape\getRadius!

  destroy: =>
    @body\destroy!

return Entity
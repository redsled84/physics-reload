class Entity
  new: (@x, @y, @shapeArgs, @bodyType="static", @shapeType="rectangle") =>
    @body = love.physics.newBody world, @x, @y, @bodyType

    if @shapeType == "rectangle"
      @shape = love.physics.newRectangleShape @shapeArgs[1], @shapeArgs[2]
    elseif @shapeType == "circle"
      @shape = love.physics.newCircleShape @shapeArgs[1]
    elseif @shapeType == "polygon"
      @shape = love.physics.newPolygonShape @shapeArgs

    @fixture = love.physics.newFixture @body, @shape
    @fixture\setUserData self
    @fixture\setFilterData 4, 3, 0

  draw: (colors) =>
    if colors
      love.graphics.setColor unpack colors
    if @shapeType ~= "circle"
      love.graphics.polygon "fill", @body\getWorldPoints @shape\getPoints!
    else
      love.graphics.circle "fill", @body\getX!, @body\getY!, @shape\getRadius!

return Entity
local Entity
do
  local _class_0
  local _base_0 = {
    draw = function(self, colors)
      if colors then
        love.graphics.setColor(unpack(colors))
      end
      if self.shapeType ~= "circle" then
        return love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
      else
        return love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, shapeArgs, bodyType, shapeType)
      if bodyType == nil then
        bodyType = "static"
      end
      if shapeType == nil then
        shapeType = "rectangle"
      end
      self.x, self.y, self.shapeArgs, self.bodyType, self.shapeType = x, y, shapeArgs, bodyType, shapeType
      self.body = love.physics.newBody(world, self.x, self.y, self.bodyType)
      if self.shapeType == "rectangle" then
        self.shape = love.physics.newRectangleShape(self.shapeArgs[1], self.shapeArgs[2])
      elseif self.shapeType == "circle" then
        self.shape = love.physics.newCircleShape(self.shapeArgs[1])
      elseif self.shapeType == "polygon" then
        self.shape = love.physics.newPolygonShape(self.shapeArgs)
      end
      self.fixture = love.physics.newFixture(self.body, self.shape)
      self.fixture:setUserData(self)
      return self.fixture:setFilterData(4, 3, 0)
    end,
    __base = _base_0,
    __name = "Entity"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Entity = _class_0
end
return Entity

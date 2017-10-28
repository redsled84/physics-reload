local collisionMasks = require("build.collisionMasks")
local physics, graphics
do
  local _obj_0 = love
  physics, graphics = _obj_0.physics, _obj_0.graphics
end
local Entity
do
  local _class_0
  local _base_0 = {
    setNormal = function(self, normal)
      self.normal = normal
    end,
    draw = function(self, colors)
      if not self.body:isDestroyed() then
        if colors then
          graphics.setColor(unpack(colors))
        else
          graphics.setColor(10, 10, 10, 140)
        end
        if self.shapeType ~= "circle" then
          return graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
        else
          return graphics.circle("fill", self.body:getX(), self.body:getY(), (function()
            local _base_1 = self.shape
            local _fn_0 = _base_1.getRadius
            return function(...)
              return _fn_0(_base_1, ...)
            end
          end)())
        end
      end
    end,
    destroy = function(self)
      return self.body:destroy()
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
      self.body = physics.newBody(world, self.x, self.y, self.bodyType)
      if self.shapeType == "rectangle" then
        self.shape = physics.newRectangleShape(self.shapeArgs[1], self.shapeArgs[2])
      elseif self.shapeType == "circle" then
        self.shape = physics.newCircleShape(self.shapeArgs[1])
      elseif self.shapeType == "polygon" then
        self.shape = physics.newPolygonShape(self.shapeArgs)
      end
      self.fixture = physics.newFixture(self.body, self.shape)
      self.fixture:setUserData(self)
      self.fixture:setFilterData(collisionMasks.solid, collisionMasks.player + collisionMasks.bulletHurtPlayer + collisionMasks.bulletHurtEnemy + collisionMasks.walker + collisionMasks.items, 0)
      self.normal = { }
      self.gold = { }
      self.nGold = math.random(3, 10)
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

local atan2, sqrt, pow, pi
do
  local _obj_0 = math
  atan2, sqrt, pow, pi = _obj_0.atan2, _obj_0.sqrt, _obj_0.pow, _obj_0.pi
end
local collisionMasks = require("build.collisionMasks")
local Entity = require("build.entity")
local Bullet
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    calculateDirections = function(self)
      self.dx = self.goalX - self.x
      self.dy = self.goalY - self.y
      self.distance = sqrt(pow(self.goalX - self.x, 2) + pow(self.goalY - self.y, 2))
      self.directionX = (self.dx) / self.distance
      self.directionY = (self.dy) / self.distance
      return self.body:setAngle(atan2(self.dy, self.dx) + math.pi / 2)
    end,
    fire = function(self)
      self:calculateDirections()
      self.body:setAngle(atan2(self.dy, self.dx) + pi / 2)
      return self.body:setLinearVelocity(self.directionX * self.speed, self.directionY * self.speed)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, goalX, goalY, speed, width, height, damage, canHurtEnemies)
      self.x, self.y, self.goalX, self.goalY, self.speed, self.width, self.height, self.damage, self.canHurtEnemies = x, y, goalX, goalY, speed, width, height, damage, canHurtEnemies
      _class_0.__parent.__init(self, self.x, self.y, {
        self.width,
        self.height
      }, "dynamic", "rectangle")
      self:calculateDirections()
      self.body:setFixedRotation(false)
      self.body:setBullet(true)
      self.body:setMass(.01)
      if self.canHurtEnemies then
        return self.fixture:setFilterData(collisionMasks.bulletHurtEnemy, collisionMasks.solid + collisionMasks.walker, 0)
      else
        return self.fixture:setFilterData(collisionMasks.bulletHurtPlayer, collisionMasks.solid + collisionMasks.player, 0)
      end
    end,
    __base = _base_0,
    __name = "Bullet",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Bullet = _class_0
end
return Bullet

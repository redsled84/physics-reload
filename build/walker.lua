local collisionMasks = require("build.collisionMasks")
local Entity = require("build.entity")
local Weapon = require("build.weapon")
local Walker
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    damage = function(self, attack)
      self.health = self.health - attack
    end,
    move = function(self, dt)
      if self.body:getX() < self.originX then
        self.dir = 1
        self.xVelocity = 10
      elseif self.body:getX() > self.endX then
        self.xVelocity = -10
        self.dir = -1
      end
      self.xVelocity = self.xVelocity + (self.dir * self.moveSpeed * dt)
      local vy
      local _
      _, vy = self.body:getLinearVelocity()
      return self.body:setLinearVelocity(self.xVelocity, vy)
    end,
    update = function(self, dt, targetX, targetY)
      if not self.body:isDestroyed() then
        self:move(dt)
        if self.health <= 0 then
          self.body:destroy()
          return 
        end
        self.weapon.x, self.weapon.y = self.body:getX(), self.body:getY()
        self.weapon:autoRemoveDestroyedBullets()
        self.weapon:shootAuto(targetX, targetY)
        return self.weapon:updateRateOfFire(dt)
      end
    end,
    draw = function(self)
      if not self.body:isDestroyed() then
        _class_0.__parent.__base.draw(self, {
          255,
          0,
          0
        })
      end
      return self.weapon:drawBullets()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, originX, originY, endX, endY)
      self.originX, self.originY, self.endX, self.endY = originX, originY, endX, endY
      _class_0.__parent.__init(self, self.originX, self.originY, {
        32,
        32
      }, "dynamic")
      self.dir = self.originX > self.endX and -1 or 1
      self.body:setFixedRotation(true)
      self.fixture:setFilterData(collisionMasks.walker, collisionMasks.solid + collisionMasks.bulletHurtEnemy + collisionMasks.player, 0)
      self.xVelocity = 0
      self.moveSpeed = 200
      self.health = 50
      self.weapon = Weapon(self.x, self.y, math.huge, math.pi / 10, false)
    end,
    __base = _base_0,
    __name = "Walker",
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
  Walker = _class_0
end
return Walker

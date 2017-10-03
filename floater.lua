local Entity = require("entity")
local Weapon = require("weapon")
local r
r = function(theta)
  return 100 - 30 * math.sin(theta)
end
local Floater
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    step = math.pi / 500,
    theta = 0,
    damage = function(self, attack)
      self.health = self.health - attack
    end,
    update = function(self, dt)
      self.theta = self.theta + self.step
      self.drawX = 100 * math.sqrt(2) * math.cos(2 * self.theta) / (math.sin(self.theta) ^ 2 + 1) + self.x
      self.drawY = 100 * math.sqrt(2) * math.cos(self.theta) * math.sin(self.theta) / (math.sin(self.theta) ^ 2 + 1) + self.y
      if self.health <= 0 and not self.body:isDestroyed() then
        self.body:destroy()
      end
      if not self.body:isDestroyed() then
        return self.body:setPosition(self.drawX, self.drawY)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, radius)
      if radius == nil then
        radius = 15
      end
      self.x, self.y, self.radius = x, y, radius
      self.drawX = r(0) * math.cos(0) + self.x
      self.drawY = r(0) * math.sin(0) + self.y
      _class_0.__parent.__init(self, self.drawX, self.drawY, {
        self.radius
      }, "static", "circle")
      self.health = 30
    end,
    __base = _base_0,
    __name = "Floater",
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
  Floater = _class_0
end
return Floater

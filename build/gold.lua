local collisionMasks = require("build.collisionMasks")
local Entity = require("build.entity")
local graphics
graphics = love.graphics
local getSign
getSign = function()
  return math.random(0, 1) == 0 and -1 or 1
end
local Gold
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    getValue = function(self)
      return self.value
    end,
    draw = function(self, x, y)
      local drawX, drawY
      if not self.body:isDestroyed() then
        if not x and not y then
          drawX = self.body:getX() - self.width / 2
          drawY = self.body:getY() - self.height / 2
        else
          drawX = x - self.width
          drawY = y - self.height
        end
        graphics.setColor(255, 223, 0, 200)
        return graphics.rectangle("fill", drawX, drawY, self.width, self.height)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, width, height, value, linearForce, yForce)
      if width == nil then
        width = 8
      end
      if height == nil then
        height = 8
      end
      if value == nil then
        value = 5
      end
      if linearForce == nil then
        linearForce = getSign() * math.random(4, 9)
      end
      if yForce == nil then
        yForce = -3
      end
      self.x, self.y, self.width, self.height, self.value, self.linearForce, self.yForce = x, y, width, height, value, linearForce, yForce
      _class_0.__parent.__init(self, self.x, self.y, {
        self.width,
        self.height
      }, "dynamic", "rectangle")
      self.fixture:setFilterData(collisionMasks.items, collisionMasks.solid + collisionMasks.player, 0)
      return self.body:applyLinearImpulse(self.linearForce, self.yForce)
    end,
    __base = _base_0,
    __name = "Gold",
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
  Gold = _class_0
end
return Gold

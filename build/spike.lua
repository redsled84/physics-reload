local Entity = require("build.entity")
local graphics
graphics = love.graphics
local Spike
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    draw = function(self)
      graphics.setColor(175, 0, 0, 65)
      graphics.polygon("fill", self.shapeArgs)
      graphics.setColor(175, 0, 0, 255)
      return graphics.polygon("line", self.shapeArgs)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, shapeArgs, attackPower)
      if attackPower == nil then
        attackPower = 10000
      end
      self.x, self.y, self.shapeArgs, self.attackPower = x, y, shapeArgs, attackPower
      return _class_0.__parent.__init(self, self.x, self.y, self.shapeArgs, "static", "polygon")
    end,
    __base = _base_0,
    __name = "Spike",
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
  Spike = _class_0
end
return Spike

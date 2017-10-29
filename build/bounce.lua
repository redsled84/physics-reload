local Entity = require("build.entity")
local graphics
graphics = love.graphics
local Bounce
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    draw = function(self)
      graphics.setColor(20, 255, 0, 65)
      graphics.polygon("fill", self.shapeArgs)
      graphics.setColor(20, 255, 0, 255)
      return graphics.polygon("line", self.shapeArgs)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, shapeArgs, bouncePower)
      if bouncePower == nil then
        bouncePower = 800
      end
      self.x, self.y, self.shapeArgs, self.bouncePower = x, y, shapeArgs, bouncePower
      return _class_0.__parent.__init(self, self.x, self.y, self.shapeArgs, "static", "polygon")
    end,
    __base = _base_0,
    __name = "Bounce",
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
  Bounce = _class_0
end
return Bounce

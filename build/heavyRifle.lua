local Weapon = require("build.weapon")
local HeavyRifle
do
  local _class_0
  local _parent_0 = Weapon
  local _base_0 = {
    drawBullets = function(self)
      return _class_0.__parent.__base.drawBullets(self, {
        255,
        10,
        255
      })
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y)
      self.x, self.y = x, y
      _class_0.__parent.__init(self, self.x, self.y, 1000, math.pi / 35, true, .05, 4000, 7, 4, 9)
      self.fireControl = "auto"
    end,
    __base = _base_0,
    __name = "HeavyRifle",
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
  HeavyRifle = _class_0
end
return HeavyRifle
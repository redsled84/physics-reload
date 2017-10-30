local Weapon = require("build.weapon")
local Pistol
do
  local _class_0
  local _parent_0 = Weapon
  local _base_0 = {
    drawBullets = function(self)
      return _class_0.__parent.__base.drawBullets(self, {
        255,
        10,
        125
      })
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y)
      self.x, self.y = x, y
      _class_0.__parent.__init(self, self.x, self.y, 1000, math.pi / 50, true, .2, 3000, 6, 8, 15)
      self.fireControl = "semi"
    end,
    __base = _base_0,
    __name = "Pistol",
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
  Pistol = _class_0
end
return Pistol

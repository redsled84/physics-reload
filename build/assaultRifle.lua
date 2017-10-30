local Weapon = require("build.weapon")
local AssaultRifle
do
  local _class_0
  local _parent_0 = Weapon
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y)
      self.x, self.y = x, y
      return _class_0.__parent.__init(self, self.x, self.y, 1000, math.pi / 95, true, .15, 5000, 10, 10, 20, 5.5)
    end,
    __base = _base_0,
    __name = "AssaultRifle",
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
  AssaultRifle = _class_0
end
return AssaultRifle

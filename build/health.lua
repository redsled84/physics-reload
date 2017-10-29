local collisionMasks = require("build.collisionMasks")
local Entity = require("build.entity")
local graphics
graphics = love.graphics
local Health
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    getHealth = function(self)
      if not self.body:isDestroyed() then
        return self.amountOfHealth
      end
    end,
    draw = function(self, x, y)
      local drawX, drawY
      if not self.body:isDestroyed() then
        if not x and not y then
          drawX = self.body:getX() - self.width / 2
          drawY = self.body:getY() - self.height / 2
        else
          drawX = x - self.width / 2
          drawY = y - self.height / 2
        end
        graphics.setColor(255, 255, 255)
        return graphics.draw(self.sprite, drawX, drawY, 0, 2, 2)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, width, height, amountOfHealth)
      if width == nil then
        width = 24
      end
      if height == nil then
        height = 24
      end
      if amountOfHealth == nil then
        amountOfHealth = 35
      end
      self.x, self.y, self.width, self.height, self.amountOfHealth = x, y, width, height, amountOfHealth
      _class_0.__parent.__init(self, self.x, self.y, {
        self.width,
        self.height
      }, "dynamic")
      self.fixture:setFilterData(collisionMasks.items, collisionMasks.solid + collisionMasks.player + collisionMasks.items, 0)
      self.sprite = graphics.newImage("sprites/health_pack.png")
      return self.sprite:setFilter("nearest", "nearest")
    end,
    __base = _base_0,
    __name = "Health",
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
  Health = _class_0
end
return Health

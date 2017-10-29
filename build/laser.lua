local Entity = require("build.entity")
local Laser
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    update = function(self, dt, player)
      local xn, yn, fraction
      xn, yn, fraction = player.shape:rayCast(self.originX, self.originY, self.endX, self.endY, 1, player.body:getX(), player.body:getY(), 0)
      if xn and yn and player.health > 0 then
        player:removeHealth(self.attackPower * dt)
        return playSound(self.laserSound)
      end
    end,
    draw = function(self, ox, oy, ex, ey)
      if not ox and not oy then
        love.graphics.setColor(255, 0, 0)
        return love.graphics.line(self.originX, self.originY, self.endX, self.endY)
      else
        love.graphics.setColor(255, 0, 0)
        return love.graphics.line(ox, oy, ex, ey)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, originX, originY, endX, endY, attackPower)
      if attackPower == nil then
        attackPower = math.random(600, 650)
      end
      self.originX, self.originY, self.endX, self.endY, self.attackPower = originX, originY, endX, endY, attackPower
      _class_0.__parent.__init(self, self.originX, self.originY, {
        self.endX,
        self.endY
      }, "static", "segment")
      self.laserSound = love.audio.newSource("audio/laser.wav", "static")
      return self.laserSound:setVolume(.08)
    end,
    __base = _base_0,
    __name = "Laser",
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
  Laser = _class_0
end
return Laser

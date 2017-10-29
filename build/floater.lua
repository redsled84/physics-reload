local cos, pi, sin, sqrt
do
  local _obj_0 = math
  cos, pi, sin, sqrt = _obj_0.cos, _obj_0.pi, _obj_0.sin, _obj_0.sqrt
end
local Entity = require("build.entity")
local Weapon = require("build.weapon")
local audio, graphics
do
  local _obj_0 = love
  audio, graphics = _obj_0.audio, _obj_0.graphics
end
local r
r = function(theta)
  return 30 - 40 * cos(theta)
end
local Floater
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    attackPower = 20,
    damage = function(self, attack)
      self.health = self.health - attack
    end,
    updateGold = function(self)
      if #self.gold > 0 then
        for i = self.nGold, 1, -1 do
          if self.gold[i].body:isDestroyed() then
            table.remove(self.gold, i)
            self.nGold = self.nGold - 1
          end
        end
      end
    end,
    update = function(self, dt)
      if not self.body:isDestroyed() then
        self.theta = self.theta + (self.step * dt)
        self.x = self.amplitude * r(self.theta) * cos(self.theta) + self.originX
        self.y = self.amplitude * r(self.theta) * sin(self.theta) + self.originY
        self.body:setPosition(self.x, self.y)
        if self.health <= 0 then
          playSound(self.popSound)
          self:destroy()
        end
      end
      return self:updateGold()
    end,
    drawGold = function(self)
      if #self.gold > 0 then
        for i = 1, #self.gold do
          self.gold[i]:draw()
        end
      end
    end,
    draw = function(self, x, y)
      if not self.body:isDestroyed() then
        if not x and not y then
          x = self.body:getX()
          y = self.body:getY()
        end
        graphics.setColor(255, 35, 8)
        graphics.circle("fill", x, y, self.radius)
        graphics.setColor(245, 245, 245)
        graphics.circle("fill", x, y, self.radius * (2 / 3))
        graphics.setColor(255, 35, 8)
        graphics.circle("fill", x, y, self.radius * (1 / 3))
      end
      return self:drawGold()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, originX, originY, radius, health, radiusFunction, step, theta, amplitude)
      if radius == nil then
        radius = 15
      end
      if health == nil then
        health = 10
      end
      if radiusFunction == nil then
        radiusFunction = r
      end
      if step == nil then
        step = math.pi / 2
      end
      if theta == nil then
        theta = 0
      end
      if amplitude == nil then
        amplitude = 1
      end
      self.originX, self.originY, self.radius, self.health, self.radiusFunction, self.step, self.theta, self.amplitude = originX, originY, radius, health, radiusFunction, step, theta, amplitude
      self.popSound = audio.newSource("audio/steve_hurt.mp3", "static")
      self.popSound:setVolume(.5)
      self.x = self.originX
      self.y = self.originY
      self.attackPower = 20
      return _class_0.__parent.__init(self, self.x, self.y, {
        self.radius
      }, "static", "circle")
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

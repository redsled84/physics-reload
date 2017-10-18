local abs
abs = math.abs
local collisionMasks = require("build.collisionMasks")
local inspect = require("libs.inspect")
local Entity = require("build.entity")
local Timer = require("build.timer")
local vx, vy, frc, dec, top, low
local acc
frc, acc, dec, top, low = 1000, 1000, 8000, 600, 50
local keyboard
keyboard = love.keyboard
local Player
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    damage = function(self, x, y, attackPower)
      self.activeHitStun = true
      return self.body:applyLinearImpulse(-1000 * x, -1000 * y)
    end,
    update = function(self, dt)
      if self.activeHitStun then
        self.hitStunTimer:update(dt, function()
          self.activeHitStun = false
        end)
        return 
      end
      local _, yv
      self:moveWithKeys(dt)
      _, yv = self.body:getLinearVelocity()
      if yv > self.terminalVelocity then
        yv = self.terminalVelocity
      end
      self.body:setLinearVelocity(self.xVelocity, yv)
      self.onGround = false
    end,
    moveWithKeys = function(self, dt)
      if keyboard.isDown('a') then
        if self.xVelocity > 0 then
          self.xVelocity = self.xVelocity - (dec * dt)
        elseif self.xVelocity > -top then
          self.xVelocity = self.xVelocity - (acc * dt)
        end
      elseif keyboard.isDown('d') then
        if self.xVelocity < 0 then
          self.xVelocity = self.xVelocity + (dec * dt)
        elseif self.xVelocity < top then
          self.xVelocity = self.xVelocity + (acc * dt)
        end
      else
        if abs(self.xVelocity) < low then
          self.xVelocity = 0
        elseif self.xVelocity > 0 then
          self.xVelocity = self.xVelocity - (frc * dt)
        elseif self.xVelocity < 0 then
          self.xVelocity = self.xVelocity + (frc * dt)
        end
      end
    end,
    jump = function(self, key)
      if #self.normal >= 2 then
        if key == "space" and self.onGround and not self.activeHitStun then
          local xv, _
          xv, _ = self.body:getLinearVelocity()
          return self.body:setLinearVelocity(xv, self.jumpVelocity)
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, width, height)
      if width == nil then
        width = 32
      end
      if height == nil then
        height = 64
      end
      self.x, self.y, self.width, self.height = x, y, width, height
      self.onGround = false
      _class_0.__parent.__init(self, self.x, self.y, {
        self.width,
        self.height
      }, "dynamic", "rectangle")
      self.body:setFixedRotation(true)
      self.fixture:setFilterData(collisionMasks.player, collisionMasks.solid, 0)
      self.xVelocity = 0
      self.terminalVelocity = 800
      self.jumpVelocity = -700
      self.hitStunTimer = Timer(2)
      self.activeHitStun = false
    end,
    __base = _base_0,
    __name = "Player",
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
  Player = _class_0
end
return Player

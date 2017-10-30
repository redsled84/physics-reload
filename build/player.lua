local abs
abs = math.abs
local collisionMasks = require("build.collisionMasks")
local inspect = require("libs.inspect")
local Entity = require("build.entity")
local Timer = require("build.timer")
local vx, vy, frc, dec, top, low
local acc
frc, acc, dec, top, low = 985, 900, 7500, 540, 45
local keyboard, graphics, mouse, audio
do
  local _obj_0 = love
  keyboard, graphics, mouse, audio = _obj_0.keyboard, _obj_0.graphics, _obj_0.mouse, _obj_0.audio
end
local Player
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    removeHealth = function(self, healthToRemove)
      if self.health - healthToRemove > 0 then
        self.health = self.health - healthToRemove
      else
        if self.deathSoundCount < 1 then
          self.deathSoundCount = self.deathSoundCount + 1
          playSound(self.deathSound)
        end
        self.health = 0
      end
    end,
    addHealth = function(self, healthToAdd)
      if self.health + healthToAdd < self.maxHealth then
        self.health = self.health + healthToAdd
      else
        self.health = self.maxHealth
      end
    end,
    removeGold = function(self, goldToRemove)
      if self.amountOfGold - goldToRemove < 0 then
        return false
      end
      self.amountOfGold = self.amountOfGold - goldToRemove
      return true
    end,
    addGold = function(self, goldToAdd)
      self.amountOfGold = self.amountOfGold + goldToAdd
    end,
    changeWeapon = function(self, weapon)
      self.weapon = weapon
    end,
    damageByImpulse = function(self, x, y, attackPower)
      self.activeHitStun = true
      self.body:applyLinearImpulse(800 * x, 800 * y)
      return self:removeHealth(attackPower)
    end,
    damage = function(self, attackPower)
      return self:removeHealth(attackPower)
    end,
    handleWeapon = function(self, dt, cam)
      if self.health <= 0 then
        return 
      end
      if not self.weapon then
        return 
      end
      self.weapon:update(dt, cam, self)
      return self.printTimer:update(dt, function() end)
    end,
    update = function(self, dt)
      if self.health <= 0 then
        return 
      end
      if self.weapon then
        if self.weapon.__class.__name == "Pistol" then
          self.body:setMass(4)
        elseif self.weapon.__class.__name == "Shotgun" then
          self.body:setMass(6.5)
        elseif self.weapon.__class.__name == "AssaultRifle" then
          self.body:setMass(8.0)
        elseif self.weapon.__class.__name == "HeavyRifle" then
          self.body:setMass(15.0)
        end
      end
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
      return self.body:setLinearVelocity(self.xVelocity, yv)
    end,
    moveWithKeys = function(self, dt)
      if self.activeHitStun then
        return 
      end
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
      if self.health <= 0 then
        return 
      end
      if #self.normal >= 2 then
        if (key == "w" or key == "space") and self.onGround and not self.activeHitStun then
          local xv, _
          xv, _ = self.body:getLinearVelocity()
          return self.body:setLinearVelocity(xv, self.jumpVelocity)
        end
      end
    end,
    drawHealth = function(self)
      local healthRatio
      healthRatio = self.health / self.maxHealth
      graphics.setColor(0, 0, 0, 150)
      local buffer
      buffer = 12
      graphics.rectangle("fill", graphics.getWidth() * (3 / 7) - buffer, graphics.getHeight() - 70 - buffer, 1 * 300 + buffer * 2, 15 + buffer * 2)
      graphics.setColor(255, 0, 0, 120)
      return graphics.rectangle("fill", graphics.getWidth() * (3 / 7), graphics.getHeight() - 70, healthRatio * 300, 15)
    end,
    drawLaser = function(self, cam, cursorImage)
      if self.weapon and self.health > 0 then
        graphics.setColor(255, 0, 0, 150)
        local targetX, targetY, slope
        targetX, targetY = cam:worldCoords(mouse.getX() + cursorImage:getWidth() / 2, mouse.getY() + cursorImage:getHeight() / 2)
        local den, num
        den = (self.body:getX() - targetX)
        num = ((self.body:getY() - self.height * (1 / 4)) - targetY)
        slope = den ~= 0 and num / den or false
        if den > 0 then
          self.dir = -1
        else
          self.dir = 1
        end
        if slope then
          targetX = targetX < self.body:getX() and 1000 * -math.abs(1 / slope) or 1000 * math.abs(1 / slope)
          targetY = targetX * slope
          return graphics.line(self.body:getX(), self.body:getY() - self.height * (1 / 4), targetX + self.body:getX(), targetY + self.body:getY())
        else
          if den == 0 then
            if targetY < self.body:getY() then
              return graphics.line(self.body:getX(), self.body:getY() - self.height * (1 / 4), self.body:getX(), self.body:getY() - 1000)
            else
              return graphics.line(self.body:getX(), self.body:getY() - self.height * (1 / 4), self.body:getX(), self.body:getY() + 1000)
            end
          elseif num == 0 then
            if targetX < self.body:getX() then
              return graphics.line(self.body:getX(), self.body:getY() - self.height * (1 / 4), self.body:getX() - 1000, self.body:getY())
            else
              return graphics.line(self.body:getX(), self.body:getY() - self.height * (1 / 4), self.body:getX() + 1000, self.body:getY())
            end
          end
        end
      end
    end,
    drawGold = function(self)
      local buffer
      buffer = 12
      graphics.setColor(0, 0, 0, 150)
      graphics.rectangle("fill", graphics.getWidth() * (5 / 7) - buffer * 2, graphics.getHeight() - buffer * 7.5, 220, 54)
      graphics.setColor(255, 223, 0, 150)
      return graphics.print("GOLD: " .. tostring(self.amountOfGold), graphics.getWidth() * (5 / 7) - buffer, graphics.getHeight() - buffer * 6)
    end,
    drawAmmo = function(self)
      local buffer
      buffer = 12
      graphics.setColor(0, 0, 0, 150)
      graphics.rectangle("fill", graphics.getWidth() * (1.9 / 7) - buffer * 2, graphics.getHeight() - buffer * 7.5, 185, 54)
      graphics.setColor(255, 255, 255, 150)
      return graphics.print("AMMO: " .. tostring(self.weapon.totalAmmo), graphics.getWidth() * (1.9 / 7) - buffer, graphics.getHeight() - buffer * 6)
    end,
    draw = function(self)
      _class_0.__parent.__base.draw(self, {
        5,
        5,
        5
      })
      if not self.weapon then
        return 
      end
      return self.weapon:drawBullets()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, width, height)
      if width == nil then
        width = 26
      end
      if height == nil then
        height = 54
      end
      self.x, self.y, self.width, self.height = x, y, width, height
      self.onGround = false
      local bevel
      bevel = 3
      _class_0.__parent.__init(self, self.x, self.y, {
        self.width / 2 - bevel,
        -self.height / 2,
        self.width / 2,
        -self.height / 2 + bevel,
        self.width / 2,
        self.height / 2 - bevel,
        self.width / 2 - bevel,
        self.height / 2,
        -self.width / 2 + bevel,
        self.height / 2,
        -self.width / 2,
        self.height / 2 - bevel,
        -self.width / 2,
        -self.height / 2 + bevel,
        -self.width / 2 + bevel,
        -self.height / 2
      }, "dynamic", "polygon")
      self.body:setFixedRotation(true)
      self.fixture:setFilterData(collisionMasks.player, collisionMasks.solid + collisionMasks.bulletHurtPlayer + collisionMasks.walker + collisionMasks.items + collisionMasks.turret, 0)
      self.xVelocity = 0
      self.terminalVelocity = 1000
      self.jumpVelocity = -700
      self.hitStunTimer = Timer(.5)
      self.printTimer = Timer(.05)
      self.activeHitStun = false
      self.maxHealth = 350
      self.health = self.maxHealth
      self.weapon = nil
      self.amountOfGold = 10000
      self.dir = 0
      self.deathSound = audio.newSource("audio/death.mp3", "static")
      self.deathSoundCount = 0
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

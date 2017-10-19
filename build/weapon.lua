local atan2, cos, pi, random, sin
do
  local _obj_0 = math
  atan2, cos, pi, random, sin = _obj_0.atan2, _obj_0.cos, _obj_0.pi, _obj_0.random, _obj_0.sin
end
local remove
remove = table.remove
local Bullet = require("build.bullet")
local shake = require("build.shake")
local graphics, audio, mouse
do
  local _obj_0 = love
  graphics, audio, mouse = _obj_0.graphics, _obj_0.audio, _obj_0.mouse
end
local gunShot = audio.newSource("audio/gunshot.wav", "static")
gunShot:setVolume(1)
local ammoFont = graphics.newFont("fonts/FFFFORWA.TTF", 20)
local Weapon
do
  local _class_0
  local _base_0 = {
    bullets = { },
    canShoot = true,
    rateOfFire = {
      time = 0,
      max = .15
    },
    minAtkPower = 5,
    maxAtkPower = 15,
    shakeConstant = 2.25,
    updateRateOfFire = function(self, dt)
      if self.rateOfFire.time < self.rateOfFire.max and not self.canShoot then
        self.rateOfFire.time = self.rateOfFire.time + dt
      else
        self.rateOfFire.time = 0
        self.canShoot = true
      end
    end,
    getVariableBulletVectors = function(self, bullet)
      local angle, goalX, goalY
      angle = atan2(bullet.dy, bullet.dx) + pi
      local randomAngle = random(1000 * (angle - self.sprayAngle), 1000 * (angle + self.sprayAngle)) / 1000
      return -bullet.distance * cos(randomAngle) + self.x, -bullet.distance * sin(randomAngle) + self.y
    end,
    shootBullet = function(self, x, y)
      local bullet
      self.canShoot = false
      self.ammoCount = self.ammoCount - 1
      shake:more(self.shakeConstant)
      bullet = Bullet(self.x, self.y, x, y, self.bulletSpeed, self.bulletSize, self.bulletSize, random(self.minAtkPower, self.maxAtkPower))
      bullet.goalX, bullet.goalY = self:getVariableBulletVectors(bullet)
      bullet:calculateDirections()
      bullet:fire()
      self.bullets[#self.bullets + 1] = bullet
      if gunShot:isPlaying() then
        gunShot:stop()
        return gunShot:play()
      else
        return gunShot:play()
      end
    end,
    shootAuto = function(self, x, y)
      local targetX, targetY
      targetX = x
      targetY = y
      if mouse.isDown(1) and self.canShoot and self.ammoCount > 0 and self.fireControl == "auto" then
        return self:shootBullet(targetX, targetY)
      end
    end,
    shootSemi = function(self, x, y, button)
      if button == 1 and self.canShoot and self.ammoCount > 0 and self.fireControl == "semi" then
        return self:shootBullet(x, y)
      end
    end,
    autoRemoveDestroyedBullets = function(self)
      for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        if b.body:isDestroyed() then
          remove(self.bullets, i)
        end
      end
    end,
    drawBullets = function(self)
      for i = 1, #self.bullets do
        graphics.setColor(0, 0, 255)
        local b = self.bullets[i]
        if not b.body:isDestroyed() then
          b:draw()
        end
      end
    end,
    drawAmmoCount = function(self)
      graphics.setFont(ammoFont)
      graphics.setColor(0, 0, 0)
      return graphics.print(self.ammoCount, 35, graphics:getHeight() - 45)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, magazineSize, sprayAngle)
      if sprayAngle == nil then
        sprayAngle = math.pi / 100
      end
      self.x, self.y, self.magazineSize, self.sprayAngle = x, y, magazineSize, sprayAngle
      self.ammoCount = self.magazineSize
      self.fireControl = "auto"
      self.bulletSpeed = 2700
      self.bulletSize = 6
    end,
    __base = _base_0,
    __name = "Weapon"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Weapon = _class_0
end
return Weapon

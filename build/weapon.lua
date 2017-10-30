local atan2, cos, pi, random, sin
do
  local _obj_0 = math
  atan2, cos, pi, random, sin = _obj_0.atan2, _obj_0.cos, _obj_0.pi, _obj_0.random, _obj_0.sin
end
local remove
remove = table.remove
local Bullet = require("build.bullet")
local Timer = require("build.timer")
local shake = require("build.shake")
local graphics, audio, mouse
do
  local _obj_0 = love
  graphics, audio, mouse = _obj_0.graphics, _obj_0.audio, _obj_0.mouse
end
local ammoFont = graphics.newFont("fonts/FFFFORWA.TTF", 20)
graphics.setFont(ammoFont)
local Weapon
do
  local _class_0
  local _base_0 = {
    bullets = { },
    canShoot = true,
    shakeConstant = 4.25,
    updateRateOfFire = function(self, dt)
      if not self.canShoot then
        return self.rateOfFireTimer:update(dt, function()
          self.canShoot = true
        end)
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
      if self.totalAmmo > 0 then
        self.totalAmmo = self.totalAmmo - 1
      end
      if self.isPlayerWeapon then
        shake:more(self.shakeConstant)
      end
      bullet = Bullet(self.x, self.y, x, y, self.bulletSpeed, self.bulletSize * (1 / 2), self.bulletSize * 2, random(self.minAtkPower, self.maxAtkPower), self.isPlayerWeapon)
      bullet.goalX, bullet.goalY = self:getVariableBulletVectors(bullet)
      bullet:calculateDirections()
      bullet:fire()
      self.bullets[#self.bullets + 1] = bullet
      return playSound(self.gunShotSound)
    end,
    shootAuto = function(self, x, y)
      local targetX, targetY
      targetX = x
      targetY = y
      if self.isPlayerWeapon and mouse.isDown(1) and self.canShoot and self.totalAmmo > 0 and self.fireControl == "auto" then
        return self:shootBullet(targetX, targetY)
      elseif not self.isPlayerWeapon and self.canShoot and self.totalAmmo > 0 and self.fireControl == "auto" then
        return self:shootBullet(targetX, targetY)
      end
    end,
    shootSemi = function(self, x, y, button)
      if button == 1 and self.canShoot and self.totalAmmo > 0 and self.fireControl == "semi" then
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
    update = function(self, dt, cam, obj)
      if obj then
        self.x, self.y = obj.body:getX(), obj.body:getY() - obj.height * (1 / 4)
      end
      self:autoRemoveDestroyedBullets()
      local mouseX, mouseY
      mouseX, mouseY = cam:worldCoords(mouse.getX(), mouse.getY())
      self:shootAuto(mouseX, mouseY)
      if not self.wcanShoot then
        return self:updateRateOfFire(dt)
      end
    end,
    drawBullets = function(self, color)
      graphics.setColor(0, 0, 255)
      if color then
        graphics.setColor(unpack(color))
      end
      for i = 1, #self.bullets do
        local b = self.bullets[i]
        if not b.body:isDestroyed() then
          b:draw()
        end
      end
    end,
    drawAmmoCount = function(self)
      graphics.setColor(0, 0, 0)
      return graphics.print(self.totalAmmo, 35, graphics:getHeight() - 45)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, totalAmmo, sprayAngle, isPlayerWeapon, rateOfFire, bulletSpeed, bulletSize, minAtkPower, maxAtkPower)
      if sprayAngle == nil then
        sprayAngle = math.pi / 100
      end
      if isPlayerWeapon == nil then
        isPlayerWeapon = false
      end
      if rateOfFire == nil then
        rateOfFire = .25
      end
      if bulletSpeed == nil then
        bulletSpeed = 2700
      end
      if bulletSize == nil then
        bulletSize = 10
      end
      if minAtkPower == nil then
        minAtkPower = 5
      end
      if maxAtkPower == nil then
        maxAtkPower = 15
      end
      self.x, self.y, self.totalAmmo, self.sprayAngle, self.isPlayerWeapon, self.rateOfFire, self.bulletSpeed, self.bulletSize, self.minAtkPower, self.maxAtkPower = x, y, totalAmmo, sprayAngle, isPlayerWeapon, rateOfFire, bulletSpeed, bulletSize, minAtkPower, maxAtkPower
      self.ammoCount = self.totalAmmo
      self.fireControl = "auto"
      self.rateOfFireTimer = Timer(self.rateOfFire)
      self.gunShotSound = audio.newSource("audio/gunshot.wav", "static")
      if self.isPlayerWeapon then
        return self.gunShotSound:setVolume(.5)
      else
        return self.gunShotSound:setVolume(.05)
      end
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

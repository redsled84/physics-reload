local Bullet = require("bullet")
local g
g = love.graphics
local Weapon
do
  local _class_0
  local _base_0 = {
    bullets = { },
    canShoot = true,
    rateOfFire = {
      time = 0,
      max = .12
    },
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
      angle = math.atan2(bullet.dy, bullet.dx) + math.pi
      local randomAngle = math.random(1000 * (angle - self.sprayAngle), 1000 * (angle + self.sprayAngle)) / 1000
      return -bullet.distance * math.cos(randomAngle) + self.x, -bullet.distance * math.sin(randomAngle) + self.y
    end,
    shootBullet = function(self, x, y)
      local bullet
      self.canShoot = false
      self.ammoCount = self.ammoCount - 1
      bullet = Bullet(self.x - self.bulletSize, self.y - self.bulletSize, x - self.bulletSize, y - self.bulletSize, self.bulletSpeed, self.bulletSize, self.bulletSize)
      bullet.goalX, bullet.goalY = self:getVariableBulletVectors(bullet)
      bullet:fire()
      self.bullets[#self.bullets + 1] = bullet
    end,
    shootAuto = function(self, x, y)
      local targetX, targetY
      targetX = x + 8
      targetY = y + 8
      if love.mouse.isDown(1) and self.canShoot and self.ammoCount > 0 and self.fireControl == "auto" then
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
          table.remove(self.bullets, i)
        end
      end
    end,
    drawBullets = function(self)
      for i = 1, #self.bullets do
        g.setColor(0, 0, 255)
        local b = self.bullets[i]
        if not b.body:isDestroyed() then
          b:draw()
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, magazineSize, sprayAngle)
      if sprayAngle == nil then
        sprayAngle = math.pi / 250
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
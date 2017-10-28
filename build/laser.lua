local Laser
do
  local _class_0
  local _base_0 = {
    update = function(self, dt, player)
      local xn, yn, fraction, dist
      dist = math.sqrt((self.originX - self.endX) ^ 2 + (self.originY - self.endY) ^ 2)
      xn, yn, fraction = player.shape:rayCast(self.originX, self.originY, self.endX, self.endY, dist, player.body:getX(), player.body:getY(), 0)
      if xn and yn then
        player:removeHealth(self.attackPower * dt)
        return playSound(self.laserSound)
      end
    end,
    draw = function(self)
      love.graphics.setColor(255, 0, 0)
      return love.graphics.line(self.originX, self.originY, self.endX, self.endY)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, originX, originY, endX, endY, attackPower)
      if attackPower == nil then
        attackPower = math.random(600, 650)
      end
      self.originX, self.originY, self.endX, self.endY, self.attackPower = originX, originY, endX, endY, attackPower
      self.body = {
        isDestroyed = function()
          return false
        end
      }
      self.laserSound = love.audio.newSource("audio/laser.wav", "static")
      return self.laserSound:setVolume(.5)
    end,
    __base = _base_0,
    __name = "Laser"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Laser = _class_0
end
return Laser

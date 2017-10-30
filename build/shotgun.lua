local Weapon = require("build.weapon")
local Shotgun
do
  local _class_0
  local _parent_0 = Weapon
  local _base_0 = {
    shootSemi = function(self, x, y, button)
      if button == 1 and self.canShoot and self.ammoCount > 0 and self.fireControl == "semi" then
        for i = 1, self.shotPerRound do
          self:shootBullet(x, y)
        end
        self.playOnce = 0
      end
    end,
    update = function(self, dt, cam, player)
      _class_0.__parent.__base.update(self, dt, cam, player)
      if self.rateOfFireTimer.time > self.rateOfFireTimer.max * .3 and self.playOnce < 1 then
        playSound(self.loadSound)
        self.playOnce = self.playOnce + 1
      end
    end,
    drawBullets = function(self)
      return _class_0.__parent.__base.drawBullets(self, {
        255,
        0,
        255
      })
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y)
      self.x, self.y = x, y
      _class_0.__parent.__init(self, self.x, self.y, 1000, math.pi / 8, true, .85, 1950, 7, 10, 19, 8.5)
      self.fireControl = "semi"
      self.shotPerRound = 8
      self.loadSound = love.audio.newSource("audio/shotgun_pump.mp3", "static")
      self.loadSound:setVolume(.2)
      self.playOnce = 0
    end,
    __base = _base_0,
    __name = "Shotgun",
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
  Shotgun = _class_0
end
return Shotgun

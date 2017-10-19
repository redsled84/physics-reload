local max, log, sin, cos
do
  local _obj_0 = math
  max, log, sin, cos = _obj_0.max, _obj_0.log, _obj_0.sin, _obj_0.cos
end
local graphics
graphics = love.graphics
local Shake
do
  local _class_0
  local _base_0 = {
    amount = 0,
    time = 0,
    reset = function(self)
      self.amount = 1
      self.time = 0
    end,
    update = function(self, dt)
      self.amount = max(1, self.amount ^ 0.9)
      self.time = self.time + dt
    end,
    more = function(self, growth)
      self.amount = self.amount + growth
    end,
    preDraw = function(self)
      local shakeFactor, waveX, waveY
      shakeFactor = self.amplitude * log(self.amount)
      waveX = sin(self.time * self.frequency)
      waveY = cos(self.time * self.frequency)
      graphics.push()
      return graphics.translate(shakeFactor * waveX, shakeFactor * waveY)
    end,
    postDraw = function(self)
      return graphics.pop()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, growth, amplitude, frequency)
      if growth == nil then
        growth = 5
      end
      if amplitude == nil then
        amplitude = 3
      end
      if frequency == nil then
        frequency = 250
      end
      self.growth, self.amplitude, self.frequency = growth, amplitude, frequency
    end,
    __base = _base_0,
    __name = "Shake"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Shake = _class_0
end
return Shake()

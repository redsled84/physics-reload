local Timer
do
  local _class_0
  local _base_0 = {
    update = function(self, dt, callback)
      if self.time >= self.max then
        self.time = 0
        return callback()
      else
        self.time = self.time + dt
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, max)
      if max == nil then
        max = .5
      end
      self.max = max
      self.time = math.random(0, self.max * 100) / 100
    end,
    __base = _base_0,
    __name = "Timer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Timer = _class_0
end
return Timer

local Timer
do
  local _class_0
  local _base_0 = {
    update = function(self, dt, callback)
      self.time = self.time - dt
      if self.time <= 0 then
        callback()
        self.time = self.max
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, max)
      self.max = max
      self.time = self.max
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

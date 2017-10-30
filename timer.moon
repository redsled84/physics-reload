class Timer
  new: (@max=.5) =>
    @time = math.random(0, @max * 100) / 100
  update: (dt, callback) =>
    if @time >= @max
      @time = 0
      callback()
    else
      @time += dt

return Timer
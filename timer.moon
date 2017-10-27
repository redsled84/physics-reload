class Timer
  new: (@max=.5) =>
    @time = 0
  update: (dt, callback) =>
    if @time >= @max
      @time = 0
      callback()
    else
      @time += dt

return Timer
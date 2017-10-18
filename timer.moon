class Timer
  new: (@max) =>
    @time = @max
  update: (dt, callback) =>
    @time -= dt
    if @time <= 0
      callback()
      @time = @max
return Timer
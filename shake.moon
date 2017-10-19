import max, log, sin, cos from math

{graphics: graphics} = love

class Shake
  new: (@growth=5, @amplitude=3, @frequency=250) =>
  amount: 0
  time: 0
  reset: =>
    @amount = 1
    @time = 0
  update: (dt) =>
    @amount = max 1, @amount ^ 0.9
    @time += dt
  more: (growth) =>
    @amount += growth
  preDraw: =>
    local shakeFactor, waveX, waveY
    shakeFactor = @amplitude * log @amount
    waveX = sin @time * @frequency
    waveY = cos @time * @frequency

    graphics.push!
    graphics.translate shakeFactor * waveX, shakeFactor * waveY
  postDraw: =>
    graphics.pop!

return Shake!
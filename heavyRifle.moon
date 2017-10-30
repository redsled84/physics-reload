Weapon = require "build.weapon"
class HeavyRifle extends Weapon
  new: (@x, @y) =>
    super @x, @y, 1000, math.pi/35, true, .05, 4000, 7, 4, 9
    @fireControl = "auto"
  drawBullets: =>
    super {255, 10, 255}
return HeavyRifle
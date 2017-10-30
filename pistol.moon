Weapon = require "build.weapon"

class Pistol extends Weapon
  new: (@x, @y) =>
    super @x, @y, 1000, math.pi/50, true, .2, 3000, 6, 8, 15
    @fireControl = "semi"
  drawBullets: =>
    super {255, 10, 125}
return Pistol
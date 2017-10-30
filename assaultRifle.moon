Weapon = require "build.weapon"
class AssaultRifle extends Weapon
  new: (@x, @y) =>
    super @x, @y, 1000, math.pi/95, true, .15, 5000, 10, 10, 20, 5.5
return AssaultRifle
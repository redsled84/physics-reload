Entity = require "build.entity"

{graphics: graphics} = love

class Spike extends Entity
  new: (@x, @y, @shapeArgs, @attackPower=10000) =>
    super @x, @y, @shapeArgs, "static", "polygon"
  draw: =>
    graphics.setColor 175, 0, 0, 65
    graphics.polygon "fill", @shapeArgs
    graphics.setColor 175, 0, 0, 255
    graphics.polygon "line", @shapeArgs
return Spike
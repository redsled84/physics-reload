Entity = require "build.entity"

{graphics: graphics} = love

class Bounce extends Entity
  new: (@x, @y, @shapeArgs, @bouncePower=700) =>
    super @x, @y, @shapeArgs, "static", "polygon"
  draw: =>
    -- super {20, 225, 0}
    graphics.setColor 20, 255, 0, 65
    graphics.polygon "fill", @shapeArgs
    graphics.setColor 20, 255, 0, 255
    graphics.polygon "line", @shapeArgs
return Bounce
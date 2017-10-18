import cos, pi, sin, sqrt from math

Entity = require "build.entity"
Weapon = require "build.weapon"

{graphics: graphics} = love

r = (theta) ->
 return 30 - 30 * sin(theta)

class Floater extends Entity
  new: (@originX, @originY, @radius=15, @health=100, @radiusFunction=r, @step=math.pi/2, @theta=0, @amplitude=1) =>
    @x = @originX
    @y = @originY
    super @x, @y, {@radius}, "static", "circle"
  attackPower: 20
  damage: (attack) =>
    @health -= attack
  update: (dt) =>
    if not @body\isDestroyed!
      @theta += @step * dt
      @x = @amplitude * r(@theta) * cos(@theta) + @originX
      @y = @amplitude * r(@theta) * sin(@theta) + @originY
      @body\setPosition @x, @y

      if @health <= 0
        @body\destroy!
  draw: =>
    if not @body\isDestroyed!
      graphics.setColor 255, 35, 8
      graphics.circle "fill", @x, @y, @radius
      graphics.setColor 245, 245, 245
      graphics.circle "fill", @x, @y, @radius * (2 / 3)
      graphics.setColor 255, 35, 8
      graphics.circle "fill", @x, @y, @radius * (1 / 3)

return Floater
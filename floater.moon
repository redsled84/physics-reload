import cos, pi, sin, sqrt from math

Entity = require "build.entity"
Weapon = require "build.weapon"

{audio: audio, graphics: graphics} = love

r = (theta) ->
 return 30 - 40 * cos(theta)

class Floater extends Entity
  new: (@originX, @originY, @radius=15, @health=10, @radiusFunction=r, @step=math.pi/2, @theta=0, @amplitude=1) =>
    @popSound = audio.newSource "audio/steve_hurt.mp3", "static"
    @popSound\setVolume .5
    @x = @originX
    @y = @originY
    @attackPower = 20
    super @x, @y, {@radius}, "static", "circle"
  attackPower: 20
  damage: (attack) =>
    @health -= attack

  updateGold: =>
    if #@gold > 0
      for i = @nGold, 1, -1
        if @gold[i].body\isDestroyed!
          table.remove @gold, i
          @nGold -= 1

  update: (dt) =>
    if not @body\isDestroyed!
      @theta += @step * dt
      @x = @amplitude * r(@theta) * cos(@theta) + @originX
      @y = @amplitude * r(@theta) * sin(@theta) + @originY
      @body\setPosition @x, @y

      if @health <= 0
        playSound @popSound

        @destroy!
    @updateGold!

  drawGold: =>
    if #@gold > 0
      for i = 1, #@gold
        @gold[i]\draw!

  draw: (x, y) =>
    if not @body\isDestroyed!
      if not x and not y
        x = @body\getX!
        y = @body\getY!
      graphics.setColor 255, 35, 8
      graphics.circle "fill", x, y, @radius
      graphics.setColor 245, 245, 245
      graphics.circle "fill", x, y, @radius * (2 / 3)
      graphics.setColor 255, 35, 8
      graphics.circle "fill", x, y, @radius * (1 / 3)
    @drawGold!

return Floater
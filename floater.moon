import cos, pi, sin, sqrt from math

Entity = require "build.entity"
Weapon = require "build.weapon"

r = (theta) ->
 return 100 - 30 * sin(theta)

class Floater extends Entity
  new: (@x, @y, @radius=15) =>
    @drawX = r(0) * cos(0) + @x
    @drawY = r(0) * sin(0) + @y
    super @drawX, @drawY, {@radius}, "static", "circle"
    @health = 30
    
  step: pi/500
  theta: 0
  damage: (attack) =>
    @health -= attack
  update: (dt) =>
    @theta += @step
    @drawX = 100 * sqrt(2) * cos(2 * @theta) / (sin(@theta)^2 + 1) + @x
    @drawY = 100 * sqrt(2) * cos(@theta) * sin(@theta) / (sin(@theta)^2 + 1) + @y

    if @health <= 0 and not @body\isDestroyed!
      @body\destroy!
    if not @body\isDestroyed!
      @body\setPosition @drawX, @drawY

return Floater
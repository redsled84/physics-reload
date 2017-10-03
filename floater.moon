Entity = require "entity"
Weapon = require "weapon"

r = (theta) ->
 return 100 - 30 * math.sin(theta)

class Floater extends Entity
  new: (@x, @y, @radius=15) =>
    @drawX = r(0) * math.cos(0) + @x
    @drawY = r(0) * math.sin(0) + @y
    super @drawX, @drawY, {@radius}, "static", "circle"
    @health = 30
    
  step: math.pi/500
  theta: 0
  damage: (attack) =>
    @health -= attack
  update: (dt) =>
    @theta += @step
    @drawX = 100 * math.sqrt(2) * math.cos(2 * @theta) / (math.sin(@theta)^2 + 1) + @x
    @drawY = 100 * math.sqrt(2) * math.cos(@theta) * math.sin(@theta) / (math.sin(@theta)^2 + 1) + @y

    if @health <= 0 and not @body\isDestroyed!
      @body\destroy!
    if not @body\isDestroyed!
      @body\setPosition @drawX, @drawY

return Floater
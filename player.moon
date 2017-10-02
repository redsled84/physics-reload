inspect = require "inspect"
Entity = require "entity"

{keyboard: k} = love

local vx, vy, frc, dec, top, low
frc, acc, dec, top, low = 1000, 1000, 8000, 600, 50

class Player extends Entity
  new: (@x, @y) =>
    @width, @height = 32, 64
    @onGround = false
    
    super @x, @y, {@width, @height}, "dynamic", "rectangle"

    @body\setFixedRotation true
    @fixture\setFilterData 3, 4, 0

    @xVelocity = 0
    @terminalVelocity = 800
    @jumpVelocity = -300

  update: (dt) =>
    local _, yv
    @moveWithKeys dt

    _, yv = @body\getLinearVelocity!
    if yv > @terminalVelocity
      yv = @terminalVelocity

    @body\setLinearVelocity @xVelocity, yv

    @onGround = false

  moveWithKeys: (dt) =>
    if k.isDown 'a' 
      if @xVelocity > 0
        @xVelocity -= dec * dt
      elseif @xVelocity > -top
        @xVelocity -= acc * dt
    elseif k.isDown 'd'
      if @xVelocity < 0
        @xVelocity += dec * dt
      elseif @xVelocity < top
        @xVelocity += acc * dt
    else
      if math.abs(@xVelocity) < low
        @xVelocity = 0
      elseif @xVelocity > 0
        @xVelocity -= frc * dt
      elseif @xVelocity < 0
        @xVelocity += frc * dt
  jump: (key) =>
    if key == "space" and @onGround
      local xv, _
      xv, _ = @body\getLinearVelocity!
      @body\setLinearVelocity xv, @jumpVelocity

return Player
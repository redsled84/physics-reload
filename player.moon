import abs from math

collisionMasks = require "collisionMasks"
inspect = require "inspect"
Entity = require "entity"

local vx, vy, frc, dec, top, low
frc, acc, dec, top, low = 1000, 1000, 8000, 600, 50

{keyboard: keyboard} = love

class Player extends Entity
  new: (@x, @y, @width=32, @height=64) =>
    @onGround = false
    
    super @x, @y, {@width, @height}, "dynamic", "rectangle"

    @body\setFixedRotation true
    @fixture\setFilterData collisionMasks.player, collisionMasks.solid, 0

    @xVelocity = 0
    @terminalVelocity = 800
    @jumpVelocity = -700

  update: (dt) =>
    local _, yv
    @moveWithKeys dt

    _, yv = @body\getLinearVelocity!
    if yv > @terminalVelocity
      yv = @terminalVelocity

    -- if #@normal >= 2
    --   if @normal[1] ~= 0 and math.abs(@normal[2]) ~= 1 and @onGround
        -- Code below makes ramps like super accelerators :D
        -- @xVelocity *= (1 / math.abs @normal[1])
    @body\setLinearVelocity @xVelocity, yv

    @onGround = false

  moveWithKeys: (dt) =>
    if keyboard.isDown 'a'
      if @xVelocity > 0
        @xVelocity -= dec * dt
      elseif @xVelocity > -top
        @xVelocity -= acc * dt
    elseif keyboard.isDown 'd'
      if @xVelocity < 0
        @xVelocity += dec * dt
      elseif @xVelocity < top
        @xVelocity += acc * dt
    else
      if abs(@xVelocity) < low
        @xVelocity = 0
      elseif @xVelocity > 0
        @xVelocity -= frc * dt
      elseif @xVelocity < 0
        @xVelocity += frc * dt

  jump: (key) =>
    if #@normal >= 2 then
      if key == "space" and @onGround
        local xv, _
        xv, _ = @body\getLinearVelocity!
        @body\setLinearVelocity xv, @jumpVelocity

return Player
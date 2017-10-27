import sqrt from math

collisionMasks = require "build.collisionMasks"
Entity = require "build.entity"
Weapon = require "build.weapon"

{graphics: graphics} = love

class Walker extends Entity
  new: (@originX, @originY, @endX, @endY, @awarenessDistance=650, @width=32, @height=32) =>
    super @originX, @originY, {@width, @height}, "dynamic"
    @originalDir = @originX > @endX and -1 or 1
    @dir = @originalDir

    @body\setFixedRotation true
    @fixture\setFilterData collisionMasks.walker, collisionMasks.solid + collisionMasks.bulletHurtEnemy + collisionMasks.player, 0

    @xVelocity = 0
    @moveSpeed = 200
    @health = 50
    @weapon = Weapon @x, @y, math.huge, math.pi / 18, false, .4, 3000, 4

  damage: (attack) =>
    @health -= attack

  move: (dt) =>
    local buffer
    buffer = 3
    if @originalDir == 1
      if @body\getX! - @width / 2 - buffer <= @originX
        @dir = 1
        @xVelocity = 10
      elseif @body\getX! + @width / 2 + buffer >= @endX
        @dir = -1
        @xVelocity = -10
    else
      if @body\getX! + @width / 2 + buffer >= @originX
        @dir = -1
        @xVelocity = -10
      elseif @body\getX! - @width / 2 - buffer <= @endX
        @dir = 1
        @xVelocity = 10

    @xVelocity += @dir * @moveSpeed * dt
    local vy
    _, vy = @body\getLinearVelocity!
    @body\setLinearVelocity @xVelocity, vy
    @touchingWall = false

  shootWeapon: (dt, targetX, targetY) =>
    @weapon.x, @weapon.y = @body\getX!, @body\getY!
    if @awarenessDistance >= sqrt (targetX - @weapon.x)^2 + (targetY-@weapon.y)^2
      @weapon\autoRemoveDestroyedBullets!
      @weapon\shootAuto targetX, targetY
      @weapon\updateRateOfFire dt

  update: (dt, targetX, targetY) =>
    if not @body\isDestroyed!
      @move dt
      if @health <= 0
        @body\destroy!
        return
      @shootWeapon dt, targetX, targetY

  draw: (x, y) =>
    if not @body\isDestroyed!
      if not x and not y
        x = @body\getX!
        y = @body\getY!
      -- else
      --   x -= @width
      --   y -= @height
      -- super {255,0,0}
      local drawX, drawY
      drawX = x - @width / 2
      drawY = y - @height / 2
      graphics.setColor 45, 25, 20, 225
      graphics.rectangle "fill", drawX, drawY, @width, @height
      graphics.setColor 190, 85, 35, 250
      local offset
      offset = 7
      graphics.rectangle "fill", drawX+offset, drawY+offset, @width-offset*2, @height-offset*2
    @weapon\drawBullets!

return Walker
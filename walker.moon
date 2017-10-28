import sqrt from math

collisionMasks = require "build.collisionMasks"
Entity = require "build.entity"
Gold = require "build.gold"
Weapon = require "build.weapon"

{graphics: graphics, audio: audio} = love

local hitAttackPowers
hitAttackPowers = {
  60,
  40,
  40,
  20,
  20,
  20,
  20,
  20,
  20,
  20,
}

class Walker extends Entity
  new: (@originX, @originY, @endX, @endY, @awarenessDistance=680, @width=32, @height=64) =>
    super @originX, @originY, {@width, @height}, "dynamic"
    @originalDir = @originX > @endX and -1 or 1
    @dir = @originalDir

    @body\setFixedRotation true
    @fixture\setFilterData collisionMasks.walker, collisionMasks.solid + collisionMasks.bulletHurtEnemy + collisionMasks.player, 0

    @xVelocity = 0
    @moveSpeed = 200
    @health = 50
    @weapon = Weapon @x, @y, math.huge, math.pi / 35, false, .35, 3000, 6, 5, 20

    @steveSound = audio.newSource "audio/steve_hurt.mp3", "static"
    @hitAttackPower = hitAttackPowers[math.random(1, #hitAttackPowers)]

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
    @weapon.x, @weapon.y = @body\getX!, @body\getY! - @height / 4
    if @awarenessDistance >= sqrt (targetX - @weapon.x)^2 + (targetY-@weapon.y)^2
      @weapon\autoRemoveDestroyedBullets!
      @weapon\shootAuto targetX, targetY
      @weapon\updateRateOfFire dt

  updateGold: =>
    if #@gold > 0
      for i = @nGold, 1, -1
        if @gold[i].body\isDestroyed!
          table.remove @gold, i
          @nGold -= 1

  update: (dt, targetX, targetY) =>
    if not @body\isDestroyed!
      @move dt
      if @health <= 0
        for i = 1, @nGold
          @gold[#@gold+1] = Gold math.floor(@body\getX!), math.floor(@body\getY!)
        playSound @steveSound
        @destroy!
        return

      @shootWeapon dt, targetX, targetY
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

      @drawGold!
    @weapon\drawBullets!

return Walker
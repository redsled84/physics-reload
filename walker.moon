collisionMasks = require "build.collisionMasks"
Entity = require "build.entity"
Weapon = require "build.weapon"

class Walker extends Entity
  new: (@originX, @originY, @endX, @endY) =>
    super @originX, @originY, {32, 32}, "dynamic"
    @dir = @originX > @endX and -1 or 1

    @body\setFixedRotation true
    @fixture\setFilterData collisionMasks.walker, collisionMasks.solid + collisionMasks.bulletHurtEnemy + collisionMasks.player, 0

    @xVelocity = 0
    @moveSpeed = 200
    @health = 50
    @weapon = Weapon @x, @y, math.huge, math.pi / 10, false

  damage: (attack) =>
    @health -= attack

  move: (dt) =>
    @xVelocity += @dir * @moveSpeed * dt
    local vy
    _, vy = @body\getLinearVelocity!
    @body\setLinearVelocity @xVelocity, vy

    if @x < @originX
      @dir = 1
    elseif @x > @endX
      @dir = -1

  update: (dt, targetX, targetY) =>
    if not @body\isDestroyed!
      @move dt
      if @health <= 0
        @body\destroy!
        return
      @weapon.x, @weapon.y = @body\getX!, @body\getY!
      @weapon\autoRemoveDestroyedBullets!
      @weapon\shootAuto targetX, targetY
      @weapon\updateRateOfFire dt

  draw: =>
    if not @body\isDestroyed!
      super {255,0,0}
    @weapon\drawBullets!

return Walker
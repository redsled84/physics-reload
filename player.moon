import abs from math

collisionMasks = require "build.collisionMasks"
inspect = require "libs.inspect"
Entity = require "build.entity"
Timer = require "build.timer"
Weapon = require "build.weapon"

local vx, vy, frc, dec, top, low
frc, acc, dec, top, low = 1000, 1000, 8000, 600, 50

{keyboard: keyboard, graphics: graphics, mouse: mouse} = love

class Player extends Entity
  new: (@x, @y, @width=26, @height=48) =>
  -- new: (@x, @y, @width=32) =>
    @onGround = false
    
    super @x, @y, {@width, @height}, "dynamic", "rectangle"

    @body\setFixedRotation true
    @fixture\setFilterData collisionMasks.player,
      collisionMasks.solid +
      collisionMasks.bulletHurtPlayer +
      collisionMasks.walker +
      collisionMasks.items, 0

    @xVelocity = 0
    @terminalVelocity = 800
    @jumpVelocity = -700

    @hitStunTimer = Timer .5
    @printTimer = Timer .05
    @activeHitStun = false

    @maxHealth = 200
    @health = @maxHealth

    @weapon = Weapon 0, 0, 1000, math.pi/75, true, .15, 3500, 7, 15, 25
    @amountOfGold = 0

  removeHealth: (healthToRemove) =>
    if @health - healthToRemove > 0
      @health -= healthToRemove
    else
      @health = 0

  addHealth: (healthToAdd) =>
    if @health + healthToAdd < @maxHealth
      @health += healthToAdd
    else
      @health = @maxHealth    

  addGold: (goldToAdd) =>
    @amountOfGold += goldToAdd

  damageByImpulse: (x, y, attackPower) =>
    @activeHitStun = true
    @body\applyLinearImpulse 800 * x, 800 * y
    @removeHealth attackPower

  damage: (attackPower) =>
    @removeHealth attackPower

  handleWeapon: (dt, cam) =>
    @weapon.x, @weapon.y = @body\getX!, @body\getY! - @height * (1 / 4)
    @weapon\autoRemoveDestroyedBullets!
    local mouseX, mouseY
    mouseX, mouseY = cam\worldCoords mouse.getX!, mouse.getY!
    @weapon\shootAuto mouseX, mouseY
    if not @weapon.canShoot
      @weapon\updateRateOfFire dt

    @printTimer\update dt, () ->
      -- print @weapon.canShoot

  update: (dt) =>
    if @health <= 0
      @health = 0
      @onGround = false
      return

    if @activeHitStun
      @hitStunTimer\update dt, () ->
        @activeHitStun = false
      return

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
      if (key == "w" or key == "space") and @onGround and not @activeHitStun
        local xv, _
        xv, _ = @body\getLinearVelocity!
        @body\setLinearVelocity xv, @jumpVelocity

  getTrajectoryPoint: (t) =>
    local stepVelocity, stepGravity
    stepVelocity = love.timer.getDelta! * 1000

    return @body\getX! + stepVelocity, @body\getY! + stepVelocity * t - (1/2) * world\getGravity! * t^2

  drawTrajectory: =>
    local tpX, tpY
    graphics.setColor 255, 0, 0
    for i = 0, 3, love.timer.getDelta!
       tpX, tpY = @getTrajectoryPoint(i)
       graphics.points tpX, tpY

  draw: =>
    super {25, 145, 245}
    -- graphics.setColor 25, 145, 245
    -- graphics.circle "fill", @body\getX!, @body\getY!, @radius
    
    local healthRatio
    healthRatio = @health / @maxHealth
    graphics.setColor 255, 0, 0
    graphics.rectangle "fill", @body\getX! - 15 - @width / 2, @body\getY! - @height / 2 - 15, healthRatio * 65, 10
    -- graphics.circle "fill", @body\getX!

    @weapon\drawBullets!
    -- @drawTrajectory!


return Player
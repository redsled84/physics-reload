import abs from math

collisionMasks = require "build.collisionMasks"
inspect = require "libs.inspect"
Entity = require "build.entity"
Timer = require "build.timer"
Weapon = require "build.weapon"

local vx, vy, frc, dec, top, low
frc, acc, dec, top, low = 1000, 1000, 8000, 600, 50

{keyboard: keyboard} = love

class Player extends Entity
  new: (@x, @y, @width=32, @height=64) =>
    @onGround = false
    
    super @x, @y, {@width, @height}, "dynamic", "rectangle"

    @body\setFixedRotation true
    @fixture\setFilterData collisionMasks.player, collisionMasks.solid + collisionMasks.bulletHurtPlayer + collisionMasks.walker, 0

    @xVelocity = 0
    @terminalVelocity = 800
    @jumpVelocity = -700

    @hitStunTimer = Timer .5
    @printTimer = Timer .05
    @activeHitStun = false

    @maxHealth = 200
    @health = @maxHealth

    @weapon = Weapon 0, 0, 1000, nil, true

  removeHealth: (healthToRemove) =>
    if @health - healthToRemove > 0
      @health -= healthToRemove
    else
      @health = 0

  damageByImpulse: (x, y, attackPower) =>
    @activeHitStun = true
    @body\applyLinearImpulse -1000 * x, -1000 * y
    @removeHealth attackPower

  damage: (attackPower) =>
    @removeHealth attackPower

  handleWeapon: (dt, cam) =>
    @weapon.x, @weapon.y = @body\getX!, @body\getY!
    @weapon\autoRemoveDestroyedBullets!
    local mouseX, mouseY
    mouseX, mouseY = cam\worldCoords love.mouse.getX!, love.mouse.getY!
    @weapon\shootAuto mouseX, mouseY
    @weapon\updateRateOfFire dt

    @printTimer\update dt, () ->
      print @weapon.canShoot

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
      if key == "space" and @onGround and not @activeHitStun
        local xv, _
        xv, _ = @body\getLinearVelocity!
        @body\setLinearVelocity xv, @jumpVelocity

  draw: =>
    super!
    local healthRatio
    healthRatio = @health / @maxHealth
    love.graphics.setColor 255, 0, 0
    love.graphics.rectangle "fill", @body\getX! - 15 - @width / 2, @body\getY! - @height / 2 - 15, healthRatio * 65, 10

    @weapon\drawBullets!

return Player
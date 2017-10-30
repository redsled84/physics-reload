import abs from math

collisionMasks = require "build.collisionMasks"
inspect = require "libs.inspect"
Entity = require "build.entity"
Timer = require "build.timer"
Pistol = require "build.pistol"
Weapon = require "build.weapon"

local vx, vy, frc, dec, top, low
frc, acc, dec, top, low = 985, 900, 7500, 540, 45

{keyboard: keyboard, graphics: graphics, mouse: mouse, audio: audio} = love

class Player extends Entity
  new: (@x, @y, @width=26, @height=54) =>
  -- new: (@x, @y, @width=32) =>
    @onGround = false
    
    local bevel
    bevel = 3
    super @x, @y, {
      @width / 2 - bevel,
      -@height / 2,
      @width / 2,
      -@height / 2 + bevel,
      @width / 2,
      @height / 2 - bevel,
      @width / 2 - bevel,
      @height / 2,
      -@width / 2 + bevel,
      @height / 2,
      -@width / 2,
      @height / 2 - bevel,
      -@width / 2,
      -@height / 2 + bevel,
      -@width / 2 + bevel,
      -@height / 2
    }, "dynamic", "polygon"

    @body\setFixedRotation true
    @fixture\setFilterData collisionMasks.player,
      collisionMasks.solid +
      collisionMasks.bulletHurtPlayer +
      collisionMasks.walker +
      collisionMasks.items +
      collisionMasks.turret, 0

    @xVelocity = 0
    @terminalVelocity = 1000
    @jumpVelocity = -700

    @hitStunTimer = Timer .5
    @printTimer = Timer .05
    @activeHitStun = false

    @maxHealth = 350
    @health = @maxHealth

    @weapon = nil
    @amountOfGold = 0
    @dir = 0

    @deathSound = audio.newSource "audio/death.mp3", "static"
    @deathSoundCount = 0

  removeHealth: (healthToRemove) =>
    if @health - healthToRemove > 0
      @health -= healthToRemove
    else
      if @deathSoundCount < 1
        @deathSoundCount += 1
        playSound @deathSound
      @health = 0

  addHealth: (healthToAdd) =>
    if @health + healthToAdd < @maxHealth
      @health += healthToAdd
    else
      @health = @maxHealth    

  removeGold: (goldToRemove) =>
    if @amountOfGold - goldToRemove < 0
      return false
    @amountOfGold -= goldToRemove
    return true


  addGold: (goldToAdd) =>
    @amountOfGold += goldToAdd

  changeWeapon: (weapon) =>
    @weapon = weapon

  damageByImpulse: (x, y, attackPower) =>
    @activeHitStun = true
    @body\applyLinearImpulse 800 * x, 800 * y
    @removeHealth attackPower

  damage: (attackPower) =>
    @removeHealth attackPower

  handleWeapon: (dt, cam) =>
    if @health <= 0
      return

    if not @weapon
      return

    @weapon\update dt, cam, self   

    @printTimer\update dt, () ->
      -- print @weapon.canShoot

  update: (dt) =>
    if @health <= 0
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

  moveWithKeys: (dt) =>
    if @activeHitStun
      return 
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
    if @health <= 0
      return

    if #@normal >= 2 then
      if (key == "w" or key == "space") and @onGround and not @activeHitStun
        local xv, _
        xv, _ = @body\getLinearVelocity!
        @body\setLinearVelocity xv, @jumpVelocity

  -- getTrajectoryPoint: (t) =>
  --   local stepVelocity, stepGravity
  --   stepVelocity = timer.getDelta! * 1000

  --   return @body\getX! + stepVelocity,
  --     @body\getY! + stepVelocity * t - (1/2) * world\getGravity! * t^2

  -- drawTrajectory: =>
  --   local tpX, tpY
  --   graphics.setColor 255, 0, 0
  --   for i = 0, 3, timer.getDelta!
  --      tpX, tpY = @getTrajectoryPoint(i)
  --      graphics.points tpX, tpY

  drawHealth: =>
    local healthRatio
    healthRatio = @health / @maxHealth
    graphics.setColor 0, 0, 0, 150
    local buffer
    buffer = 12
    graphics.rectangle "fill", graphics.getWidth! * (3/7) - buffer, graphics.getHeight! - 70 - buffer,
      1 * 300 + buffer * 2, 15 + buffer * 2
    graphics.setColor 255, 0, 0, 120
    graphics.rectangle "fill", graphics.getWidth! * (3/7), graphics.getHeight! - 70,
      healthRatio * 300, 15

  drawLaser: (cam, cursorImage) =>
    if @weapon and @health > 0
      graphics.setColor 255, 0, 0, 150
      local targetX, targetY, slope
      targetX, targetY = cam\worldCoords mouse.getX! + cursorImage\getWidth! / 2,
        mouse.getY! + cursorImage\getHeight! / 2
      local den, num
      den = (@body\getX! - targetX)
      num = ((@body\getY! - @height * (1/4)) - targetY)
      slope = den ~= 0 and num / den or false 
      if den > 0
        @dir = -1
      else
        @dir = 1
      if slope
        targetX = targetX < @body\getX! and
          1000 * -math.abs(1 / slope) or 1000 * math.abs(1 / slope)
        targetY = targetX * slope
        graphics.line @body\getX!, @body\getY! - @height * (1/4),
          targetX + @body\getX!, targetY + @body\getY!
      else
        if den == 0
          if targetY < @body\getY!
            graphics.line @body\getX!, @body\getY! - @height * (1/4),
              @body\getX!, @body\getY! - 1000
          else
            graphics.line @body\getX!, @body\getY! - @height * (1/4),
              @body\getX!, @body\getY! + 1000
        elseif num == 0
          if targetX < @body\getX!
            graphics.line @body\getX!, @body\getY! - @height * (1/4),
              @body\getX! - 1000, @body\getY!
          else
            graphics.line @body\getX!, @body\getY! - @height * (1/4),
              @body\getX! + 1000, @body\getY!

  drawGold: =>
    local buffer
    buffer = 12
    graphics.setColor 0, 0, 0, 150
    graphics.rectangle "fill", graphics.getWidth! * (5/7) - buffer * 2, graphics.getHeight! - buffer * 7.5, 220, 54
    graphics.setColor 255, 223, 0, 150
    graphics.print "GOLD: " .. tostring(@amountOfGold), graphics.getWidth! * (5/7) - buffer, graphics.getHeight! - buffer * 6

  drawAmmo: =>
    local buffer
    buffer = 12
    graphics.setColor 0, 0, 0, 150
    graphics.rectangle "fill", graphics.getWidth! * (1.9/7) - buffer * 2, graphics.getHeight! - buffer * 7.5, 185, 54
    graphics.setColor 255, 255, 255, 150
    graphics.print "AMMO: " .. tostring(@weapon.totalAmmo), graphics.getWidth! * (1.9/7) - buffer, graphics.getHeight! - buffer * 6    

  draw: =>
    super {5, 5, 5}
    if not @weapon
      return
    @weapon\drawBullets!
    -- graphics.setColor 25, 145, 245
    -- graphics.circle "fill", @body\getX!, @body\getY!, @radius
    
    -- graphics.circle "fill", @body\getX!

    -- @drawTrajectory!


return Player
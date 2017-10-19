import atan2, cos, pi, random, sin from math
import remove from table

Bullet = require "build.bullet"
shake = require "build.shake"

{graphics: graphics, audio: audio, mouse: mouse} = love

gunShot = audio.newSource "audio/gunshot.wav", "static"
gunShot\setVolume 1
ammoFont = graphics.newFont "fonts/FFFFORWA.TTF", 20

class Weapon
  new: (@x, @y, @magazineSize, @sprayAngle=math.pi/100) =>
    @ammoCount = @magazineSize
    -- @drawOffset = {x: @sprite\getWidth! / 4, y: @sprite\getHeight! / 2}
    @fireControl = "auto"
    @bulletSpeed = 2700
    @bulletSize = 6

  bullets: {}
  canShoot: true
  rateOfFire: {time: 0, max: .15}
  minAtkPower: 5
  maxAtkPower: 15
  shakeConstant: 2.25

  updateRateOfFire: (dt) =>
    if @rateOfFire.time < @rateOfFire.max and not @canShoot
      @rateOfFire.time += dt
    else
      @rateOfFire.time = 0
      @canShoot = true

  getVariableBulletVectors: (bullet) =>
    local angle, goalX, goalY
    -- calculate angle, note that the origin is position of weapon
    angle = atan2(bullet.dy, bullet.dx) + pi
    randomAngle = random(1000 * (angle - @sprayAngle),
      1000 * (angle + @sprayAngle)) / 1000

    -- negative bullet.distance because of how the trig functions return value
    -- with wrong sign?
    -- Polar coordinates are found like this:
    --   x = r * cos(theta)
    --   y = r * sin(theta)
    -- But we aren't calculating at the origin of the window, we need to translate
    -- the points to be relative to the weapon
    -- Thus:
    --   x = r * cos(theta) + weapon.x
    --   y = r * sin(theta) + weapon.y
    return -bullet.distance * cos(randomAngle) + @x, -bullet.distance * sin(randomAngle) + @y

  shootBullet: (x, y) =>
    local bullet
    @canShoot = false
    @ammoCount -= 1

    shake\more @shakeConstant

    bullet = Bullet @x, @y, x, y, @bulletSpeed, @bulletSize, @bulletSize, random(@minAtkPower, @maxAtkPower)
    bullet.goalX, bullet.goalY = @getVariableBulletVectors bullet
    -- print @x, @y, -bullet.distance * math.cos(angle) + @x, 
    bullet\calculateDirections!
    bullet\fire!

    -- Add bullet to world
    @bullets[#@bullets+1] = bullet

    if gunShot\isPlaying!
      gunShot\stop!
      gunShot\play!
    else
      gunShot\play!

  shootAuto: (x, y) =>
    local targetX, targetY
    targetX = x
    targetY = y
    if mouse.isDown(1) and @canShoot and @ammoCount > 0 and @fireControl == "auto"
      @shootBullet targetX, targetY

  shootSemi: (x, y, button) =>
    if button == 1 and @canShoot and @ammoCount > 0 and @fireControl == "semi"
      @shootBullet x, y

  autoRemoveDestroyedBullets: =>
    for i = #@bullets, 1, -1
      b = @bullets[i]
      if b.body\isDestroyed!
        remove @bullets, i

  drawBullets: =>
    for i = 1, #@bullets
      graphics.setColor 0, 0, 255
      b = @bullets[i]
      if not b.body\isDestroyed!
        b\draw!

  drawAmmoCount: =>
    graphics.setFont ammoFont
    graphics.setColor 0, 0, 0
    graphics.print @ammoCount, 35, graphics\getHeight! - 45


  -- draw: (x, y) =>
    -- graphics.setColor 255, 255, 255
    -- local angle, scale
    -- scale = .65
    -- angle = math.atan2(@y - y, @x - x) + math.pi
  
    -- graphics.setColor 0, 0, 0
    -- if angle < 3 * math.pi / 2 and angle > math.pi / 2
    --   graphics.draw @sprite, @x, @y, angle, scale, -scale, @drawOffset.x, @drawOffset.y
    -- else
    --   graphics.draw @sprite, @x, @y, angle, scale, scale, @drawOffset.x, @drawOffset.y
    -- -- if angle < 3 * math.pi / 2 and angle > math.pi / 2
    -- --   graphics.draw @sprite, @x, @y, angle, 1, -1, @drawOffset.x, @drawOffset.y
    -- -- else
    -- --   graphics.draw @sprite, @x, @y, angle, 1, 1, @drawOffset.x, @drawOffset.y
    -- graphics.print tostring @ammoCount

return Weapon
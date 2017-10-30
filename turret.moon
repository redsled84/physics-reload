import sqrt from math

collisionMasks = require "build.collisionMasks"
Entity = require "build.entity"
Weapon = require "build.weapon"
Gold = require "build.gold"

getSign = () ->
  return math.random(0, 1) == 0 and -1 or 1

class Turret extends Entity
  new: (@x, @y, @width=32, @height=32, @attackPower=math.random(10, 15)) =>
    super @x+@width/2, @y+@height/2, {@width, @height}, "static", "rectangle"
    @fixture\setFilterData collisionMasks.turret, collisionMasks.solid + collisionMasks.bulletHurtEnemy + collisionMasks.player, 0
    @awarenessDistance = 650
    @weapon = Weapon @x, @y, math.huge, math.pi / 90, false, 1, 3500, 8, 4, 8
    @health = math.random(25, 30)
  damage: (attackPower) =>
    @health -= attackPower
  shootWeapon: (dt, targetX, targetY) =>
    @weapon.x, @weapon.y = @body\getX!, @body\getY!
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
  update: (dt, player) =>
    if not @body\isDestroyed!
      if @health <= 0
        for i = 1, @nGold
          @gold[#@gold+1] = Gold math.floor(@body\getX!), math.floor(@body\getY!), nil, nil, nil, getSign!*math.random(5,10), 0
        @destroy!
        return
      @shootWeapon dt, player.body\getX!, player.body\getY!
    @updateGold!
  drawGold: =>
    if #@gold > 0
      for i = 1, #@gold
        @gold[i]\draw!
  draw: =>
    if not @body\isDestroyed!
      super {144,65,180}
    @weapon\drawBullets {0, 0, 0}
return Turret
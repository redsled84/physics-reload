inspect = require "inspect"
require "world"
Entity = require "entity"
Player = require "player"
Weapon = require "weapon"
player = Player 16, 32
floor = Entity 100, 500, {600, 32}
weapon = Weapon 0, 0, 100

setWorldCallbacks!

love.load = ->
  love.update = (dt) ->
    player\update dt
    world\update dt

    weapon\updateRateOfFire dt
    weapon\autoRemoveDestroyedBullets!
    weapon\shootAuto love.mouse.getX!, love.mouse.getY!
    weapon.x, weapon.y = player.body\getX!, player.body\getY!

  love.draw = ->
    player\draw {0, 255, 255}
    floor\draw {255, 0, 0}
    weapon\drawBullets!


  love.keypressed = (key) ->
    if key == "escape"
      love.event.quit!
    player\jump key
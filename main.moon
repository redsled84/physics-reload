inspect = require "inspect"
require "world"
Entity = require "entity"
Player = require "player"
Weapon = require "weapon"
player = Player 16, 32
-- floor = Entity 100, 500, {600, 32}
weapon = Weapon 0, 0, 100

level = require "level"
levelEntities = {}

for i = 1, #level
  target = level[i]
  if target.shapeType == "polygon"
    levelEntities[#levelEntities+1] = Entity target.x, target.y, level[target.vertices[1]], "static", "polygon"

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
    weapon\drawBullets!
    -- floor\draw {255, 0, 0}
    for i = 1, #levelEntities
      love.graphics.polygon "fill", unpack levelEntities[i].shapeArgs


  love.keypressed = (key) ->
    if key == "escape"
      love.event.quit!
    player\jump key
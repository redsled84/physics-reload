inspect = require "inspect"
require "world"
Camera = require "camera"
Entity = require "entity"
Floater = require "floater"
Player = require "player"
Weapon = require "weapon"
player = Player 16, 32
-- floor = Entity 100, 500, {600, 32}
weapon = Weapon 0, 0, 100
floater = Floater 350, 100

level = require "level"
levelEntities = {}

for i = 1, #level
  target = level[i]
  if target.shapeType == "polygon"
    levelEntities[#levelEntities+1] = Entity 0, 0, level[target.vertices[1]], "static", "polygon"

setWorldCallbacks!

cam = Camera love.graphics.getWidth! / 2, love.graphics.getHeight! / 2

love.load = ->
  love.update = (dt) ->
    player\update dt
    world\update dt
    floater\update dt

    weapon\updateRateOfFire dt
    weapon\autoRemoveDestroyedBullets!
    local mouseX, mouseY
    mouseX, mouseY = cam\worldCoords love.mouse.getX!, love.mouse.getY!
    weapon\shootAuto mouseX, mouseY
    weapon.x, weapon.y = player.body\getX!, player.body\getY!

    cam\lookAt player.body\getX!, player.body\getY!

  love.draw = ->
    cam\attach!

    player\draw {0, 255, 255}
    weapon\drawBullets!
    for i = 1, #levelEntities
      love.graphics.setColor 255, 255, 0, 200
      love.graphics.polygon "line", unpack levelEntities[i].shapeArgs
    weapon\drawAmmoCount!

    floater\draw!

    cam\detach!

  love.keypressed = (key) ->
    if key == "escape"
      love.event.quit!
    player\jump key
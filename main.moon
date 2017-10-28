math.randomseed os.time!

inspect = require "libs.inspect"
require "build.utils"
require "build.world"
Camera = require "libs.camera"
Editor = require "build.editor"
Entity = require "build.entity"
Floater = require "build.floater"
Gold = require "build.gold"
Player = require "build.player"
shake = require "build.shake"
-- Walker = require "build.walker"
Weapon = require "build.weapon"

local cam, editor, player, spawn, toggleEditor, walker, walker2, weapon, gold
initGame = ->
  editor = Editor!
  -- shake = Shake!

  -- Change this string to be the level you want to load!
  editor\loadSavedFile "levels/level10.lua"

  -- spawn position of the player
  spawn = {x: 64, y: 32}
  player = Player spawn.x, spawn.y
  -- floor = Entity 100, 500, {600, 32}
  -- walker = Walker 300, 32, 450, 32
  -- walker2 = Walker -200, -198, -100, -198
    -- floater = Floater 350, 100
  -- gold = Gold 32, 32

  setWorldCallbacks!

  cam = Camera love.graphics.getWidth! / 2, love.graphics.getHeight! / 2
  cam\zoomTo .8

  toggleEditor = false

  love.graphics.setBackgroundColor 230, 237, 247
  cursor = love.mouse.newCursor "sprites/cursor.png", 0, 0
  love.mouse.setCursor cursor

initGame!

local viewPort, xoffset, yoffset
xoffset = 200
yoffset = 175
viewPort = {
  min: {xoffset, yoffset},
  max: {love.graphics.getWidth! - xoffset, love.graphics.getHeight! - yoffset}
}

updateCamera = ->
  local px, py
  px, py = cam\cameraCoords player.x, player.y


love.load = ->
  love.update = (dt) ->
    if toggleEditor
      editor\update dt
    else
      shake\update dt
      player\update dt
      player\handleWeapon dt, cam
      world\update dt
      -- floater\update dt

      editor\updateObjects dt, player
      editor\updateWalkers dt, player.body\getX!, player.body\getY!


      -- print weapon.canShoot, weapon.rateOfFire.time

      -- cam\lookAt 300, 200
      cam\lookAt player.body\getX!, player.body\getY!

      -- walker\update dt, player.body\getX!, player.body\getY!
      -- walker2\update dt, player.body\getX!, player.body\getY!

      -- print walker2.dir

      -- print editor.objects[#editor.objects].dir

  love.draw = ->
    if toggleEditor
      editor\draw!
    else
      cam\attach!
      shake\preDraw!

      -- editor\drawGrid!
      for i = 1, #editor.entities
        editor.entities[i]\draw!
      editor\drawObjects!
      editor\drawObjectGold!
      
      player\draw {0, 255, 255}
      -- player\drawTrajectory!

      -- floater\draw!

      -- walker\draw!
      -- walker2\draw!

      -- gold\draw!
      shake\postDraw!
      cam\detach!
    
      player.weapon\drawAmmoCount!
      love.graphics.setColor 15, 15, 15
      love.graphics.print "Gold: " .. tostring(player.amountOfGold), 15, love.graphics.getHeight! - 100

  love.mousepressed = (x, y, button) ->
    if toggleEditor
      editor\mousepressed x, y, button

  love.keypressed = (key) ->
    if key == "escape" and not toggleEditor
      editor\saveFile!
      love.event.quit!
    elseif key == "escape" and toggleEditor
      toggleEditor = not toggleEditor
      cam\lookAt 0, 0

    if toggleEditor
      editor\keypressed key
      editor\hotLoad!
      editor\hotLoadObjects!
      player.body\setPosition spawn.x, spawn.y
      player.xVelocity = 50
      player.health = player.maxHealth
    else
      -- print inspect editor.objectData
      -- print #editor.objectData, #editor.objects
      player\jump key

    if key == "f3"
      toggleEditor = not toggleEditor

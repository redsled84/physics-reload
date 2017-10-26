inspect = require "libs.inspect"
require "build.world"
Camera = require "libs.camera"
Editor = require "build.editor"
Entity = require "build.entity"
Floater = require "build.floater"
Player = require "build.player"
shake = require "build.shake"
-- Walker = require "build.walker"
Weapon = require "build.weapon"

local cam, editor, player, spawn, toggleEditor, walker, walker2, weapon
initGame = ->
  editor = Editor!
  -- shake = Shake!

  -- Change this string to be the level you want to load!
  editor\loadSavedFile "levels/level3.lua"

  -- spawn position of the player
  spawn = {x: 64, y: 32}
  player = Player spawn.x, spawn.y
  -- floor = Entity 100, 500, {600, 32}
  -- walker = Walker 300, 32, 450, 32
  -- walker2 = Walker -200, -198, -100, -198
  
  -- floater = Floater 350, 100

  setWorldCallbacks!

  cam = Camera love.graphics.getWidth! / 2, love.graphics.getHeight! / 2

  toggleEditor = false

  love.graphics.setBackgroundColor 230, 237, 247

initGame!

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

      editor\updateObjects dt


      -- print weapon.canShoot, weapon.rateOfFire.time

      cam\lookAt player.body\getX!, player.body\getY!

      -- walker\update dt, player.body\getX!, player.body\getY!
      -- walker2\update dt, player.body\getX!, player.body\getY!

      -- print walker2.dir

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
      
      player\draw {0, 255, 255}

      -- floater\draw!

      -- walker\draw!
      -- walker2\draw!

      shake\postDraw!
      cam\detach!
    
      player.weapon\drawAmmoCount!

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

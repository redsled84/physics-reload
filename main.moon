inspect = require "libs.inspect"
require "build.world"
Camera = require "libs.camera"
Editor = require "build.editor"
Entity = require "build.entity"
Floater = require "build.floater"
Player = require "build.player"
Weapon = require "build.weapon"

local cam, editor, player, spawn, toggleEditor, weapon
initGame = ->
  editor = Editor!

  -- Change this string to be the level you want to load!
  editor\loadSavedFile "levels/level3.lua"

  -- spawn position of the player
  spawn = {x: 64, y: 32}
  player = Player spawn.x, spawn.y
  -- floor = Entity 100, 500, {600, 32}
  weapon = Weapon 0, 0, 100
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
      player\update dt
      world\update dt
      -- floater\update dt

      weapon\updateRateOfFire dt
      weapon\autoRemoveDestroyedBullets!
      local mouseX, mouseY
      mouseX, mouseY = cam\worldCoords love.mouse.getX!, love.mouse.getY!
      weapon\shootAuto mouseX, mouseY
      weapon.x, weapon.y = player.body\getX!, player.body\getY!

      cam\lookAt player.body\getX!, player.body\getY!

      -- print player.onGround

  love.draw = ->
    if toggleEditor
      editor\draw!
    else
      cam\attach!

      editor\drawGrid!
      for i = 1, #editor.entities
        editor.entities[i]\draw!
      weapon\drawBullets!
      player\draw {0, 255, 255}

      -- floater\draw!

      cam\detach!
    
      weapon\drawAmmoCount!

  love.mousepressed = (x, y, button) ->
    if toggleEditor
      editor\mousepressed x, y, button

  love.keypressed = (key) ->
    if key == "escape"
      love.event.quit!

    if toggleEditor
      editor\keypressed key
      editor\hotLoad!
      player.body\setPosition spawn.x, spawn.y
      player.xVelocity = 50

    else
      player\jump key

    if key == "f3"
      toggleEditor = not toggleEditor

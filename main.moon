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
Turret = require "build.turret"
shake = require "build.shake"
-- Walker = require "build.walker"
Weapon = require "build.weapon"
Phone = require "build.phone"

local cam, cursorImage, editor, player, phone, spawn, toggleEditor, walker, walker2, weapon, gold, turret
local togglePhone
initGame = ->
  editor = Editor!
  -- shake = Shake!

  -- Change this string to be the level you want to load!
  editor\loadSavedFile "levels/jumpbunnylevel.lua"
  -- print #editor.data

  -- spawn position of the player
  spawn = {x: 64, y: 32}
  player = Player spawn.x, spawn.y
  phone = Phone!
  -- floor = Entity 100, 500, {600, 32}
  -- walker = Walker 300, 32, 450, 32
  -- walker2 = Walker -200, -198, -100, -198
    -- floater = Floater 350, 100
  -- gold = Gold 32, 32

  setWorldCallbacks!

  cam = Camera love.graphics.getWidth! / 2, love.graphics.getHeight! / 2
  cam\zoomTo .8

  toggleEditor = false
  togglePhone = false

  love.graphics.setBackgroundColor 230, 237, 247
  cursorImage = love.graphics.newImage "sprites/cursor.png"
  cursor = love.mouse.newCursor "sprites/cursor.png", 0, 0
  love.mouse.setCursor cursor
  love.mouse.setGrabbed true

  -- turret = Turret 0, 0

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


local bodyList
love.load = ->
  love.update = (dt) ->
    if toggleEditor
      editor\update dt
    else
      shake\update dt
      player\handleWeapon dt, cam
      player\update dt

      -- print player.weapon.canShoot
      world\update dt
      -- floater\update dt
      -- editor\updateWalkers dt, player.body\getX!, player.body\getY!
      -- print weapon.canShoot, weapon.rateOfFire.time
      -- cam\lookAt 300, 200
      cam\lookAt player.body\getX!, player.body\getY!

      -- turret\update dt, player
      -- walker\update dt, player.body\getX!, player.body\getY!
      -- walker2\update dt, player.body\getX!, player.body\getY!
      -- print walker2.dir
      -- print editor.objects[#editor.objects].dir
      editor\updateObjects dt, player

  love.draw = ->
    if toggleEditor
      editor\draw!
    else
      cam\attach!
      shake\preDraw!

      -- editor\drawGrid!
      -- editor\drawShapes!
      for i = 1, #editor.entities
        editor.entities[i]\draw!
      editor\drawObjects!
      editor\drawObjectGold!

      
      player\draw {0, 255, 255}
      player\drawLaser cam, cursorImage
      
      -- player\drawTrajectory!

      -- floater\draw!

      -- walker\draw!
      -- walker2\draw!
      -- turret\draw!

      -- gold\draw!
      shake\postDraw!
      cam\detach!
    
      if togglePhone
        phone\draw!

      player\drawHealth!
      player\drawGold!
      if player.weapon
        player\drawAmmo!
      --   player.weapon\drawAmmoCount!

  love.mousepressed = (x, y, button) ->
    if toggleEditor
      editor\mousepressed x, y, button
    else
      local targetX, targetY
      targetX, targetY = cam\worldCoords x, y
      if player.weapon
        player.weapon\shootSemi targetX, targetY, button

  editorDebugPrint = ->
    local bodies, count
    bodies = world\getBodyList!
    count = 0
    local className
    local nLasers, nWalkers, nHealth, nFloaters
    nLasers, nWalkers, nHealth, nFloaters = 0, 0, 0, 0
    local nSpikes, nBounces, nSolids
    nSpikes, nBounces, nSolids = 0, 0, 0
    for i = #bodies, 1, -1
      -- count = (bodies[i]\getUserData!.__class.__name ~= "Laser" or bodies[i]\getUserData!.__class.__name ~= "Floater") and count + 1 or count
      className = bodies[i]\getUserData!.__class.__name
      -- if className ~= "Entity" or className ~= "Spike" or className ~= "Bounce"
      --   count += 1
      nLasers = className == "Laser" and nLasers + 1 or nLasers
      nWalkers = className == "Walker" and nWalkers + 1 or nWalkers
      nHealth = className == "Health" and nHealth + 1 or nHealth
      nFloaters = className == "Floater" and nFloaters + 1 or nFloaters
      -- nSpikes = className == "Spike" and nSpikes + 1 or nSpikes
      -- nBounces = className == "Bounce" and nBounces + 1 or nBounces
      -- nSolids = className == "Entity" and nSolids + 1 or nSolids

    
    print #editor.objects, #editor.objectData, nLasers, nWalkers, nHealth, nFloaters, nLasers+nWalkers+nHealth+nFloaters
    -- print inspect editor.objectData
    -- print #editor.entities, #editor.shapes, #editor.data, nSpikes, nBounces, nSolids

  love.keypressed = (key) ->
    if key == "escape" and not toggleEditor
      editor\saveFile!
      love.event.quit!
    elseif key == "escape" and toggleEditor
      toggleEditor = not toggleEditor
      cam\lookAt 0, 0

    if key == "h"
      editorDebugPrint!
      
    if toggleEditor
      editor\keypressed key
    else
      -- print inspect editor.objectData
      -- print #editor.objectData, #editor.objects
      editor.activeShapeType = "polygon"

      player\jump key
      if togglePhone
        phone\buy key, player
    if key == "e"
      togglePhone = not togglePhone

    if key == "f3"
      editor.selectedObject = -1
      editor.selectedShape = -1
      editor.activeDeleteIndex = -1

      togglePhone = false
      phone.lastBoughtItem = false

      editor\flushObjectGold!
      if not toggleEditor
        editor\hotLoad!
        editor\hotLoadObjects!
        love.mouse.setGrabbed false
      else
        love.mouse.setGrabbed true


      player.body\setPosition spawn.x, spawn.y
      player.amountOfGold = 0
      player.deathSoundCount = 0
      player.xVelocity = 50
      player.health = player.maxHealth
      player\changeWeapon nil

      phone\resetBuyList!

      toggleEditor = not toggleEditor


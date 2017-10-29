math.randomseed(os.time())
local inspect = require("libs.inspect")
require("build.utils")
require("build.world")
local Camera = require("libs.camera")
local Editor = require("build.editor")
local Entity = require("build.entity")
local Floater = require("build.floater")
local Gold = require("build.gold")
local Player = require("build.player")
local shake = require("build.shake")
local Weapon = require("build.weapon")
local cam, editor, player, spawn, toggleEditor, walker, walker2, weapon, gold
local initGame
initGame = function()
  editor = Editor()
  editor:loadSavedFile("levels/level10.lua")
  spawn = {
    x = 64,
    y = 32
  }
  player = Player(spawn.x, spawn.y)
  setWorldCallbacks()
  cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  cam:zoomTo(.8)
  toggleEditor = false
  love.graphics.setBackgroundColor(230, 237, 247)
  local cursor = love.mouse.newCursor("sprites/cursor.png", 0, 0)
  return love.mouse.setCursor(cursor)
end
initGame()
local viewPort, xoffset, yoffset
xoffset = 200
yoffset = 175
viewPort = {
  min = {
    xoffset,
    yoffset
  },
  max = {
    love.graphics.getWidth() - xoffset,
    love.graphics.getHeight() - yoffset
  }
}
local updateCamera
updateCamera = function()
  local px, py
  px, py = cam:cameraCoords(player.x, player.y)
end
local bodyList
love.load = function()
  love.update = function(dt)
    if toggleEditor then
      return editor:update(dt)
    else
      shake:update(dt)
      player:update(dt)
      player:handleWeapon(dt, cam)
      world:update(dt)
      cam:lookAt(player.body:getX(), player.body:getY())
      return editor:updateObjects(dt, player)
    end
  end
  love.draw = function()
    if toggleEditor then
      return editor:draw()
    else
      cam:attach()
      shake:preDraw()
      for i = 1, #editor.entities do
        editor.entities[i]:draw()
      end
      editor:drawObjects()
      editor:drawObjectGold()
      player:draw({
        0,
        255,
        255
      })
      shake:postDraw()
      cam:detach()
      player.weapon:drawAmmoCount()
      love.graphics.setColor(15, 15, 15)
      return love.graphics.print("Gold: " .. tostring(player.amountOfGold), 15, love.graphics.getHeight() - 100)
    end
  end
  love.mousepressed = function(x, y, button)
    if toggleEditor then
      return editor:mousepressed(x, y, button)
    end
  end
  love.keypressed = function(key)
    if key == "escape" and not toggleEditor then
      editor:saveFile()
      love.event.quit()
    elseif key == "escape" and toggleEditor then
      toggleEditor = not toggleEditor
      cam:lookAt(0, 0)
    end
    if key == "h" then
      local bodies, count
      bodies = world:getBodyList()
      count = 0
      local className
      local nLasers, nWalkers, nHealth, nFloaters
      nLasers, nWalkers, nHealth, nFloaters = 0, 0, 0, 0
      local nSpikes, nBounces, nSolids
      nSpikes, nBounces, nSolids = 0, 0, 0
      for i = #bodies, 1, -1 do
        className = bodies[i]:getUserData().__class.__name
        nLasers = className == "Laser" and nLasers + 1 or nLasers
        nWalkers = className == "Walker" and nWalkers + 1 or nWalkers
        nHealth = className == "Health" and nHealth + 1 or nHealth
        nFloaters = className == "Floater" and nFloaters + 1 or nFloaters
      end
      print(#editor.objects, #editor.objectData, nLasers, nWalkers, nHealth, nFloaters, nLasers + nWalkers + nHealth + nFloaters)
    end
    if toggleEditor then
      editor:keypressed(key)
    else
      editor.activeShapeType = "polygon"
      player:jump(key)
    end
    if key == "f3" then
      editor.selectedObject = -1
      editor.selectedShape = -1
      editor.activeDeleteIndex = -1
      editor:flushObjectGold()
      if not toggleEditor then
        editor:hotLoad()
        editor:hotLoadObjects()
        print(true)
      end
      player.body:setPosition(spawn.x, spawn.y)
      player.amountOfGold = 0
      player.deathSoundCount = 0
      player.xVelocity = 50
      player.health = player.maxHealth
      toggleEditor = not toggleEditor
    end
  end
end

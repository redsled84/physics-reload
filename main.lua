local inspect = require("libs.inspect")
require("build.world")
local Camera = require("libs.camera")
local Editor = require("build.editor")
local Entity = require("build.entity")
local Floater = require("build.floater")
local Player = require("build.player")
local shake = require("build.shake")
local Weapon = require("build.weapon")
local cam, editor, player, spawn, toggleEditor, weapon
local initGame
initGame = function()
  editor = Editor()
  spawn = {
    x = 64,
    y = 32
  }
  player = Player(spawn.x, spawn.y)
  weapon = Weapon(0, 0, 100)
  setWorldCallbacks()
  cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  toggleEditor = false
  return love.graphics.setBackgroundColor(230, 237, 247)
end
initGame()
love.load = function()
  love.update = function(dt)
    if toggleEditor then
      return editor:update(dt)
    else
      shake:update(dt)
      player:update(dt)
      world:update(dt)
      for i = 1, #editor.objects do
        editor.objects[i]:update(dt)
      end
      weapon:updateRateOfFire(dt)
      weapon:autoRemoveDestroyedBullets()
      local mouseX, mouseY
      mouseX, mouseY = cam:worldCoords(love.mouse.getX(), love.mouse.getY())
      weapon:shootAuto(mouseX, mouseY)
      weapon.x, weapon.y = player.body:getX(), player.body:getY()
      return cam:lookAt(player.body:getX(), player.body:getY())
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
      weapon:drawBullets()
      player:draw({
        0,
        255,
        255
      })
      shake:postDraw()
      cam:detach()
      return weapon:drawAmmoCount()
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
    if toggleEditor then
      editor:keypressed(key)
      editor:hotLoad()
      player.body:setPosition(spawn.x, spawn.y)
      player.xVelocity = 50
    else
      player:jump(key)
    end
    if key == "f3" then
      toggleEditor = not toggleEditor
    end
  end
end

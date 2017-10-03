local inspect = require("inspect")
require("world")
local Camera = require("camera")
local Entity = require("entity")
local Floater = require("floater")
local Player = require("player")
local Weapon = require("weapon")
local player = Player(16, 32)
local weapon = Weapon(0, 0, 100)
local floater = Floater(350, 100)
local level = require("level")
local levelEntities = { }
for i = 1, #level do
  local target = level[i]
  if target.shapeType == "polygon" then
    levelEntities[#levelEntities + 1] = Entity(0, 0, level[target.vertices[1]], "static", "polygon")
  end
end
setWorldCallbacks()
local cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
love.load = function()
  love.update = function(dt)
    player:update(dt)
    world:update(dt)
    floater:update(dt)
    weapon:updateRateOfFire(dt)
    weapon:autoRemoveDestroyedBullets()
    local mouseX, mouseY
    mouseX, mouseY = cam:worldCoords(love.mouse.getX(), love.mouse.getY())
    weapon:shootAuto(mouseX, mouseY)
    weapon.x, weapon.y = player.body:getX(), player.body:getY()
    return cam:lookAt(player.body:getX(), player.body:getY())
  end
  love.draw = function()
    cam:attach()
    player:draw({
      0,
      255,
      255
    })
    weapon:drawBullets()
    for i = 1, #levelEntities do
      love.graphics.setColor(255, 255, 0, 200)
      love.graphics.polygon("line", unpack(levelEntities[i].shapeArgs))
    end
    weapon:drawAmmoCount()
    floater:draw()
    return cam:detach()
  end
  love.keypressed = function(key)
    if key == "escape" then
      love.event.quit()
    end
    return player:jump(key)
  end
end

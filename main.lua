local inspect = require("inspect")
require("world")
local Entity = require("entity")
local Player = require("player")
local Weapon = require("weapon")
local player = Player(16, 32)
local weapon = Weapon(0, 0, 100)
local level = require("level")
local levelEntities = { }
for i = 1, #level do
  local target = level[i]
  if target.shapeType == "polygon" then
    levelEntities[#levelEntities + 1] = Entity(target.x, target.y, level[target.vertices[1]], "static", "polygon")
  end
end
setWorldCallbacks()
love.load = function()
  love.update = function(dt)
    player:update(dt)
    world:update(dt)
    weapon:updateRateOfFire(dt)
    weapon:autoRemoveDestroyedBullets()
    weapon:shootAuto(love.mouse.getX(), love.mouse.getY())
    weapon.x, weapon.y = player.body:getX(), player.body:getY()
  end
  love.draw = function()
    player:draw({
      0,
      255,
      255
    })
    weapon:drawBullets()
    for i = 1, #levelEntities do
      levelEntities[i]:draw({
        255,
        0,
        0
      })
    end
  end
  love.keypressed = function(key)
    if key == "escape" then
      love.event.quit()
    end
    return player:jump(key)
  end
end

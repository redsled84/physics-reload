local inspect = require("inspect")
require("world")
local Entity = require("entity")
local Player = require("player")
local Weapon = require("weapon")
local player = Player(16, 32)
local floor = Entity(100, 500, {
  600,
  32
})
local weapon = Weapon(0, 0, 100)
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
    floor:draw({
      255,
      0,
      0
    })
    return weapon:drawBullets()
  end
  love.keypressed = function(key)
    if key == "escape" then
      love.event.quit()
    end
    return player:jump(key)
  end
end

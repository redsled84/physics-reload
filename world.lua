inspect = require "inspect"
world = love.physics.newWorld(0, 1050, true)

local function beginContact(a, b, coll)

end

local function endContact(a, b, coll)
  
end

local function preSolve(a, b, coll)
end

local function postSolve(a, b, coll, normalimpulse, tangentimpulse)
  local obj1, obj2 = a:getUserData(), b:getUserData()
  local x, y = coll:getNormal()

  local player = getObject(obj1, obj2, "Player")
  local bullet = getObject(obj1, obj2, "Bullet")
  local floater = getObject(obj1, obj2, "Floater")

  if player then
    if math.abs(x) == 1 then
      player.xVelocity = 0
    end
    if y > 0 and y <= 1 then
      player.onGround = true
    end

    player:setNormal({x, y})
  end

  if bullet then
    bullet.body:destroy()
  end

  if floater and bullet and not floater.body:isDestroyed() then
    floater:damage(10)
  end

end

function getObject(a, b, name)
  if a.__class.__name == name then
    return a
  elseif b.__class.__name == name then
    return b
  end
  return false
end

function setWorldCallbacks()
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

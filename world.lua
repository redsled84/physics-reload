inspect = require "inspect"
world = love.physics.newWorld(0, 650, true)

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

  if player then
    if math.abs(x) == 1 then
      player.xVelocity = 0
    end
    if y == 1 then
      player.onGround = true
    end
  end

  if bullet then
    print (true)
    bullet.body:destroy()
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

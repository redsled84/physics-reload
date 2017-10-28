inspect = require "libs.inspect"
-- love.physics.setMeter(1)
world = love.physics.newWorld(0, 1050, true)

local function beginContact(a, b, coll)

end

local function endContact(a, b, coll)
  
end

local function preSolve(a, b, coll)
end

local hitMarkerSound = love.audio.newSource("audio/hit_marker_cut.mp3", "static")
local goldPickupSound = love.audio.newSource("audio/gold_pickup.wav", "static")
goldPickupSound:setVolume(.25)
local function postSolve(a, b, coll, normalimpulse, tangentimpulse)
  local obj1, obj2 = a:getUserData(), b:getUserData()
  local x, y = coll:getNormal()

  local player = getObject(obj1, obj2, "Player")
  local bullet = getObject(obj1, obj2, "Bullet")
  local floater = getObject(obj1, obj2, "Floater")
  local walker = getObject(obj1, obj2, "Walker")
  local health = getObject(obj1, obj2, "Health")
  local gold = getObject(obj1, obj2, "Gold")

  if player then
    if math.abs(x) == 1 and not player.onGround and not bullet and not health and not gold then
      player.xVelocity = 0
    end
    if y ~= 0 and not health and not bullet and not gold then
      player.onGround = true

      -- player.xVelocity = player.xVelocity * math.abs(y)
    end

    player:setNormal({x, y})

    if bullet then
      player:damage(bullet.damage)
    end

    if walker then
      player:damageByImpulse(x, y, walker.hitAttackPower)
    end

    if health then
      player:addHealth(health:getHealth())
      health:destroy()
    end

    if gold then
      player:addGold(gold:getValue())
      gold:destroy()
      playSound(goldPickupSound)
    end
  end

  if bullet then
    bullet:destroy()
  end

  if floater and bullet and not floater.body:isDestroyed() then
    floater:damage(bullet.damage)
  end

  if floater and player then
    player:damageByImpulse(-x, -y, floater.attackPower)
  end

  if walker and not walker.body:isDestroyed() then
    if x > 0 then
      walker.dir = 1
      walker.xVelocity = 0
    elseif x < 0 then
      walker.dir = -1
      walker.xVelocity = 0
    end
    if bullet then
      walker:damage(bullet.damage)
      playSound(hitMarkerSound)
    end
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

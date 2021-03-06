inspect = require "libs.inspect"
-- love.physics.setMeter(1)
world = love.physics.newWorld(0, 1050, true)
-- world = love.physics.newWorld(0, 400, true)

local hurtSound = love.audio.newSource("audio/steve_hurt.mp3", "static")
local hitMarkerSound = love.audio.newSource("audio/hit_marker_cut.mp3", "static")
local goldPickupSound = love.audio.newSource("audio/gold_pickup.wav", "static")
hurtSound:setVolume(.15)
hitMarkerSound:setVolume(.4)
goldPickupSound:setVolume(.20)

local function beginContact(a, b, coll)

end

local function endContact(a, b, coll)
  local obj1, obj2 = a:getUserData(), b:getUserData()
  local x, y = coll:getNormal()
  local player = getObject(obj1, obj2, "Player")
  if player then
    player.onGround = false
  end

end

local function preSolve(a, b, coll)
  local obj1, obj2 = a:getUserData(), b:getUserData()
  local x, y = coll:getNormal()

  local player = getObject(obj1, obj2, "Player")
  if player and y ~= 0 then
    player.onGround = true
  end
end


local function postSolve(a, b, coll, normalimpulse, tangentimpulse)
  local obj1, obj2 = a:getUserData(), b:getUserData()
  local x, y = coll:getNormal()

  local player = getObject(obj1, obj2, "Player")
  local bullet = getObject(obj1, obj2, "Bullet")
  local floater = getObject(obj1, obj2, "Floater")
  local walker = getObject(obj1, obj2, "Walker")
  local health = getObject(obj1, obj2, "Health")
  local gold = getObject(obj1, obj2, "Gold")
  local spike = getObject(obj1, obj2, "Spike")
  local bounce = getObject(obj1, obj2, "Bounce")
  local turret = getObject(obj1, obj2, "Turret")

  if player then
    -- print (player.onGround, os.time())
    if math.abs(x) == 1 and not player.onGround and not bullet and not health and not gold then
      player.xVelocity = 0
    end

    if math.abs(x) == 1 and math.abs(y) == 1 then
      player.body:applyLinearImpulse(0, 10)
    end

    player:setNormal({x, y})

    if player.health > 0 then
      if bullet then
        player:damage(bullet.damage)
        playSound(hurtSound)
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

      if floater then
        player:damageByImpulse(-x*10, -y*4, floater.attackPower)
        playSound(hurtSound)
      end

      if spike then
        player:damageByImpulse(math.random(-100, 100) / 100, y, spike.attackPower)
      end

      if bounce then
        if bounce.body:getY() < player.body:getY() and y > 0 then
          player.body:applyLinearImpulse(x, -y * bounce.bouncePower * player.body:getMass() / 1.5)
        else
          player.body:applyLinearImpulse(x, y * bounce.bouncePower * player.body:getMass() / 1.5)
        end
      end

      if walker then
        local signX
        player:damageByImpulse(walker.dir*x, y, walker.hitAttackPower)
        playSound(hurtSound)
      end
    end
  end

  if bullet then
    bullet:destroy()
  end

  if floater and bullet and not floater.body:isDestroyed() then
    floater:damage(bullet.damage)
  end

  if walker and not walker.body:isDestroyed() then
    if bullet then
      walker:damage(bullet.damage)
      playSound(hitMarkerSound)
    else
      if x > 0 then
        walker.dir = 1
        walker.xVelocity = 0
      elseif x < 0 then
        walker.dir = -1
        walker.xVelocity = 0
      end
    end

    if spike then
      walker.health = 0
    end
  end

  if turret and not turret.body:isDestroyed() then
    if bullet then
      turret:damage(bullet.damage)
      playSound(hitMarkerSound)

    end
  end

  if gold and spike then
    gold:destroy()
  end

  if health and spike then
    health:destroy()
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

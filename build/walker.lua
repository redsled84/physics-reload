local sqrt
sqrt = math.sqrt
local collisionMasks = require("build.collisionMasks")
local Entity = require("build.entity")
local Gold = require("build.gold")
local Weapon = require("build.weapon")
local graphics, audio
do
  local _obj_0 = love
  graphics, audio = _obj_0.graphics, _obj_0.audio
end
local hitAttackPowers
hitAttackPowers = {
  80,
  50,
  50,
  50,
  30,
  30,
  30,
  30,
  30,
  30
}
local Walker
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    damage = function(self, attack)
      self.health = self.health - attack
    end,
    move = function(self, dt)
      local buffer
      buffer = 3
      if self.originalDir == 1 then
        if self.body:getX() - self.width / 2 - buffer <= self.originX then
          self.dir = 1
          self.xVelocity = 10
        elseif self.body:getX() + self.width / 2 + buffer >= self.endX then
          self.dir = -1
          self.xVelocity = -10
        end
      else
        if self.body:getX() + self.width / 2 + buffer >= self.originX then
          self.dir = -1
          self.xVelocity = -10
        elseif self.body:getX() - self.width / 2 - buffer <= self.endX then
          self.dir = 1
          self.xVelocity = 10
        end
      end
      self.xVelocity = self.xVelocity + (self.dir * self.moveSpeed * dt)
      local vy
      local _
      _, vy = self.body:getLinearVelocity()
      self.body:setLinearVelocity(self.xVelocity, vy)
      self.touchingWall = false
    end,
    shootWeapon = function(self, dt, targetX, targetY)
      self.weapon.x, self.weapon.y = self.body:getX(), self.body:getY() - self.height / 4
      if self.awarenessDistance >= sqrt((targetX - self.weapon.x) ^ 2 + (targetY - self.weapon.y) ^ 2) then
        self.weapon:autoRemoveDestroyedBullets()
        self.weapon:shootAuto(targetX, targetY)
        return self.weapon:updateRateOfFire(dt)
      end
    end,
    updateGold = function(self)
      if #self.gold > 0 then
        for i = self.nGold, 1, -1 do
          if self.gold[i].body:isDestroyed() then
            table.remove(self.gold, i)
            self.nGold = self.nGold - 1
          end
        end
      end
    end,
    update = function(self, dt, targetX, targetY)
      if not self.body:isDestroyed() then
        self:move(dt)
        if self.health <= 0 then
          for i = 1, self.nGold do
            self.gold[#self.gold + 1] = Gold(math.floor(self.body:getX()), math.floor(self.body:getY()))
          end
          self:destroy()
          return 
        end
        self:shootWeapon(dt, targetX, targetY)
      end
      return self:updateGold()
    end,
    drawGold = function(self)
      if #self.gold > 0 then
        for i = 1, #self.gold do
          self.gold[i]:draw()
        end
      end
    end,
    draw = function(self)
      if not self.body:isDestroyed() then
        local drawX, drawY
        drawX = self.body:getX() - self.width / 2
        drawY = self.body:getY() - self.height / 2
        graphics.setColor(45, 25, 20, 225)
        graphics.rectangle("fill", drawX, drawY, self.width, self.height)
        graphics.setColor(190, 85, 35, 250)
        local offset
        offset = 7
        graphics.rectangle("fill", drawX + offset, drawY + offset, self.width - offset * 2, self.height - offset * 2)
      end
      self:drawGold()
      return self.weapon:drawBullets()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, originX, originY, endX, endY, awarenessDistance, width, height)
      if awarenessDistance == nil then
        awarenessDistance = 750
      end
      if width == nil then
        width = 32
      end
      if height == nil then
        height = 64
      end
      self.originX, self.originY, self.endX, self.endY, self.awarenessDistance, self.width, self.height = originX, originY, endX, endY, awarenessDistance, width, height
      _class_0.__parent.__init(self, self.originX, self.originY, {
        self.width,
        self.height
      }, "dynamic")
      self.originalDir = self.originX > self.endX and -1 or 1
      self.dir = self.originalDir
      self.body:setFixedRotation(true)
      self.fixture:setFilterData(collisionMasks.walker, collisionMasks.solid + collisionMasks.bulletHurtEnemy + collisionMasks.player, 0)
      self.xVelocity = 0
      self.moveSpeed = 200
      self.health = 45
      self.weapon = Weapon(self.x, self.y, math.huge, math.pi / 38, false, .45, 3000, 9, 7, 16)
      self.hitAttackPower = hitAttackPowers[math.random(1, #hitAttackPowers)]
    end,
    __base = _base_0,
    __name = "Walker",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Walker = _class_0
end
return Walker

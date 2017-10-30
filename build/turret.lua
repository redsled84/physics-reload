local sqrt
sqrt = math.sqrt
local collisionMasks = require("build.collisionMasks")
local Entity = require("build.entity")
local Weapon = require("build.weapon")
local Gold = require("build.gold")
local getSign
getSign = function()
  return math.random(0, 1) == 0 and -1 or 1
end
local Turret
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    damage = function(self, attackPower)
      self.health = self.health - attackPower
    end,
    shootWeapon = function(self, dt, targetX, targetY)
      self.weapon.x, self.weapon.y = self.body:getX(), self.body:getY()
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
    update = function(self, dt, player)
      if not self.body:isDestroyed() then
        if self.health <= 0 then
          for i = 1, self.nGold do
            self.gold[#self.gold + 1] = Gold(math.floor(self.body:getX()), math.floor(self.body:getY()), nil, nil, nil, getSign() * math.random(5, 10), 0)
          end
          self:destroy()
          return 
        end
        self:shootWeapon(dt, player.body:getX(), player.body:getY())
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
        _class_0.__parent.__base.draw(self, {
          144,
          65,
          180
        })
      end
      return self.weapon:drawBullets({
        0,
        0,
        0
      })
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, width, height, attackPower)
      if width == nil then
        width = 32
      end
      if height == nil then
        height = 32
      end
      if attackPower == nil then
        attackPower = math.random(10, 15)
      end
      self.x, self.y, self.width, self.height, self.attackPower = x, y, width, height, attackPower
      _class_0.__parent.__init(self, self.x + self.width / 2, self.y + self.height / 2, {
        self.width,
        self.height
      }, "static", "rectangle")
      self.fixture:setFilterData(collisionMasks.turret, collisionMasks.solid + collisionMasks.bulletHurtEnemy + collisionMasks.player, 0)
      self.awarenessDistance = 650
      self.weapon = Weapon(self.x, self.y, math.huge, math.pi / 90, false, 1, 3500, 8, 4, 8)
      self.health = math.random(25, 30)
    end,
    __base = _base_0,
    __name = "Turret",
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
  Turret = _class_0
end
return Turret

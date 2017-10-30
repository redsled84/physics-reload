local Pistol = require("build.pistol")
local Shotgun = require("build.shotgun")
local AssaultRifle = require("build.assaultRifle")
local HeavyRifle = require("build.heavyRifle")
local width, height, buffer
width = love.graphics.getWidth() * (1 / 6)
height = love.graphics.getHeight() * (1 / 2)
buffer = 120
local Phone
do
  local _class_0
  local _base_0 = {
    x = love.graphics.getWidth() - width - buffer * 1.25,
    y = love.graphics.getHeight() - height - buffer * .5,
    width = width,
    height = height,
    sound = love.audio.newSource("audio/bought_cut.mp3", "static"),
    items = {
      Pistol,
      Shotgun,
      AssaultRifle,
      HeavyRifle
    },
    costs = {
      0,
      50,
      100,
      250
    },
    buyRecords = {
      false,
      false,
      false,
      false
    },
    draw = function(self)
      love.graphics.setColor(0, 255, 255, 180)
      love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
      love.graphics.rectangle("fill", self.x - 60, self.y, 60, self.height)
      love.graphics.setColor(0, 0, 0, 180)
      love.graphics.rectangle("fill", self.x + self.width, self.y, 130, self.height)
      local className, itemBuffer, itemWidth, itemHeight
      itemBuffer = 14
      itemWidth = width - itemBuffer * 2
      itemHeight = height / #self.items - itemBuffer * 2
      for i = 1, #self.items do
        local itemX, itemY
        itemX, itemY = self.x + itemBuffer, itemBuffer + self.y + itemBuffer * 2 * (i - 1)
        itemY = itemY + (itemHeight * (i - 1))
        className = self.items[i].__class.__name
        love.graphics.setColor(20, 20, 20, 200)
        love.graphics.rectangle("fill", itemX, itemY, itemWidth, itemHeight)
        love.graphics.setColor(255, 255, 255)
        if className == "Pistol" then
          love.graphics.print("pistol", itemX + itemWidth / 3.5, itemY + itemHeight * (1 / 4))
        end
        if className == "Shotgun" then
          love.graphics.print("shotgun", itemX + itemWidth / 5, itemY + itemHeight * (1 / 4))
        end
        if className == "AssaultRifle" then
          love.graphics.print("assault rifle", itemX + 10, itemY + itemHeight * (1 / 4))
        end
        if className == "HeavyRifle" then
          love.graphics.print("heavy rifle", itemX + 10, itemY + itemHeight * (1 / 4))
        end
        love.graphics.setColor(255, 255, 0)
        love.graphics.print(tostring(self.costs[i]), itemX + itemWidth + 35, itemY + itemHeight * (1 / 3))
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(i, itemX - 40, itemY + itemHeight * (1 / 3))
      end
    end,
    buy = function(self, key, player)
      for i = 1, #self.items do
        if key == tostring(i) then
          local bought
          if not self.buyRecords[i] then
            bought = player:removeGold(self.costs[i])
            if bought then
              self.buyRecords[i] = true
              player:changeWeapon(self.items[i](player.body:getX(), player.body:getY()))
              self.sound:setVolume(.3)
              playSound(self.sound)
            else
              print("not enough money to buy [" .. self.items[i].__class.__name .. "]")
            end
          else
            player:changeWeapon(self.items[i](player.body:getX(), player.body:getY()))
          end
        end
      end
    end,
    resetBuyList = function(self)
      for i = 1, #self.buyRecords do
        self.buyRecords[i] = false
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Phone"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Phone = _class_0
end
return Phone

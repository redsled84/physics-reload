
Pistol = require "build.pistol"
Shotgun = require "build.shotgun"
AssaultRifle = require "build.assaultRifle"
HeavyRifle = require "build.heavyRifle"

local width, height, buffer
width = love.graphics.getWidth! * (1/6)
height = love.graphics.getHeight! * (1/2)
buffer = 120

class Phone
  x: love.graphics.getWidth! - width - buffer * 1.25
  y: love.graphics.getHeight! - height - buffer
  width: width
  height: height
  sound: love.audio.newSource "audio/bought_cut.mp3", "static"
  items: {
    -- LaserSight
    Pistol
    Shotgun
    AssaultRifle
    HeavyRifle
  }
  costs: {
    0
    100
    300
    500
  }
  buyRecords: {
    false
    false
    false
    false
  }
  lastBoughtItem: false

  draw: =>
    love.graphics.setColor 0, 255, 255, 180
    love.graphics.rectangle "fill", @x, @y, @width, @height
    love.graphics.rectangle "fill", @x-60, @y, 60, @height
    love.graphics.setColor 0, 0, 0, 180
    love.graphics.rectangle "fill", @x+@width, @y, 130, @height

    local className, itemBuffer, itemWidth, itemHeight
    itemBuffer = 14
    itemWidth = width - itemBuffer * 2
    itemHeight = height / #@items - itemBuffer * 2
    for i = 1, #@items
      local itemX, itemY
      itemX, itemY = @x + itemBuffer, itemBuffer + @y + itemBuffer * 2 * (i - 1)
      itemY += itemHeight * (i-1)
      className = @items[i].__class.__name

      -- 
      love.graphics.setColor 20, 20, 20, 200
      love.graphics.rectangle "fill", itemX, itemY, itemWidth, itemHeight

      -- item text
      love.graphics.setColor 255, 255, 255
      if className == "Pistol"
        love.graphics.print "pistol", itemX + itemWidth / 3.5, itemY + itemHeight * (1/4)
      if className == "Shotgun"
        love.graphics.print "shotgun", itemX + itemWidth / 5, itemY + itemHeight * (1/4)
      if className == "AssaultRifle"
        love.graphics.print "assault rifle", itemX + 10, itemY + itemHeight * (1/4)
      if className == "HeavyRifle"
        love.graphics.print "heavy rifle", itemX + 10, itemY + itemHeight * (1/4)

      -- cost of item  
      love.graphics.setColor 255, 255, 0
      love.graphics.print tostring(@costs[i]), itemX + itemWidth + 35, itemY + itemHeight * (1/3)

      if @lastBoughtItem
        if @lastBoughtItem.__class.__name == className
          love.graphics.setColor 20, 20, 20, 200
          love.graphics.rectangle "fill", itemX - 50, itemY+itemHeight * (1/3) - 15, 35, 50
      love.graphics.setColor 255, 255, 255
      love.graphics.print i, itemX-40, itemY+itemHeight * (1/3)

  buy: (key, player) =>
    for i = 1, #@items
      if key == tostring i
        local bought
        if not @buyRecords[i]
          bought = player\removeGold @costs[i]
          local weapon
          if bought
            @buyRecords[i] = true
            weapon = @items[i](player.body\getX!, player.body\getY!)
            @lastBoughtItem = weapon
            player\changeWeapon weapon
            @sound\setVolume .45
            playSound @sound
          else
            print "not enough money to buy [" .. @items[i].__class.__name .. "]"
        else
          weapon = @items[i](player.body\getX!, player.body\getY!)
          @lastBoughtItem = weapon
          player\changeWeapon weapon

  resetBuyList: =>
    for i = 1, #@buyRecords
      @buyRecords[i] = false

return Phone
Weapon = require "build.weapon"

class Shotgun extends Weapon
  new: (@x, @y) =>
    super @x, @y, 1000, math.pi / 8, true, .85, 1950, 7, 10, 19, 8.5
    @fireControl = "semi"
    @shotPerRound = 8
    @loadSound = love.audio.newSource "audio/shotgun_pump.mp3", "static"
    @loadSound\setVolume .2
    @playOnce = 0
  shootSemi: (x, y, button) =>
    if button == 1 and @canShoot and @ammoCount > 0 and @fireControl == "semi"
      for i = 1, @shotPerRound
        @shootBullet x, y
      @playOnce = 0
  update: (dt, cam, player) =>
    super dt, cam, player
    if @rateOfFireTimer.time > @rateOfFireTimer.max *  .3 and @playOnce < 1
      playSound @loadSound
      @playOnce += 1
  drawBullets: =>
    super {255, 0, 255}

return Shotgun
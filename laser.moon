Entity = require "build.entity"
class Laser extends Entity
  new: (@originX, @originY, @endX, @endY, @attackPower=math.random(600, 650)) =>
    super @originX, @originY, {@endX, @endY}, "static", "segment"
    @laserSound = love.audio.newSource "audio/laser.wav", "static"
    @laserSound\setVolume .08

  update: (dt, player) =>
    local xn, yn, fraction
    xn, yn, fraction = player.shape\rayCast @originX, @originY, @endX, @endY, 1, player.body\getX!, player.body\getY!, 0
    if xn and yn and player.health > 0
      player\removeHealth @attackPower * dt
      playSound @laserSound

  draw: (ox, oy, ex, ey) =>
    if not ox and not oy
      love.graphics.setColor 255, 0, 0
      love.graphics.line @originX, @originY, @endX, @endY
    else
      love.graphics.setColor 255, 0, 0
      love.graphics.line ox, oy, ex, ey

return Laser
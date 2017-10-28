class Laser
  new: (@originX, @originY, @endX, @endY, @attackPower=math.random(600, 650)) =>
    @body = {
      isDestroyed: ->
        return false
    }
    @laserSound = love.audio.newSource "audio/laser.wav", "static"
    @laserSound\setVolume .5

  update: (dt, player) =>
    local xn, yn, fraction, dist
    dist = math.sqrt((@originX - @endX)^2 + (@originY - @endY)^2)
    xn, yn, fraction = player.shape\rayCast @originX, @originY, @endX, @endY, dist, player.body\getX!, player.body\getY!, 0
    if xn and yn
      player\removeHealth @attackPower * dt
      playSound @laserSound
  draw: =>
    love.graphics.setColor 255, 0, 0
    love.graphics.line @originX, @originY, @endX, @endY
return Laser
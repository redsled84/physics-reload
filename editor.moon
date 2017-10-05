inspect = require "inspect"
Camera = require "camera"
require "utils"

class Editor
  cam: Camera love.graphics.getWidth! / 2, love.graphics.getHeight! / 2
  cameraSpeed: 300

  activeClickerRadius: 8
  activeDeleteIndex: -1
  activeRadius: 0
  activeShape: false
  activeVertices: {}
  activeX: love.mouse.getX!
  activeY: love.mouse.getY!
  selectedShape: -1

  data: {}
  shapes: {}
  wantToLoad: false

  gridSize: 32
  gridWidth: 30
  gridHeight: 60
  viewControls: false

  -- colors
  hovered: {230, 140, 0}
  normal: {0, 0, 190}
  selected: {160, 25, 230}

  loadSavedFile: (filename) =>
    if @wantToLoad
      @data = not love.filesystem.exists(filename) and table.load(filename) or {}
      local n
      if #@data > 0 then
        n = #@data[1]
        for i = 1, #@data
          @shapes[#@shapes+1] = love.physics.newPolygonShape @data[i].vertices
          print "new polygon: ", inspect @data[i].vertices
        

  vec2: (x, y) =>
    return {x: x, y: y}

  verticesList: =>
    result = {}

    for i = #@activeVertices, 1, -1
      vec = @activeVertices[i]
      table.insert result, vec.x
      table.insert result, vec.y

    return result

  drawPolygon: (vertices) =>
    love.graphics.setColor 210, 150, 175, 120
    love.graphics.polygon "fill", unpack vertices
    love.graphics.setColor 210, 150, 175, 255
    love.graphics.polygon "line", unpack vertices
    love.graphics.polygon "line", unpack vertices

  drawOutlinedPolygon: (color1, color2, vertices) =>
    if color2 == nil
      color2 = color1

    love.graphics.setColor color1[1], color1[2], color1[3], 65
    love.graphics.polygon "fill", vertices
    love.graphics.setColor color2[1], color2[2], color2[3], 255
    love.graphics.polygon "line", vertices

  drawCircle: (x, y, radius) =>
    love.graphics.setColor 190, 230, 185, 120
    love.graphics.circle "fill", x, y, radius
    love.graphics.setColor 190, 230, 185, 255
    love.graphics.circle "line", x, y, radius
    love.graphics.circle "line", x, y, radius

  draw: =>
    @cam\attach!

    @activeShape = false
    @activeDeleteIndex = -1

    -- drawing polygons
    local shape, x, y
    x, y = @activeX, @activeY
    for i=#@shapes, 1, -1
      shape = @shapes[i]
      if shape\testPoint(0, 0, 0, x, y) and @selectedShape ~= i then
        @activeDeleteIndex = i
        @activeShape = true
        @drawOutlinedPolygon(@hovered, nil, table.flatten(@data[i].vertices))
      elseif @selectedShape == i then
        @drawOutlinedPolygon(@selected, nil, table.flatten(@data[selectedShape].vertices))
      else
        @drawOutlinedPolygon(@normal, nil, table.flatten(@data[i].vertices))

    -- draw the cursor
    love.graphics.circle "line", @activeX, @activeY, @activeClickerRadius

    -- draw the grid dots
    love.graphics.setColor(10, 10, 10, 85)
    for x = 0, @gridSize * @gridWidth, @gridSize
      for y = 0, @gridSize * @gridHeight, @gridSize
        love.graphics.circle("line", x, y, 3)

return Editor
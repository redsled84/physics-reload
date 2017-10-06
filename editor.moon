inspect = require "inspect"
Camera = require "camera"
Entity = require "entity"
require "utils"

class Editor
  cam: Camera love.graphics.getWidth! / 2, love.graphics.getHeight! / 2
  cameraSpeed: 300
  cameraScale: 1

  activeClickerRadius: 8
  activeDeleteIndex: -1
  activeRadius: 0
  activeShape: false
  activeShapeType: "polygon"
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
  verticeRadius: 9

  entities: {}

  addEntites: =>
    local target, entity
    for i = 1, #@data
      target = @data[i]
      if target.shapeType == "polygon"
        entity = Entity 0, 0,
          @data[target.vertices[1]], "static", "polygon"
        
        @entities[#@entities+1] = entity

  loadSavedFile: (filename) =>
    if @wantToLoad
      @data = not love.filesystem.exists(filename) and table.load(filename) or {}
      local n
      if #@data > 0 then
        n = #@data[1]
        for i = 1, #@data
          @shapes[#@shapes+1] = love.physics.newPolygonShape @data[i].vertices
          print "new polygon: ", inspect @data[i].vertices
        
        @addEntites!

  hotLoad: =>
    local target, entity
    for i = 1, #@data
      target = @data[i]
      if target.shapeType == "polygon" and not target.added
        target.added = true
        entity = Entity 0, 0, target.vertices, "static", "polygon"
        @entities[#@entities+1] = entity

  vec2: (x, y) =>
    return {x: x, y: y}

  verticesList: =>
    result = {}

    for i = #@activeVertices, 1, -1
      vec = @activeVertices[i]
      table.insert result, vec.x
      table.insert result, vec.y

    return result

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

  drawShapes: =>    
    @activeShape = false
    @activeDeleteIndex = -1

    -- drawing polygons
    local shape, x, y, tf
    tf = table.flatten
    x, y = @activeX, @activeY
    for i=#@shapes, 1, -1
      shape = @shapes[i]
      if shape\testPoint(0, 0, 0, x, y) and @selectedShape ~= i then
        @activeDeleteIndex = i
        @activeShape = true
        @drawOutlinedPolygon(@hovered, nil, tf(@data[i].vertices))
      elseif @selectedShape == i then
        @drawOutlinedPolygon(@selected, nil, tf(@data[@selectedShape].vertices))
      else
        @drawOutlinedPolygon(@normal, nil, tf(@data[i].vertices))

  drawCursor: =>
    love.graphics.circle "line", @activeX, @activeY, @activeClickerRadius

  drawGrid: =>
    -- draw the grid dots
    love.graphics.setColor(10, 10, 10, 85)
    -- Possible optimization is to keep a grid only locked onto the camera
    -- local drawX, drawY
    -- drawX = @activeX - love.graphics.getWidth! / gridSize +
    --   gridSize - (love.graphics.getWidth! % gridSize)
    -- drawY = @activeY - love.graphics.getHeight! / gridSize +
    --   gridSize - (love.graphics.getHeight! % gridSize)
    -- for x = @cam.x, , @gridSize
    --   for y = @cam.y, love.graphics, @gridSize
    --     love.graphics.circle("line", x, y, 3)
    for x = 0, @gridSize * @gridWidth, @gridSize
      for y = 0, @gridSize * @gridHeight, @gridSize
        love.graphics.circle "line", x, y, 3

  drawActiveVertices: =>
    love.graphics.setColor(0, 0, 0, 255)
    if #@activeVertices > 2
      for i = #@activeVertices, 1, -1
        local current, nextOne, vec
        vec = @activeVertices[i]
        if i + 1 > #@activeVertices
          current = vec
          nextOne = @activeVertices[1]
        else
          current = vec
          nextOne = @activeVertices[i + 1]

        if current and nextOne
          love.graphics.line current.x, current.y, nextOne.x, nextOne.y

    elseif #@activeVertices == 2
      love.graphics.line @activeVertices[1].x, @activeVertices[1].y,
        @activeVertices[#@activeVertices].x, @activeVertices[#@activeVertices].y

    for i = #@activeVertices, 1, -1
      love.graphics.setColor 0, 235, 80, 130
      love.graphics.circle "fill", @activeVertices[i].x, @activeVertices[i].y,
        @verticeRadius
      love.graphics.setColor 0, 235, 80, 245
      love.graphics.circle "line", @activeVertices[i].x, @activeVertices[i].y,
        @verticeRadius

  drawControls: =>
    if @viewControls
      love.graphics.setColor 0, 0, 0, 155
      love.graphics.rectangle "fill", 0, 0, 930, 250
      love.graphics.setColor 255, 255, 255
      love.graphics.print "Press 'W A S D' to move the camera around \n" ..
      "Press 'q' to zoom out and 'e' to zoom in \n" ..
      "Press 'c' to increase camera speed and 'z' to decrease camera speed \n" ..
      "Press LEFT CLICK to add polygon point \n" ..
      "Press 'space' to add a polygon to the level \n" ..
      "Press RIGHT CLICK to select a polygon \n" ..
      "Press 'r' remove the last placed point, or a selected polygon \n" ..
      "Press 'm' to minimize this box", 15, 15
    else
      love.graphics.setColor 0, 0, 0, 155
      love.graphics.rectangle "fill", 0, 0, 475, 48
      love.graphics.setColor 255, 255, 255
      love.graphics.print "Press 'm' to open the controls list", 15, 15

  draw: =>
    @cam\attach!   
   
    @drawGrid!
    @drawShapes!
    @drawActiveVertices!
    @drawCursor!

    @cam\detach!

    @drawControls!

  clickerTheta: 0
  clickerThetaStep: math.pi / 2
  minClickerRadius: 8
  speedControlFactor: 500
  maxCameraSpeed: 1200
  scaleControlFactor: 1
  minScale: .5
  maxScale: 2

  manipulateCursorRadius: (dt) =>
    -- Cursor radius manipulation
    @activeClickerRadius = math.abs(@minClickerRadius * math.sin @clickerTheta) + @minClickerRadius
    -- Ensure theta doesn't go past 2pi
    @clickerTheta = @clickerTheta + @clickerThetaStep * dt < math.pi * 2 and
      @clickerTheta + @clickerThetaStep * dt or math.pi * 2
    -- Ensure if theta is greater or equal to 2pi then it gets assigned to zero
    @clickerTheta = @clickerTheta >= math.pi * 2 and 0 or @clickerTheta

  gridLockCursor: =>
    -- Translating cursor to become grid-locked
    local x, y, xr, yr
    x, y = @cam\worldCoords love.mouse.getX!, love.mouse.getY!
    xr, yr = (x % @gridSize), (y % @gridSize)
    @activeX = xr >= @gridSize / 2 and x - xr + @gridSize or x - xr
    @activeY = yr >= @gridSize / 2 and y - yr + @gridSize or y - yr

  moveCamera: (dt) =>
    if love.keyboard.isDown "d"
      @cam.x += @cameraSpeed * dt
    elseif love.keyboard.isDown "a"
      @cam.x -= @cameraSpeed * dt

    if love.keyboard.isDown "w"
      @cam.y -= @cameraSpeed * dt
    elseif love.keyboard.isDown "s"
      @cam.y += @cameraSpeed * dt

  controlCameraAttributes: (dt) =>
    -- Camera speed control
    if love.keyboard.isDown "z"
      @cameraSpeed = @cameraSpeed - @speedControlFactor * dt > 100 and
        @cameraSpeed - @speedControlFactor * dt or 100
    elseif love.keyboard.isDown "c"
      @cameraSpeed = @cameraSpeed + @speedControlFactor * dt < @maxCameraSpeed and
        @cameraSpeed + @speedControlFactor * dt or @maxCameraSpeed

    -- Camera scale control
    if love.keyboard.isDown "q"
      @cameraScale = @cameraScale - @scaleControlFactor * dt > @minScaleFactor and
        @cameraScale - @scaleControlFactor * dt or @minScale
    elseif love.keyboard.isDown "e"
      @cameraScale = @cameraScale + @scaleControlFactor * dt < @maxScale and
        @cameraScale + @scaleControlFactor * dt or @maxScale

  update: (dt) =>
    @cam\zoomTo @cameraScale
    -- Ensure camera coordinates are integars
    @cam\lookAt math.ceil(@cam.x), math.ceil(@cam.y)

    @manipulateCursorRadius dt
    @gridLockCursor!
    @moveCamera dt
    @controlCameraAttributes dt

  mousepressed: (x, y, button) =>
    local found
    if button == 1
      -- Add a vertice to the active vertices table
      if @activeShapeType == "polygon"
        found = false
        for i = 1, #@activeVertices
          if @activeVertices[i].x == @activeX and @activeVertices[i].y == @activeY
            found = true

        if not found
          table.insert @activeVertices, @vec2(@activeX, @activeY)
        else
          print "there is already a vertice at that coordinate"
    if button == 2
      -- Select a shape      
      if @activeShapeType == "polygon"
        @selectedShape = -1
        if @activeShape
          @selectedShape = @activeDeleteIndex

  keypressed: (key) =>
    if key == "r"
      if #@activeVertices > 0
        table.remove @activeVertices, #@activeVertices
      if @selectedShape > 0
        table.remove @data, @selectedShape
        table.remove @shapes, @selectedShape
        @selectedShape = -1

    if key == "space"
      local object, targetX, targetY
      targetX, targetY = @cam\worldCoords @activeX, @activeY
      if @activeShapeType == "polygon"
        @shapes[#@shapes+1] = love.physics.newPolygonShape @verticesList @activeVertices 
        print "new polygon: ", inspect @verticesList @activeVertices
        table.insert @data, {
          vertices: @verticesList(@activeVertices),
          shapeType: @activeShapeType,
          added: false
        }
        for i = #@activeVertices, 1, -1
          table.remove @activeVertices, i

    if key == "m"
      @viewControls = not @viewControls

return Editor
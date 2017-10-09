import insert, remove from table
import len from string
import abs, ceil, floor, sin from math

inspect = require "inspect"
Camera = require "camera"
Entity = require "entity"
require "utils"

{graphics: graphics, mouse: mouse, physics: physics, filesystem: filesystem, keyboard: keyboard} = love

class Editor
  cam: Camera graphics.getWidth! / 2, graphics.getHeight! / 2
  cameraSpeed: 300
  cameraScale: 1

  activeClickerRadius: 8
  activeDeleteIndex: -1
  activeRadius: 0
  activeShape: false
  activeShapeType: "polygon"
  activeVertices: {}
  activeX: mouse.getX!
  activeY: mouse.getY!
  selectedShape: -1

  data: {}
  shapes: {}
  loadedFilename: ""

  gridSize: 32
  gridWidth: graphics.getWidth! / 32
  gridHeight: graphics.getHeight! / 32
  viewControls: false

  -- colors
  hovered: {230, 140, 0}
  normal: {0, 0, 190}
  selected: {160, 25, 230}
  verticeRadius: 9

  entities: {}

  loadSavedFile: (filename) =>
    @data = filesystem.exists(filename) and table.load(filename) or {}
    local n
    if #@data > 0 then
      n = #@data[1]
      for i = 1, #@data
        @shapes[i] = physics.newPolygonShape @data[i].vertices
        print "new polygon: ", inspect @data[i].vertices
      
      @loadedFilename = filename
      @hotLoad!

  hotLoad: =>
    local target, entity
    for i = #@data, 1, -1
      target = @data[i]
      if target.shapeType == "polygon" and not target.added
        target.added = true
        entity = Entity 0, 0, target.vertices, "static", "polygon"
        @entities[i] = entity

  vec2: (x, y) =>
    return {x: x, y: y}

  verticesList: =>
    result = {}

    for i = #@activeVertices, 1, -1
      vec = @activeVertices[i]
      insert result, vec.x
      insert result, vec.y

    return result

  drawOutlinedPolygon: (color1, color2, vertices) =>
    if color2 == nil
      color2 = color1

    graphics.setColor color1[1], color1[2], color1[3], 65
    graphics.polygon "fill", vertices
    graphics.setColor color2[1], color2[2], color2[3], 255
    graphics.polygon "line", vertices

  drawCircle: (x, y, radius) =>
    graphics.setColor 190, 230, 185, 120
    graphics.circle "fill", x, y, radius
    graphics.setColor 190, 230, 185, 255
    graphics.circle "line", x, y, radius
    graphics.circle "line", x, y, radius

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
    graphics.circle "line", @activeX, @activeY, @activeClickerRadius

  drawGrid: =>
    -- draw the grid dots
    graphics.setColor(10, 10, 10, 85)
    -- Possible optimization is to keep a grid only locked onto the camera
    -- local drawX, drawY
    -- drawX = @activeX - graphics.getWidth! / gridSize +
    --   gridSize - (graphics.getWidth! % gridSize)
    -- drawY = @activeY - graphics.getHeight! / gridSize +
    --   gridSize - (graphics.getHeight! % gridSize)
    -- for x = @cam.x, , @gridSize
    --   for y = @cam.y, graphics, @gridSize
    --     graphics.circle("line", x, y, 3)
    local translateX, translateY
    translateX = ceil(@cam.x - graphics.getWidth! / 2) - (@cam.x % @gridSize)
    translateY = ceil(@cam.y - graphics.getHeight! / 2) - (@cam.y % @gridSize) + @gridSize / 4

    for x = 0, @gridSize * @gridWidth, @gridSize
      for y = 0, @gridSize * @gridHeight, @gridSize
        graphics.circle "line", translateX + x, translateY + y, 3

  drawActiveVertices: =>
    graphics.setColor(0, 0, 0, 255)
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
          graphics.line current.x, current.y, nextOne.x, nextOne.y

    elseif #@activeVertices == 2
      graphics.line @activeVertices[1].x, @activeVertices[1].y,
        @activeVertices[#@activeVertices].x, @activeVertices[#@activeVertices].y

    for i = #@activeVertices, 1, -1
      graphics.setColor 0, 235, 80, 130
      graphics.circle "fill", @activeVertices[i].x, @activeVertices[i].y,
        @verticeRadius
      graphics.setColor 0, 235, 80, 245
      graphics.circle "line", @activeVertices[i].x, @activeVertices[i].y,
        @verticeRadius

  drawControls: =>
    if @viewControls
      graphics.setColor 0, 0, 0, 155
      graphics.rectangle "fill", 0, 0, 930, 250
      graphics.setColor 255, 255, 255
      graphics.print "Press 'W A S D' to move the camera around \n" ..
      "Press 'q' to zoom out and 'e' to zoom in \n" ..
      "Press 'c' to increase camera speed and 'z' to decrease camera speed \n" ..
      "Press LEFT CLICK to add polygon point \n" ..
      "Press 'space' to add a polygon to the level \n" ..
      "Press RIGHT CLICK to select a polygon \n" ..
      "Press 'r' remove the last placed point, or a selected polygon \n" ..
      "Press 'm' to minimize this box", 15, 15
    else
      graphics.setColor 0, 0, 0, 155
      graphics.rectangle "fill", 0, 0, 475, 48
      graphics.setColor 255, 255, 255
      graphics.print "Press 'm' to open the controls list", 15, 15

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
    @activeClickerRadius = abs(@minClickerRadius * sin @clickerTheta) + @minClickerRadius
    -- Ensure theta doesn't go past 2pi
    @clickerTheta = @clickerTheta + @clickerThetaStep * dt < math.pi * 2 and
      @clickerTheta + @clickerThetaStep * dt or math.pi * 2
    -- Ensure if theta is greater or equal to 2pi then it gets assigned to zero
    @clickerTheta = @clickerTheta >= math.pi * 2 and 0 or @clickerTheta

  gridLockCursor: =>
    -- Translating cursor to become grid-locked
    local x, y, xr, yr
    x, y = @cam\worldCoords mouse.getX!, mouse.getY!
    xr, yr = (x % @gridSize), (y % @gridSize)
    @activeX = xr >= @gridSize / 2 and x - xr + @gridSize or x - xr
    @activeY = yr >= @gridSize / 2 and y - yr + @gridSize or y - yr

  moveCamera: (dt) =>
    if keyboard.isDown "d"
      @cam.x += @cameraSpeed * dt
    elseif keyboard.isDown "a"
      @cam.x -= 1.5 * @cameraSpeed * dt

    if keyboard.isDown "w"
      @cam.y -= 1.5 * @cameraSpeed * dt
    elseif keyboard.isDown "s"
      @cam.y += @cameraSpeed * dt

  controlCameraAttributes: (dt) =>
    -- Camera speed control
    if keyboard.isDown "z"
      @cameraSpeed = @cameraSpeed - @speedControlFactor * dt > 100 and
        @cameraSpeed - @speedControlFactor * dt or 100
    elseif keyboard.isDown "c"
      @cameraSpeed = @cameraSpeed + @speedControlFactor * dt < @maxCameraSpeed and
        @cameraSpeed + @speedControlFactor * dt or @maxCameraSpeed

    -- Camera scale control
    if keyboard.isDown "q"
      @cameraScale = @cameraScale - @scaleControlFactor * dt > @minScale and
        @cameraScale - @scaleControlFactor * dt or @minScale
    elseif keyboard.isDown "e"
      @cameraScale = @cameraScale + @scaleControlFactor * dt < @maxScale and
        @cameraScale + @scaleControlFactor * dt or @maxScale

  update: (dt) =>
    @cam\zoomTo @cameraScale
    -- Ensure camera coordinates are integars
    @cam\lookAt ceil(@cam.x), ceil(@cam.y)

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
          insert @activeVertices, @vec2(@activeX, @activeY)
        else
          print "there is already a vertice at that coordinate"
    if button == 2
      -- Select a shape      
      if @activeShapeType == "polygon"
        @selectedShape = -1
        if @activeShape
          @selectedShape = @activeDeleteIndex

  recursivelySaveNewFile: (n) =>
    local str
    str = "level" .. n
    if filesystem.exists str .. ".lua"
      @recursivelySaveNewFile n + 1
    else
      table.save @data, "levels/" .. str .. ".lua"
      print "safely saved level data to " .. str .. ".lua"

  saveFile: =>
    if 0 < len @loadedFilename
      table.save @data, @loadedFilename
      print "saved level data to " .. @loadedFilename
    else
      @recursivelySaveNewFile 0

  keypressed: (key) =>
    if key == "r"
      if #@activeVertices > 0
        remove @activeVertices, #@activeVertices
      if @selectedShape > 0
        remove @data, @selectedShape
        remove @shapes, @selectedShape
        @entities[@selectedShape]\destroy!
        remove @entities, @selectedShape

        @selectedShape = -1

    if key == "space"
      if #@activeVertices <= 2
        print "error: not enough active vertices to create a polgon!"
        return

      local object, targetX, targetY
      targetX, targetY = @cam\worldCoords @activeX, @activeY
      if @activeShapeType == "polygon"
        @shapes[#@shapes+1] = physics.newPolygonShape @verticesList @activeVertices 
        print "new polygon: ", inspect @verticesList @activeVertices
        insert @data, {
          vertices: @verticesList(@activeVertices)
          shapeType: @activeShapeType
          added: false
        }
        for i = #@activeVertices, 1, -1
          remove @activeVertices, i

    if key == "m"
      @viewControls = not @viewControls

    if key == "p"
      @saveFile!

return Editor
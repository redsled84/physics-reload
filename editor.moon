import insert, remove from table
import len from string
import abs, ceil, floor, sin from math

inspect = require "libs.inspect"
Camera = require "libs.camera"
Entity = require "build.entity"
Floater = require "build.floater"
Laser = require "build.laser"
Walker = require "build.walker"
Health = require "build.health"

{graphics: graphics, mouse: mouse, physics: physics, filesystem: filesystem, keyboard: keyboard} = love

class Editor
  cam: Camera graphics.getWidth! / 2, graphics.getHeight! / 2
  cameraSpeed: 300
  cameraScale: 1

  activeClickerRadius: 8
  activeDeleteIndex: -1
  activeRadius: 0
  activeShape: false
  activeObject: false
  activeShapeType: "polygon"
  activeVertices: {}
  activeX: mouse.getX!
  activeY: mouse.getY!
  selectedShape: -1
  selectedObject: -1
  selectedMenuItem: Floater

  menuItems: {
    Floater
    Walker
    Health
    Laser
  }
  objectData: {}
  objects: {}
  data: {}
  shapes: {}
  loadedFilename: ""
  tool: "polygon"

  gridSize: 32
  gridWidth: graphics.getWidth! / 32
  gridHeight: graphics.getHeight! / 32
  viewControls: false
  viewObjectMenu: false

  -- colors
  hovered: {230, 140, 0}
  normal: {0, 0, 190}
  selected: {160, 25, 230}
  verticeRadius: 9

  entities: {}

  loadSavedFile: (filename) =>
    local fileData
    fileData = filesystem.exists(filename) and table.load(filename) or {}
    @data = fileData.polygonData
    if #@data > 0
      for i = 1, #@data
        @shapes[i] = physics.newPolygonShape @data[i].vertices
        print "new polygon: ", inspect @data[i].vertices
        if @data[i].object
          @data[i].load!
      @hotLoad!
    @objectData = fileData.objectData
    if #@objectData > 0
      @hotLoadObjects!
    @loadedFilename = filename
    

  hotLoad: =>
    local target, entity
    for i = #@data, 1, -1
      target = @data[i]
      if target.shapeType == "polygon" and not target.added
        target.added = true
        entity = Entity 0, 0, target.vertices, "static", "polygon"
        @entities[i] = entity

    -- @hotLoadObjects!

  hotLoadObjects: =>
    local object
    for i = #@objectData, 1, -1
      object = @objectData[i]
      if object.added == nil
        object.added = false
      if object.objectType == "Floater" and not object.added
        object.added = true
        @objects[i] = Floater object.x, object.y
      if object.objectType == "Walker" and not object.added
        object.added = true
        @objects[i] = Walker object.x, object.y, object.endX, object.endY
      if object.objectType == "Health" and not object.added
        object.added = true
        @objects[i] = Health object.x, object.y
      if object.objectType == "Laser" and not object.added
        object.added = true
        @objects[i] = Laser object.x, object.y, object.endX, object.endY

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
      if shape\testPoint(0, 0, 0, x, y) and @selectedShape ~= i
        @activeDeleteIndex = i
        @activeShape = true
        @drawOutlinedPolygon(@hovered, nil, tf(@data[i].vertices))
      elseif @selectedShape == i
        @drawOutlinedPolygon(@selected, nil, tf(@data[@selectedShape].vertices))
      else
        @drawOutlinedPolygon(@normal, nil, tf(@data[i].vertices))

  drawObjects: =>
    @activeObject = false

    graphics.setColor 255, 255, 255
    for i=#@objects, 1, -1
      obj = @objects[i]
      if @objectData[i].x == @activeX and @objectData[i].y == @activeY and @selectedObject ~= i and not @viewObjectMenu
        @activeDeleteIndex = i
        @activeObject = true

      -- if obj.__class.__name == "Walker"
        -- graphics.setColor 0, 0, 0
        -- graphics.line obj.originX, obj.originY, obj.endX, obj.endY
        -- @drawCircle obj.originX, obj.originY, 8
        -- @drawCircle obj.endX, obj.endY, 8
      obj\draw!

  drawObjectGold: =>
    for i=#@objects, 1, -1
      obj = @objects[i]
      if obj.gold
        if #obj.gold > 0 and obj.body\isDestroyed!
          obj\drawGold!

  drawCursor: =>
    graphics.setColor 10, 10, 10, 255
    graphics.circle "line", @activeX, @activeY, @activeClickerRadius

  drawGrid: =>
    -- draw the grid dots
    graphics.setColor 10, 10, 10, 85
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

  drawMode: =>
    graphics.setColor 0, 0, 0, 155
    graphics.rectangle "fill", 0, graphics.getHeight! - 48, 350, 48
    graphics.setColor 255, 255, 255
    graphics.print "Selected mode: " .. @tool, 15, graphics.getHeight! - 32

  drawControls: =>
    if @viewControls and not @viewObjectMenu
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
      "Press 'm' to minimize this box\n" ..
      "Press '1' to create and destroy polygon shapes\n" ..
      "Press '2' to create and destroy objects\n" .. 
      "Press 'j' to access the object menu", 15, 15
    else
      graphics.setColor 0, 0, 0, 155
      graphics.rectangle "fill", 0, 0, 475, 48
      graphics.setColor 255, 255, 255
      graphics.print "Press 'm' to open the controls list", 15, 15
      @drawMode!

  testPoint: (x1,y1,w1,h1,x2,y2) =>
    return x2 > x1 and x2 < x1 + w1 and y2 > y1 and y2 < y1 + h1

  getWidthRatio: (num, den) =>
    return graphics.getWidth! * num / den

  getHeightRatio: (num, den) =>
    return graphics.getHeight! * num / den

  drawObjectMenu: =>
    -- constants for menu window
    local x, y, w, h, xoffset, yoffset, itemCounter, nItemsWide, nItemsTall, itemWidth, itemHeight, actualWidth, actualHeight
    x, y, w, h = @getWidthRatio(1,8), @getHeightRatio(1,8), @getWidthRatio(3,4), @getHeightRatio(3,4)
    xoffset, yoffset = 10, 10
    nItemsWide, nItemsTall = w/6, h/6
    itemWidth, itemHeight = nItemsWide-xoffset, nItemsTall-yoffset
    actualWidth, actualHeight = itemWidth-xoffset*2, itemHeight-yoffset*2

    if @viewObjectMenu and not @viewControls
      -- draw main window
      graphics.setColor 0, 0, 0, 155
      graphics.rectangle "fill", x-10, y-10, w+10, h+10
      -- draw each placable object
      graphics.setColor 100, 100, 100, 200
      itemCounter = 1
    

      -- nested for loop to get x,y coordinates for menu grid
      -- each loop step considers the width and height of the GUI block 
      local temp, className
      for ox = x+xoffset, x+w-itemWidth, itemWidth+xoffset
        for oy = y+yoffset, y+h-itemHeight, itemHeight+yoffset
          if itemCounter <= #@menuItems
            graphics.setColor 0, 0, 0, 200
            -- check if the mouse is inside this particular menu item
            if @testPoint ox, oy, actualWidth, actualHeight, mouse.getX!, mouse.getY!
              graphics.setColor unpack @hovered
              if mouse.isDown 1
                @selectedMenuItem = @menuItems[itemCounter]
                graphics.setColor unpack @selected
                
            graphics.rectangle "fill", ox, oy, actualWidth, actualHeight

            className = @menuItems[itemCounter].__class.__name
            if className == "Floater" or className == "Health"
              temp = @menuItems[itemCounter] ox, oy
            elseif className == "Walker"
              temp = @menuItems[itemCounter] ox, oy, ox, oy
            elseif className == "Laser"
              temp = @menuItems[itemCounter] ox + actualWidth / 2, oy, ox + actualWidth / 2, oy + actualHeight

            temp\draw ox + actualWidth / 2, oy + actualHeight / 2
              -- elseif .__class.__name == "Walker"
              --   .draw ox+4, oy+4, itemWidth, itemHeight
          itemCounter += 1

  drawObjectOrigin: =>
    local originRadius
    originRadius = 12
    for i = 1, #@objectData
      if @activeObject and @activeDeleteIndex == i
        graphics.setColor @hovered[1], @hovered[2], @hovered[3], 120
        graphics.circle "fill", @objectData[i].x, @objectData[i].y, originRadius
        graphics.setColor @hovered[1], @hovered[2], @hovered[3], 255
        graphics.circle "line", @objectData[i].x, @objectData[i].y, originRadius
      elseif @selectedObject == i
        graphics.setColor @selected[1], @selected[2], @selected[3], 120
        graphics.circle "fill", @objectData[i].x, @objectData[i].y, originRadius
        graphics.setColor @selected[1], @selected[2], @selected[3], 255
        graphics.circle "line", @objectData[i].x, @objectData[i].y, originRadius
      else
        graphics.setColor @normal[1], @normal[2], @normal[3], 120
        graphics.circle "fill", @objectData[i].x, @objectData[i].y, originRadius
        graphics.setColor @normal[1], @normal[2], @normal[3], 255
        graphics.circle "line", @objectData[i].x, @objectData[i].y, originRadius

  draw: =>
    @cam\attach!   
   
    @drawGrid!
    if #@shapes > 0
      @drawShapes!
    if #@activeVertices > 0
      @drawActiveVertices!
    if #@objects > 0
      @drawObjects!
      @drawObjectOrigin!
    @drawCursor!

    graphics.setColor 0, 0, 0
    graphics.circle "fill", 0, 0, 6

    @cam\detach!

    @drawControls!
    @drawObjectMenu!

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

  updateObjects: (dt, player) =>
    for i = #@objects, 1, -1 do
      if @objects[i].body\isDestroyed!
        @objectData[i].added = false
        -- remove @objects, i
      else
        if @objects[i].__class.__name == "Floater"
          @objects[i]\update dt
        if @objects[i].__class.__name == "Laser" and player
          @objects[i]\update dt, player

  updateWalkers: (dt, targetX, targetY) =>
    for i = #@objects, 1, -1 do
      if @objects[i].__class.__name == "Walker"
        @objects[i]\update dt, targetX, targetY

  update: (dt) =>
    @cam\zoomTo @cameraScale
    -- Ensure camera coordinates are integars
    @cam\lookAt ceil(@cam.x), ceil(@cam.y)

    @manipulateCursorRadius dt
    @gridLockCursor!
    @moveCamera dt
    @controlCameraAttributes dt
    @updateObjects dt

  mousepressed: (x, y, button) =>
    local found
    if button == 1 and not @viewObjectMenu
      -- Add a vertice to the active vertices table
      found = false
      for i = 1, #@activeVertices
        if @activeVertices[i].x == @activeX and @activeVertices[i].y == @activeY
          found = true

      if not found
        if @tool == "polygon"
          insert @activeVertices, @vec2(@activeX, @activeY)
        elseif @tool == "object"
          if (@selectedMenuItem == Floater or @selectedMenuItem == Health) and #@activeVertices < 1
            insert @activeVertices, @vec2(@activeX, @activeY)
          elseif (@selectedMenuItem == Walker or @selectedMenuItem == Laser) and #@activeVertices < 2
            insert @activeVertices, @vec2(@activeX, @activeY)
      else
        print "there is already a vertice at that coordinate"

    if button == 2 and not @viewObjectMenu
      -- Select a shape      
      if @tool == "polygon"
        @selectedShape = -1
        if @activeShape
          @selectedShape = @activeDeleteIndex
      elseif @tool == "object"
        @selectedObject = -1
        if @activeObject
          @selectedObject = @activeDeleteIndex

  recursivelySaveNewFile: (n) =>
    local str
    str = "level" .. n
    if filesystem.exists "levels/" .. str .. ".lua"
      @recursivelySaveNewFile n + 1
    else
      @loadedFilename = "levels/" .. str .. ".lua"
      return

  saveFile: =>
    if 0 < len @loadedFilename
      table.save {polygonData: @data, objectData: @objectData}, @loadedFilename
      print "saved level data to " .. @loadedFilename
    else
      @recursivelySaveNewFile 1
      @saveFile!

  flushActiveVertices: =>
    for i = #@activeVertices, 1, -1
      remove @activeVertices, i

  keypressed: (key) =>
    if key == "r"
      if @tool == "polygon"
        if #@activeVertices > 0
          remove @activeVertices, #@activeVertices
        if @selectedShape > 0
          remove @data, @selectedShape
          remove @shapes, @selectedShape
          @entities[@selectedShape]\destroy!
          remove @entities, @selectedShape

          @selectedShape = -1
      elseif @tool == "object"
        if #@activeVertices > 0
          remove @activeVertices, #@activeVertices
        if @selectedObject > 0
          remove @objectData, @selectedObject
          @objects[@selectedObject].body\destroy!
          remove @objects, @selectedObject

          @selectedObject = -1

    if key == "space"
      if @tool == "polygon"
        if #@activeVertices <= 2
          print "error: not enough active vertices to create a polgon!"
          return

        if @activeShapeType == "polygon"
          @shapes[#@shapes+1] = physics.newPolygonShape @verticesList @activeVertices 
          print "new polygon: ", inspect @verticesList @activeVertices
          insert @data, {
            vertices: @verticesList(@activeVertices)
            shapeType: @activeShapeType
            added: false
          }
        @flushActiveVertices!
      elseif @tool == "object"
        if #@activeVertices == 0
          print "error: not enough active vertices to create an object!"
          return

        local className, obj
        if @selectedMenuItem
          className = @selectedMenuItem.__class.__name
          -- adding the object data
          if className == "Floater" or className == "Health"
            obj = {
              x: @activeVertices[1].x,
              y: @activeVertices[1].y,
              objectType: className,
              added: false,
            }
          elseif className == "Walker" or className == "Laser"
            obj = {
              x: @activeVertices[1].x,
              y: @activeVertices[1].y,
              endX: @activeVertices[2].x,
              endY: @activeVertices[2].y,
              objectType: className,
              added: false,
            }
          if obj
            insert @objectData, obj
            print "new object [" .. className .. "]: " .. inspect {obj.x, obj.y} 
          @flushActiveVertices!

    if key == "m"
      @viewControls = not @viewControls
      @viewObjectMenu = false

    if key == "j"
      @viewObjectMenu = not @viewObjectMenu
      @viewControls = false

    if key == "p"
      @saveFile!

    if key == "1"
      @tool = "polygon"
      @selectedShape = -1
    elseif key == "2"
      @tool = "object"
      @selectedObject = -1

return Editor
local insert, remove
do
  local _obj_0 = table
  insert, remove = _obj_0.insert, _obj_0.remove
end
local len
len = string.len
local abs, ceil, floor, sin
do
  local _obj_0 = math
  abs, ceil, floor, sin = _obj_0.abs, _obj_0.ceil, _obj_0.floor, _obj_0.sin
end
local inspect = require("libs.inspect")
local Camera = require("libs.camera")
local Entity = require("build.entity")
local Floater = require("build.floater")
require("build.utils")
local graphics, mouse, physics, filesystem, keyboard
do
  local _obj_0 = love
  graphics, mouse, physics, filesystem, keyboard = _obj_0.graphics, _obj_0.mouse, _obj_0.physics, _obj_0.filesystem, _obj_0.keyboard
end
local Editor
do
  local _class_0
  local _base_0 = {
    cam = Camera(graphics.getWidth() / 2, graphics.getHeight() / 2),
    cameraSpeed = 300,
    cameraScale = 1,
    activeClickerRadius = 8,
    activeDeleteIndex = -1,
    activeRadius = 0,
    activeShape = false,
    activeShapeType = "polygon",
    activeVertices = { },
    activeX = mouse.getX(),
    activeY = mouse.getY(),
    selectedShape = -1,
    selectedObject = -1,
    selectedMenuItem = Floater,
    objects = { },
    data = { },
    shapes = { },
    loadedFilename = "",
    tool = "polygon",
    gridSize = 32,
    gridWidth = graphics.getWidth() / 32,
    gridHeight = graphics.getHeight() / 32,
    viewControls = false,
    hovered = {
      230,
      140,
      0
    },
    normal = {
      0,
      0,
      190
    },
    selected = {
      160,
      25,
      230
    },
    verticeRadius = 9,
    entities = { },
    loadSavedFile = function(self, filename)
      self.data = filesystem.exists(filename) and table.load(filename) or { }
      if #self.data > 0 then
        for i = 1, #self.data do
          self.shapes[i] = physics.newPolygonShape(self.data[i].vertices)
          print("new polygon: ", inspect(self.data[i].vertices))
          if self.data[i].object then
            self.data[i].load()
          end
        end
        self.loadedFilename = filename
        self:hotLoad()
        if #self.objects > 0 then
          for i = 1, #self.objects do
            self.objects[i].load()
            print(self.objects[i])
          end
        end
      end
    end,
    hotLoad = function(self)
      local target, entity
      for i = #self.data, 1, -1 do
        target = self.data[i]
        if target.shapeType == "polygon" and not target.added then
          target.added = true
          entity = Entity(0, 0, target.vertices, "static", "polygon")
          self.entities[i] = entity
        end
      end
    end,
    vec2 = function(self, x, y)
      return {
        x = x,
        y = y
      }
    end,
    verticesList = function(self)
      local result = { }
      for i = #self.activeVertices, 1, -1 do
        local vec = self.activeVertices[i]
        insert(result, vec.x)
        insert(result, vec.y)
      end
      return result
    end,
    drawOutlinedPolygon = function(self, color1, color2, vertices)
      if color2 == nil then
        color2 = color1
      end
      graphics.setColor(color1[1], color1[2], color1[3], 65)
      graphics.polygon("fill", vertices)
      graphics.setColor(color2[1], color2[2], color2[3], 255)
      return graphics.polygon("line", vertices)
    end,
    drawCircle = function(self, x, y, radius)
      graphics.setColor(190, 230, 185, 120)
      graphics.circle("fill", x, y, radius)
      graphics.setColor(190, 230, 185, 255)
      graphics.circle("line", x, y, radius)
      return graphics.circle("line", x, y, radius)
    end,
    drawShapes = function(self)
      self.activeShape = false
      self.activeDeleteIndex = -1
      local shape, x, y, tf
      tf = table.flatten
      x, y = self.activeX, self.activeY
      for i = #self.shapes, 1, -1 do
        shape = self.shapes[i]
        if shape:testPoint(0, 0, 0, x, y) and self.selectedShape ~= i then
          self.activeDeleteIndex = i
          self.activeShape = true
          self:drawOutlinedPolygon(self.hovered, nil, tf(self.data[i].vertices))
        elseif self.selectedShape == i then
          self:drawOutlinedPolygon(self.selected, nil, tf(self.data[self.selectedShape].vertices))
        else
          self:drawOutlinedPolygon(self.normal, nil, tf(self.data[i].vertices))
        end
      end
    end,
    drawObjects = function(self)
      graphics.setColor(255, 255, 255)
      for i = #self.objects, 1, -1 do
        local obj = self.objects[i]
        obj:draw()
      end
    end,
    drawCursor = function(self)
      return graphics.circle("line", self.activeX, self.activeY, self.activeClickerRadius)
    end,
    drawGrid = function(self)
      graphics.setColor(10, 10, 10, 85)
      local translateX, translateY
      translateX = ceil(self.cam.x - graphics.getWidth() / 2) - (self.cam.x % self.gridSize)
      translateY = ceil(self.cam.y - graphics.getHeight() / 2) - (self.cam.y % self.gridSize) + self.gridSize / 4
      for x = 0, self.gridSize * self.gridWidth, self.gridSize do
        for y = 0, self.gridSize * self.gridHeight, self.gridSize do
          graphics.circle("line", translateX + x, translateY + y, 3)
        end
      end
    end,
    drawActiveVertices = function(self)
      graphics.setColor(0, 0, 0, 255)
      if #self.activeVertices > 2 then
        for i = #self.activeVertices, 1, -1 do
          local current, nextOne, vec
          vec = self.activeVertices[i]
          if i + 1 > #self.activeVertices then
            current = vec
            nextOne = self.activeVertices[1]
          else
            current = vec
            nextOne = self.activeVertices[i + 1]
          end
          if current and nextOne then
            graphics.line(current.x, current.y, nextOne.x, nextOne.y)
          end
        end
      elseif #self.activeVertices == 2 then
        graphics.line(self.activeVertices[1].x, self.activeVertices[1].y, self.activeVertices[#self.activeVertices].x, self.activeVertices[#self.activeVertices].y)
      end
      for i = #self.activeVertices, 1, -1 do
        graphics.setColor(0, 235, 80, 130)
        graphics.circle("fill", self.activeVertices[i].x, self.activeVertices[i].y, self.verticeRadius)
        graphics.setColor(0, 235, 80, 245)
        graphics.circle("line", self.activeVertices[i].x, self.activeVertices[i].y, self.verticeRadius)
      end
    end,
    drawMode = function(self)
      graphics.setColor(0, 0, 0, 155)
      graphics.rectangle("fill", 0, graphics.getHeight() - 48, 350, 48)
      graphics.setColor(255, 255, 255)
      return graphics.print("Selected mode: " .. self.tool, 15, graphics.getHeight() - 32)
    end,
    drawControls = function(self)
      if self.viewControls then
        graphics.setColor(0, 0, 0, 155)
        graphics.rectangle("fill", 0, 0, 930, 250)
        graphics.setColor(255, 255, 255)
        return graphics.print("Press 'W A S D' to move the camera around \n" .. "Press 'q' to zoom out and 'e' to zoom in \n" .. "Press 'c' to increase camera speed and 'z' to decrease camera speed \n" .. "Press LEFT CLICK to add polygon point \n" .. "Press 'space' to add a polygon to the level \n" .. "Press RIGHT CLICK to select a polygon \n" .. "Press 'r' remove the last placed point, or a selected polygon \n" .. "Press 'm' to minimize this box", 15, 15)
      else
        graphics.setColor(0, 0, 0, 155)
        graphics.rectangle("fill", 0, 0, 475, 48)
        graphics.setColor(255, 255, 255)
        graphics.print("Press 'm' to open the controls list", 15, 15)
        return self:drawMode()
      end
    end,
    draw = function(self)
      self.cam:attach()
      self:drawGrid()
      if #self.shapes > 0 then
        self:drawShapes()
      end
      if #self.activeVertices > 0 then
        self:drawActiveVertices()
      end
      if #self.objects > 0 then
        self:drawObjects()
      end
      self:drawCursor()
      graphics.setColor(0, 0, 0)
      graphics.circle("fill", 0, 0, 10)
      self.cam:detach()
      return self:drawControls()
    end,
    clickerTheta = 0,
    clickerThetaStep = math.pi / 2,
    minClickerRadius = 8,
    speedControlFactor = 500,
    maxCameraSpeed = 1200,
    scaleControlFactor = 1,
    minScale = .5,
    maxScale = 2,
    manipulateCursorRadius = function(self, dt)
      self.activeClickerRadius = abs(self.minClickerRadius * sin(self.clickerTheta)) + self.minClickerRadius
      self.clickerTheta = self.clickerTheta + self.clickerThetaStep * dt < math.pi * 2 and self.clickerTheta + self.clickerThetaStep * dt or math.pi * 2
      self.clickerTheta = self.clickerTheta >= math.pi * 2 and 0 or self.clickerTheta
    end,
    gridLockCursor = function(self)
      local x, y, xr, yr
      x, y = self.cam:worldCoords(mouse.getX(), mouse.getY())
      xr, yr = (x % self.gridSize), (y % self.gridSize)
      self.activeX = xr >= self.gridSize / 2 and x - xr + self.gridSize or x - xr
      self.activeY = yr >= self.gridSize / 2 and y - yr + self.gridSize or y - yr
    end,
    moveCamera = function(self, dt)
      if keyboard.isDown("d") then
        self.cam.x = self.cam.x + (self.cameraSpeed * dt)
      elseif keyboard.isDown("a") then
        self.cam.x = self.cam.x - (1.5 * self.cameraSpeed * dt)
      end
      if keyboard.isDown("w") then
        self.cam.y = self.cam.y - (1.5 * self.cameraSpeed * dt)
      elseif keyboard.isDown("s") then
        self.cam.y = self.cam.y + (self.cameraSpeed * dt)
      end
    end,
    controlCameraAttributes = function(self, dt)
      if keyboard.isDown("z") then
        self.cameraSpeed = self.cameraSpeed - self.speedControlFactor * dt > 100 and self.cameraSpeed - self.speedControlFactor * dt or 100
      elseif keyboard.isDown("c") then
        self.cameraSpeed = self.cameraSpeed + self.speedControlFactor * dt < self.maxCameraSpeed and self.cameraSpeed + self.speedControlFactor * dt or self.maxCameraSpeed
      end
      if keyboard.isDown("q") then
        self.cameraScale = self.cameraScale - self.scaleControlFactor * dt > self.minScale and self.cameraScale - self.scaleControlFactor * dt or self.minScale
      elseif keyboard.isDown("e") then
        self.cameraScale = self.cameraScale + self.scaleControlFactor * dt < self.maxScale and self.cameraScale + self.scaleControlFactor * dt or self.maxScale
      end
    end,
    update = function(self, dt)
      for i = #self.objects, 1, -1 do
        self.objects[i]:update(dt)
      end
      self.cam:zoomTo(self.cameraScale)
      self.cam:lookAt(ceil(self.cam.x), ceil(self.cam.y))
      self:manipulateCursorRadius(dt)
      self:gridLockCursor()
      self:moveCamera(dt)
      return self:controlCameraAttributes(dt)
    end,
    mousepressed = function(self, x, y, button)
      local found
      if button == 1 then
        if self.activeShapeType == "polygon" then
          found = false
          for i = 1, #self.activeVertices do
            if self.activeVertices[i].x == self.activeX and self.activeVertices[i].y == self.activeY then
              found = true
            end
          end
          if not found then
            insert(self.activeVertices, self:vec2(self.activeX, self.activeY))
          else
            print("there is already a vertice at that coordinate")
          end
        end
      end
      if button == 2 then
        if self.activeShapeType == "polygon" then
          self.selectedShape = -1
          if self.activeShape then
            self.selectedShape = self.activeDeleteIndex
          end
        end
      end
    end,
    recursivelySaveNewFile = function(self, n)
      local str
      str = "level" .. n
      if filesystem.exists("levels/" .. str .. ".lua") then
        return self:recursivelySaveNewFile(n + 1)
      else
        self.loadedFilename = "levels/" .. str .. ".lua"
        return 
      end
    end,
    saveFile = function(self)
      if 0 < len(self.loadedFilename) then
        table.save(self.data, self.loadedFilename)
        return print("saved level data to " .. self.loadedFilename)
      else
        self:recursivelySaveNewFile(1)
        return self:saveFile()
      end
    end,
    flushActiveVertices = function(self)
      for i = #self.activeVertices, 1, -1 do
        remove(self.activeVertices, i)
      end
    end,
    keypressed = function(self, key)
      if key == "r" then
        if self.tool == "polygon" then
          if #self.activeVertices > 0 then
            remove(self.activeVertices, #self.activeVertices)
          end
          if self.selectedShape > 0 then
            remove(self.data, self.selectedShape)
            remove(self.shapes, self.selectedShape)
            self.entities[self.selectedShape]:destroy()
            remove(self.entities, self.selectedShape)
            self.selectedShape = -1
          end
        elseif self.tool == "object" then
          if #self.activeVertices > 0 then
            remove(self.activeVertices, #self.activeVertices)
          end
          if self.selectedObject > 0 then
            remove(self.objects, self.selectedObject)
            self.objects[self.objects]:destroy()
          end
        end
      end
      if key == "space" then
        if self.tool == "polygon" then
          if #self.activeVertices <= 2 then
            print("error: not enough active vertices to create a polgon!")
            return 
          end
          if self.activeShapeType == "polygon" then
            self.shapes[#self.shapes + 1] = physics.newPolygonShape(self:verticesList(self.activeVertices))
            print("new polygon: ", inspect(self:verticesList(self.activeVertices)))
            insert(self.data, {
              vertices = self:verticesList(self.activeVertices),
              shapeType = self.activeShapeType,
              added = false
            })
          end
          self:flushActiveVertices()
        elseif self.tool == "object" then
          if #self.activeVertices == 0 then
            print("error: not enough active vertices to create an object!")
            return 
          end
          local className
          if self.selectedMenuItem then
            className = self.selectedMenuItem.__class.__name
            if className == "Floater" then
              self.objects[#self.objects + 1] = Floater(self.activeVertices[1].x, self.activeVertices[1].y)
              self:flushActiveVertices()
            end
          end
        end
      end
      if key == "m" then
        self.viewControls = not self.viewControls
      end
      if key == "p" then
        self:saveFile()
      end
      if key == "1" then
        self.tool = "polygon"
      elseif key == "2" then
        self.tool = "object"
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Editor"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Editor = _class_0
end
return Editor

local inspect = require("inspect")
local Camera = require("camera")
local Entity = require("entity")
require("utils")
local Editor
do
  local _class_0
  local _base_0 = {
    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2),
    cameraSpeed = 300,
    cameraScale = 1,
    activeClickerRadius = 8,
    activeDeleteIndex = -1,
    activeRadius = 0,
    activeShape = false,
    activeShapeType = "polygon",
    activeVertices = { },
    activeX = love.mouse.getX(),
    activeY = love.mouse.getY(),
    selectedShape = -1,
    data = { },
    shapes = { },
    wantToLoad = false,
    gridSize = 32,
    gridWidth = 30,
    gridHeight = 60,
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
    addEntites = function(self)
      local target, entity
      for i = 1, #self.data do
        target = self.data[i]
        if target.shapeType == "polygon" then
          entity = Entity(0, 0, self.data[target.vertices[1]], "static", "polygon")
          self.entities[#self.entities + 1] = entity
        end
      end
    end,
    loadSavedFile = function(self, filename)
      if self.wantToLoad then
        self.data = not love.filesystem.exists(filename) and table.load(filename) or { }
        local n
        if #self.data > 0 then
          n = #self.data[1]
          for i = 1, #self.data do
            self.shapes[#self.shapes + 1] = love.physics.newPolygonShape(self.data[i].vertices)
            print("new polygon: ", inspect(self.data[i].vertices))
          end
          return self:addEntites()
        end
      end
    end,
    hotLoad = function(self)
      local target, entity
      for i = #self.data, 1, -1 do
        target = self.data[i]
        if target.removed then
          table.remove(self.data, i)
        elseif target.shapeType == "polygon" and not target.added then
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
        table.insert(result, vec.x)
        table.insert(result, vec.y)
      end
      return result
    end,
    drawOutlinedPolygon = function(self, color1, color2, vertices)
      if color2 == nil then
        color2 = color1
      end
      love.graphics.setColor(color1[1], color1[2], color1[3], 65)
      love.graphics.polygon("fill", vertices)
      love.graphics.setColor(color2[1], color2[2], color2[3], 255)
      return love.graphics.polygon("line", vertices)
    end,
    drawCircle = function(self, x, y, radius)
      love.graphics.setColor(190, 230, 185, 120)
      love.graphics.circle("fill", x, y, radius)
      love.graphics.setColor(190, 230, 185, 255)
      love.graphics.circle("line", x, y, radius)
      return love.graphics.circle("line", x, y, radius)
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
    drawCursor = function(self)
      return love.graphics.circle("line", self.activeX, self.activeY, self.activeClickerRadius)
    end,
    drawGrid = function(self)
      love.graphics.setColor(10, 10, 10, 85)
      for x = 0, self.gridSize * self.gridWidth, self.gridSize do
        for y = 0, self.gridSize * self.gridHeight, self.gridSize do
          love.graphics.circle("line", x, y, 3)
        end
      end
    end,
    drawActiveVertices = function(self)
      love.graphics.setColor(0, 0, 0, 255)
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
            love.graphics.line(current.x, current.y, nextOne.x, nextOne.y)
          end
        end
      elseif #self.activeVertices == 2 then
        love.graphics.line(self.activeVertices[1].x, self.activeVertices[1].y, self.activeVertices[#self.activeVertices].x, self.activeVertices[#self.activeVertices].y)
      end
      for i = #self.activeVertices, 1, -1 do
        love.graphics.setColor(0, 235, 80, 130)
        love.graphics.circle("fill", self.activeVertices[i].x, self.activeVertices[i].y, self.verticeRadius)
        love.graphics.setColor(0, 235, 80, 245)
        love.graphics.circle("line", self.activeVertices[i].x, self.activeVertices[i].y, self.verticeRadius)
      end
    end,
    drawControls = function(self)
      if self.viewControls then
        love.graphics.setColor(0, 0, 0, 155)
        love.graphics.rectangle("fill", 0, 0, 930, 250)
        love.graphics.setColor(255, 255, 255)
        return love.graphics.print("Press 'W A S D' to move the camera around \n" .. "Press 'q' to zoom out and 'e' to zoom in \n" .. "Press 'c' to increase camera speed and 'z' to decrease camera speed \n" .. "Press LEFT CLICK to add polygon point \n" .. "Press 'space' to add a polygon to the level \n" .. "Press RIGHT CLICK to select a polygon \n" .. "Press 'r' remove the last placed point, or a selected polygon \n" .. "Press 'm' to minimize this box", 15, 15)
      else
        love.graphics.setColor(0, 0, 0, 155)
        love.graphics.rectangle("fill", 0, 0, 475, 48)
        love.graphics.setColor(255, 255, 255)
        return love.graphics.print("Press 'm' to open the controls list", 15, 15)
      end
    end,
    draw = function(self)
      self.cam:attach()
      self:drawGrid()
      self:drawShapes()
      self:drawActiveVertices()
      self:drawCursor()
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
      self.activeClickerRadius = math.abs(self.minClickerRadius * math.sin(self.clickerTheta)) + self.minClickerRadius
      self.clickerTheta = self.clickerTheta + self.clickerThetaStep * dt < math.pi * 2 and self.clickerTheta + self.clickerThetaStep * dt or math.pi * 2
      self.clickerTheta = self.clickerTheta >= math.pi * 2 and 0 or self.clickerTheta
    end,
    gridLockCursor = function(self)
      local x, y, xr, yr
      x, y = self.cam:worldCoords(love.mouse.getX(), love.mouse.getY())
      xr, yr = (x % self.gridSize), (y % self.gridSize)
      self.activeX = xr >= self.gridSize / 2 and x - xr + self.gridSize or x - xr
      self.activeY = yr >= self.gridSize / 2 and y - yr + self.gridSize or y - yr
    end,
    moveCamera = function(self, dt)
      if love.keyboard.isDown("d") then
        self.cam.x = self.cam.x + (self.cameraSpeed * dt)
      elseif love.keyboard.isDown("a") then
        self.cam.x = self.cam.x - (self.cameraSpeed * dt)
      end
      if love.keyboard.isDown("w") then
        self.cam.y = self.cam.y - (self.cameraSpeed * dt)
      elseif love.keyboard.isDown("s") then
        self.cam.y = self.cam.y + (self.cameraSpeed * dt)
      end
    end,
    controlCameraAttributes = function(self, dt)
      if love.keyboard.isDown("z") then
        self.cameraSpeed = self.cameraSpeed - self.speedControlFactor * dt > 100 and self.cameraSpeed - self.speedControlFactor * dt or 100
      elseif love.keyboard.isDown("c") then
        self.cameraSpeed = self.cameraSpeed + self.speedControlFactor * dt < self.maxCameraSpeed and self.cameraSpeed + self.speedControlFactor * dt or self.maxCameraSpeed
      end
      if love.keyboard.isDown("q") then
        self.cameraScale = self.cameraScale - self.scaleControlFactor * dt > self.minScale and self.cameraScale - self.scaleControlFactor * dt or self.minScale
      elseif love.keyboard.isDown("e") then
        self.cameraScale = self.cameraScale + self.scaleControlFactor * dt < self.maxScale and self.cameraScale + self.scaleControlFactor * dt or self.maxScale
      end
    end,
    update = function(self, dt)
      self.cam:zoomTo(self.cameraScale)
      self.cam:lookAt(math.ceil(self.cam.x), math.ceil(self.cam.y))
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
            table.insert(self.activeVertices, self:vec2(self.activeX, self.activeY))
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
    keypressed = function(self, key)
      if key == "r" then
        if #self.activeVertices > 0 then
          table.remove(self.activeVertices, #self.activeVertices)
        end
        if self.selectedShape > 0 then
          table.remove(self.data, self.selectedShape)
          table.remove(self.shapes, self.selectedShape)
          table.remove(self.entities, self.selectedShape)
          self.selectedShape = -1
        end
      end
      if key == "space" then
        local object, targetX, targetY
        targetX, targetY = self.cam:worldCoords(self.activeX, self.activeY)
        if self.activeShapeType == "polygon" then
          self.shapes[#self.shapes + 1] = love.physics.newPolygonShape(self:verticesList(self.activeVertices))
          print("new polygon: ", inspect(self:verticesList(self.activeVertices)))
          table.insert(self.data, {
            vertices = self:verticesList(self.activeVertices),
            shapeType = self.activeShapeType,
            added = false
          })
          for i = #self.activeVertices, 1, -1 do
            table.remove(self.activeVertices, i)
          end
        end
      end
      if key == "m" then
        self.viewControls = not self.viewControls
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

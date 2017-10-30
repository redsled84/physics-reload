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
local Bounce = require("build.bounce")
local Entity = require("build.entity")
local Floater = require("build.floater")
local Laser = require("build.laser")
local Walker = require("build.walker")
local Turret = require("build.turret")
local Health = require("build.health")
local Spike = require("build.spike")
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
    activeObject = false,
    activeShapeType = "polygon",
    activeVertices = { },
    activeX = mouse.getX(),
    activeY = mouse.getY(),
    selectedShape = -1,
    selectedObject = -1,
    selectedMenuItem = Floater,
    menuItems = {
      Floater,
      Walker,
      Turret,
      Health,
      Laser,
      Spike,
      Entity,
      Bounce
    },
    objectData = { },
    objects = { },
    data = { },
    shapes = { },
    loadedFilename = "",
    tool = "polygon",
    gold = { },
    gridSize = 32,
    gridWidth = graphics.getWidth() / 32,
    gridHeight = graphics.getHeight() / 32,
    viewControls = false,
    viewObjectMenu = false,
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
      local fileData
      fileData = filesystem.exists(filename) and table.load(filename) or { }
      if fileData.polygonData then
        self.data = fileData.polygonData
      else
        self.data = fileData
      end
      if #self.data > 0 then
        for i = 1, #self.data do
          self.shapes[i] = physics.newPolygonShape(self.data[i].vertices)
          print("new polygon: ", inspect(self.data[i].vertices))
        end
        self:hotLoad()
      end
      if fileData.objectData then
        self.objectData = fileData.objectData
        if #self.objectData > 0 then
          self:hotLoadObjects()
        end
        self.loadedFilename = filename
      end
    end,
    flushObjects = function(self)
      if self.objects and #self.objects > 0 then
        for k, v in pairs(self.objects) do
          self.objects[k] = nil
        end
      end
    end,
    hotLoad = function(self)
      local target
      for i = #self.data, 1, -1 do
        target = self.data[i]
        local entity
        if not target.added then
          if target.shapeType == "polygon" then
            entity = Entity(0, 0, target.vertices, "static", "polygon")
          end
          if target.shapeType == "spike" then
            entity = Spike(0, 0, target.vertices)
          end
          if target.shapeType == "bounce" then
            entity = Bounce(0, 0, target.vertices)
          end
          if entity then
            target.added = true
            self.entities[i] = entity
          end
        end
      end
    end,
    hotLoadObjects = function(self)
      for k, v in pairs(self.objectData) do
        if not v.added then
          if v.objectType == "Floater" then
            self.objects[k] = Floater(v.x, v.y)
          end
          if v.objectType == "Walker" then
            self.objects[k] = Walker(v.x, v.y, v.endX, v.endY)
          end
          if v.objectType == "Health" then
            self.objects[k] = Health(v.x, v.y)
          end
          if v.objectType == "Laser" then
            self.objects[k] = Laser(v.x, v.y, v.endX, v.endY)
          end
          if v.objectType == "Turret" then
            self.objects[k] = Turret(v.x, v.y)
          end
          v.added = true
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
        if shape:testPoint(0, 0, 0, x, y) and self.selectedShape ~= i and self.tool == "polygon" then
          self.activeDeleteIndex = i
          self.activeShape = true
          self:drawOutlinedPolygon(self.hovered, nil, tf(self.data[i].vertices))
        elseif self.selectedShape == i then
          self:drawOutlinedPolygon(self.selected, nil, tf(self.data[self.selectedShape].vertices))
        else
          if self.data[i].shapeType == "polygon" then
            self:drawOutlinedPolygon(self.normal, nil, tf(self.data[i].vertices))
          elseif self.data[i].shapeType == "spike" then
            self:drawOutlinedPolygon({
              135,
              10,
              0
            }, nil, tf(self.data[i].vertices))
          elseif self.data[i].shapeType == "bounce" then
            self:drawOutlinedPolygon({
              20,
              165,
              0
            }, nil, tf(self.data[i].vertices))
          end
        end
      end
    end,
    drawObjects = function(self)
      self.activeObject = false
      graphics.setColor(255, 255, 255)
      for k, v in pairs(self.objects) do
        if self.objectData[k].x == self.activeX and self.objectData[k].y == self.activeY and self.selectedObject ~= i and self.tool == "object" then
          self.activeDeleteIndex = k
          self.activeObject = true
        end
        v:draw()
      end
    end,
    drawObjectGold = function(self)
      for k, v in pairs(self.objects) do
        if v.gold then
          if #v.gold > 0 and v.body:isDestroyed() then
            v:drawGold()
          end
        end
      end
    end,
    drawCursor = function(self)
      graphics.setColor(10, 10, 10, 255)
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
      if self.viewControls and not self.viewObjectMenu then
        graphics.setColor(0, 0, 0, 155)
        graphics.rectangle("fill", 0, 0, 930, 350)
        graphics.setColor(255, 255, 255)
        return graphics.print("Press 'W A S D' to move the camera around \n" .. "Press 'q' to zoom out and 'e' to zoom in \n" .. "Press 'c' to increase camera speed and 'z' to decrease camera speed \n" .. "Press LEFT CLICK to add polygon point \n" .. "Press 'space' to add a polygon to the level \n" .. "Press RIGHT CLICK to select a polygon \n" .. "Press 'r' remove the last placed point, or a selected polygon \n" .. "Press 'm' to minimize this box\n" .. "Press '1' to create and destroy polygon shapes\n" .. "Press '2' to create and destroy objects\n" .. "Press 'f' to access the object menu", 15, 15)
      else
        graphics.setColor(0, 0, 0, 155)
        graphics.rectangle("fill", 0, 0, 475, 48)
        graphics.setColor(255, 255, 255)
        graphics.print("Press 'm' to open the controls list", 15, 15)
        return self:drawMode()
      end
    end,
    testPoint = function(self, x1, y1, w1, h1, x2, y2)
      return x2 > x1 and x2 < x1 + w1 and y2 > y1 and y2 < y1 + h1
    end,
    getWidthRatio = function(self, num, den)
      return graphics.getWidth() * num / den
    end,
    getHeightRatio = function(self, num, den)
      return graphics.getHeight() * num / den
    end,
    drawObjectMenu = function(self)
      local x, y, w, h, xoffset, yoffset, itemCounter
      x, y, w, h = self:getWidthRatio(1, 8), self:getHeightRatio(1, 8), self:getWidthRatio(3, 4), self:getHeightRatio(3, 4)
      xoffset, yoffset = 10, 10
      local nItemsWide, nItemsTall, itemWidth, itemHeight, actualWidth, actualHeight
      nItemsWide, nItemsTall = w / 6, h / 6
      itemWidth, itemHeight = nItemsWide - xoffset, nItemsTall - yoffset
      actualWidth, actualHeight = itemWidth - xoffset * 2, itemHeight - yoffset * 2
      if self.viewObjectMenu and not self.viewControls then
        graphics.setColor(0, 0, 0, 155)
        graphics.rectangle("fill", x - 10, y - 10, w + 10, h + 10)
        graphics.setColor(100, 100, 100, 200)
        itemCounter = 1
        local temp, className
        for ox = x + xoffset, x + w - itemWidth, itemWidth + xoffset do
          for oy = y + yoffset, y + h - itemHeight, itemHeight + yoffset do
            if itemCounter <= #self.menuItems then
              graphics.setColor(0, 0, 0, 200)
              if self:testPoint(ox, oy, actualWidth, actualHeight, mouse.getX(), mouse.getY()) then
                graphics.setColor(unpack(self.hovered))
                if mouse.isDown(1) then
                  self.selectedMenuItem = self.menuItems[itemCounter]
                  if self.selectedMenuItem.__class.__name == "Spike" then
                    self.activeShapeType = "spike"
                  elseif self.selectedMenuItem.__class.__name == "Entity" then
                    self.activeShapeType = "polygon"
                  elseif self.selectedMenuItem.__class.__name == "Bounce" then
                    self.activeShapeType = "bounce"
                  end
                  graphics.setColor(unpack(self.selected))
                end
              end
              graphics.rectangle("fill", ox, oy, actualWidth, actualHeight)
              className = self.menuItems[itemCounter].__class.__name
              graphics.setColor(255, 255, 255)
              if className == "Floater" then
                graphics.print("floater", ox + actualWidth * (1 / 6), oy + actualHeight * (2 / 5))
              elseif className == "Walker" then
                graphics.print("walker", ox + actualWidth * (1 / 6), oy + actualHeight * (3 / 8))
              elseif className == "Turret" then
                graphics.print("turret", ox + actualWidth * (1 / 6), oy + actualHeight * (3 / 8))
              elseif className == "Health" then
                graphics.print("health", ox + actualWidth * (1 / 6), oy + actualHeight * (3 / 8))
              elseif className == "Laser" then
                graphics.print("laser", ox + actualWidth * (1 / 4), oy + actualHeight * (2 / 5))
              elseif className == "Spike" then
                graphics.print("spike", ox + actualWidth * (1 / 4), oy + actualHeight * (2 / 5))
              elseif className == "Entity" then
                graphics.print("polygon", ox + actualWidth * (1 / 6), oy + actualHeight * (2 / 5))
              elseif className == "Bounce" then
                graphics.print("bounce", ox + actualWidth * (1 / 6), oy + actualHeight * (3 / 8))
              end
            end
            itemCounter = itemCounter + 1
          end
        end
      end
    end,
    drawObjectOrigin = function(self)
      local originRadius
      originRadius = 12
      for k, v in pairs(self.objectData) do
        if self.activeObject and self.activeDeleteIndex == k then
          graphics.setColor(self.hovered[1], self.hovered[2], self.hovered[3], 120)
          graphics.circle("fill", v.x, v.y, originRadius)
          graphics.setColor(self.hovered[1], self.hovered[2], self.hovered[3], 255)
          graphics.circle("line", v.x, v.y, originRadius)
        elseif self.selectedObject == k then
          graphics.setColor(self.selected[1], self.selected[2], self.selected[3], 120)
          graphics.circle("fill", v.x, v.y, originRadius)
          graphics.setColor(self.selected[1], self.selected[2], self.selected[3], 255)
          graphics.circle("line", v.x, v.y, originRadius)
        else
          graphics.setColor(self.normal[1], self.normal[2], self.normal[3], 120)
          graphics.circle("fill", v.x, v.y, originRadius)
          graphics.setColor(self.normal[1], self.normal[2], self.normal[3], 255)
          graphics.circle("line", v.x, v.y, originRadius)
        end
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
        self:drawObjectOrigin()
      end
      self:drawCursor()
      graphics.setColor(0, 0, 0)
      graphics.circle("fill", 0, 0, 6)
      self.cam:detach()
      self:drawControls()
      return self:drawObjectMenu()
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
    updateObjects = function(self, dt, player)
      for k, v in pairs(self.objects) do
        if v.body:isDestroyed() then
          self.objectData[k].added = false
          if v.gold then
            if #v.gold < 1 then
              self.objects[k] = nil
            end
          end
        end
        if v.__class.__name == "Floater" then
          v:update(dt)
        end
        if v.__class.__name == "Laser" and player then
          v:update(dt, player)
        end
        if v.__class.__name == "Walker" and player then
          v:update(dt, player.body:getX(), player.body:getY())
        end
        if v.__class.__name == "Turret" and player then
          v:update(dt, player)
        end
      end
    end,
    update = function(self, dt)
      self.cam:zoomTo(self.cameraScale)
      self.cam:lookAt(ceil(self.cam.x), ceil(self.cam.y))
      self:manipulateCursorRadius(dt)
      self:gridLockCursor()
      self:moveCamera(dt)
      return self:controlCameraAttributes(dt)
    end,
    mousepressed = function(self, x, y, button)
      local found
      if button == 1 and not self.viewObjectMenu then
        found = false
        for i = 1, #self.activeVertices do
          if self.activeVertices[i].x == self.activeX and self.activeVertices[i].y == self.activeY then
            found = true
          end
        end
        if not found then
          if self.tool == "polygon" then
            insert(self.activeVertices, self:vec2(self.activeX, self.activeY))
          elseif self.tool == "object" then
            if (self.selectedMenuItem == Floater or self.selectedMenuItem == Health or self.selectedMenuItem == Turret) and #self.activeVertices < 1 then
              insert(self.activeVertices, self:vec2(self.activeX, self.activeY))
            elseif (self.selectedMenuItem == Walker or self.selectedMenuItem == Laser) and #self.activeVertices < 2 then
              insert(self.activeVertices, self:vec2(self.activeX, self.activeY))
            end
          end
        else
          print("there is already a vertice at that coordinate")
        end
      end
      if button == 2 and not self.viewObjectMenu then
        if self.tool == "polygon" then
          self.selectedShape = -1
          if self.activeShape then
            self.selectedShape = self.activeDeleteIndex
          end
        elseif self.tool == "object" then
          self.selectedObject = -1
          if self.activeObject then
            self.selectedObject = self.activeDeleteIndex
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
        table.save({
          polygonData = self.data,
          objectData = self.objectData
        }, self.loadedFilename)
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
    flushObjectGold = function(self)
      for k, v in pairs(self.objects) do
        if v.gold then
          if #v.gold > 0 then
            for j = #v.gold, 1, -1 do
              v.gold[j].body:destroy()
              remove(v.gold, j)
            end
          end
        end
      end
    end,
    keypressed = function(self, key)
      if key == "r" then
        if self.tool == "polygon" then
          if #self.activeVertices > 0 then
            remove(self.activeVertices, #self.activeVertices)
          end
          if self.selectedShape > 0 and self.selectedShape <= #self.entities then
            remove(self.data, self.selectedShape)
            remove(self.shapes, self.selectedShape)
            if self.entities[self.selectedShape].body then
              self.entities[self.selectedShape]:destroy()
            end
            remove(self.entities, self.selectedShape)
            print(self.selectedShape, #self.entities)
            self.selectedShape = -1
          end
        elseif self.tool == "object" then
          if #self.activeVertices > 0 then
            remove(self.activeVertices, #self.activeVertices)
          end
          if self.selectedObject > 0 and self.objects then
            remove(self.objectData, self.selectedObject)
            if self.selectedObject <= #self.objects then
              if not self.objects[self.selectedObject].body:isDestroyed() then
                self.objects[self.selectedObject].body:destroy()
              end
              remove(self.objects, self.selectedObject)
            end
            self.selectedObject = -1
          end
        end
      end
      if key == "space" then
        if self.tool == "polygon" then
          if #self.activeVertices <= 2 then
            print("error: not enough active vertices to create a polgon!")
            return 
          end
          if self.activeShapeType == "polygon" or self.activeShapeType == "spike" or self.activeShapeType == "bounce" then
            self.shapes[#self.shapes + 1] = physics.newPolygonShape(self:verticesList(self.activeVertices))
            print("new polygon: ", inspect(self:verticesList(self.activeVertices)))
            insert(self.data, {
              vertices = self:verticesList(self.activeVertices),
              shapeType = self.activeShapeType,
              added = false
            })
          end
          self:flushActiveVertices()
          self:hotLoad()
        elseif self.tool == "object" then
          if #self.activeVertices == 0 then
            print("error: not enough active vertices to create an object!")
            return 
          end
          local className, obj
          if self.selectedMenuItem then
            className = self.selectedMenuItem.__class.__name
            if className == "Floater" or className == "Health" or className == "Turret" then
              obj = {
                x = self.activeVertices[1].x,
                y = self.activeVertices[1].y,
                objectType = className,
                added = false
              }
            elseif className == "Walker" or className == "Laser" and #self.activeVertices > 1 then
              obj = {
                x = self.activeVertices[1].x,
                y = self.activeVertices[1].y,
                endX = self.activeVertices[2].x,
                endY = self.activeVertices[2].y,
                objectType = className,
                added = false
              }
            end
            if obj then
              insert(self.objectData, obj)
              print("new object [" .. className .. "]: " .. inspect({
                obj.x,
                obj.y
              }))
            end
            self:flushActiveVertices()
            self:hotLoadObjects()
          end
        end
      end
      if key == "m" then
        self.viewControls = not self.viewControls
        self.viewObjectMenu = false
      end
      if key == "f" then
        self.viewObjectMenu = not self.viewObjectMenu
        self.viewControls = false
      end
      if key == "p" then
        self:saveFile()
      end
      if key == "1" then
        self.tool = "polygon"
        self.selectedShape = -1
      elseif key == "2" then
        self.tool = "object"
        self.selectedObject = -1
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

local inspect = require("inspect")
local Camera = require("camera")
require("utils")
local Editor
do
  local _class_0
  local _base_0 = {
    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2),
    cameraSpeed = 300,
    activeClickerRadius = 8,
    activeDeleteIndex = -1,
    activeRadius = 0,
    activeShape = false,
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
    drawPolygon = function(self, vertices)
      love.graphics.setColor(210, 150, 175, 120)
      love.graphics.polygon("fill", unpack(vertices))
      love.graphics.setColor(210, 150, 175, 255)
      love.graphics.polygon("line", unpack(vertices))
      return love.graphics.polygon("line", unpack(vertices))
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
    draw = function(self)
      self.cam:attach()
      self.activeShape = false
      self.activeDeleteIndex = -1
      local shape, x, y
      x, y = self.activeX, self.activeY
      for i = #self.shapes, 1, -1 do
        shape = self.shapes[i]
        if shape:testPoint(0, 0, 0, x, y) and self.selectedShape ~= i then
          self.activeDeleteIndex = i
          self.activeShape = true
          self:drawOutlinedPolygon(self.hovered, nil, table.flatten(self.data[i].vertices))
        elseif self.selectedShape == i then
          self:drawOutlinedPolygon(self.selected, nil, table.flatten(self.data[selectedShape].vertices))
        else
          self:drawOutlinedPolygon(self.normal, nil, table.flatten(self.data[i].vertices))
        end
      end
      love.graphics.circle("line", self.activeX, self.activeY, self.activeClickerRadius)
      love.graphics.setColor(10, 10, 10, 85)
      for x = 0, self.gridSize * self.gridWidth, self.gridSize do
        for y = 0, self.gridSize * self.gridHeight, self.gridSize do
          love.graphics.circle("line", x, y, 3)
        end
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

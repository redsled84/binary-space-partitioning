local g = love.graphics
local m = love.math
local w = love.window
local nodes = {len=0, data={}, max=15}

local inspect = require "inspect"

-- helper util
local function newNode(x,y,w,h)
  local new = {x=x, y=y, w=w, h=h}
  nodes.len = nodes.len + 1
  nodes.data[nodes.len] = new
  return new 
end

function getLeafNodes()
  local leaves = {}
  for i = 1, #nodes.data do
    if not nodes.data[i].childs then
      table.insert(leaves, nodes.data[i])
    end
  end
  return leaves
end

function createChilds(leaf)
  local a, b
  if leaf.split == "h" then
    a = newNode(leaf.x, leaf.y, leaf.w / 2, leaf.h)
    b = newNode(leaf.x + leaf.w / 2, leaf.y, leaf.w / 2, leaf.h)
    a.split, b.split = "v", "v"
  elseif leaf.split == "v" then
    a = newNode(leaf.x, leaf.y, leaf.w, leaf.h / 2)
    b = newNode(leaf.x, leaf.y + leaf.h / 2, leaf.w, leaf.h / 2)
    a.split, b.split = "h", "h"
  end
  a.parent, b.parent = leaf, leaf
  leaf.childs = {a, b}
end

function drawNodes()
  g.setColor(1, 1, 1)
  local leaves = getLeafNodes()
  for i = 1, #leaves do
    local leaf = leaves[i]
    g.rectangle("line", leaf.x, leaf.y, leaf.w, leaf.h)
    g.print(i, leaf.x + leaf.w / 2, leaf.y + leaf.h / 2)
  end
end

function createBSP()
  -- create root
  newNode(0, 0, g.getWidth(), g.getHeight())
  nodes.data[1].split = m.random(0, 1) == 0 and "h" or "v"
  createChilds(nodes.data[1]) 
  while nodes.len < nodes.max do
    local leaves = getLeafNodes() 
    local randLeaf = m.random(0, 100) < 25 and leaves[1] or leaves[#leaves]
    while randLeaf.w / 2 < g.getWidth() / 9 or randLeaf.h / 2 < g.getHeight() / 9 do
      randLeaf = leaves[m.random(1, #leaves)]
    end
    createChilds(randLeaf)
  end
end

local rooms = {}
function createRooms()
  local flr = math.floor
  local leaves = getLeafNodes()
  for i, v in ipairs(leaves) do
    local w = m.random(flr(v.w / 2), flr(v.w / 1.2))
    local h = m.random(flr(v.h / 2), flr(v.h / 1.2))
    local room = {
      x = m.random(v.x, v.x + v.w - w),
      y = m.random(v.y, v.y + v.h - h),
      w = w,
      h = h
    }
    rooms[#rooms+1] = room
  end
end

function drawRooms()
  g.setColor(.5, .65, .5)
  for i, room in ipairs(rooms) do
    g.rectangle("fill", room.x, room.y, room.w, room.h)
  end
end

function love.load()
  w.setMode(1280, 720)
  createBSP()
  createRooms()
end

function love.draw()
  drawRooms()
  drawNodes()
end

function love.keypressed(key)
  if key == "r" then
    love.event.quit("restart")
  elseif key == "escape" then
    love.event.quit()
  end
end


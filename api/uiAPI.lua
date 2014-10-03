-- vim: ts=2 sw=2 expandtab
local component = require("component")
local colors = require("colors")
local term = require("term")
local event = require("event")
local unicode = require("unicode")

local gpu = component.gpu

local uiAPI = {}

function uiAPI.init ()
  uiAPI.widget = {}
  uiAPI.terminate = false
  gpu.setBackground(colors.black, true)
  gpu.setForeground(colors.white, true)
  term.clear()
end


-- -- -- -- uiAPI create widgets -- -- -- --

function uiAPI.createButton(name, caption, x, y, width, height)
  uiAPI.widget[name] = {
    ["type"] = "button",
    ["repaint"] = true,
    ["name"] = name,
    ["caption"] = caption,
    ["foreground"] = colors.gray,
    ["background"] = colors.blue,
    ["x"] = x,
    ["y"] = y,
    ["z"] = 0,
    ["width"] = width - 1,
    ["height"] = height,
    ["func"] = false
  }
  return uiAPI.widget[name]
end

function uiAPI.createFrame(name, caption, x, y, width, height)
  uiAPI.widget[name] = {
    ["type"] = "frame",
    ["repaint"] = true,
    ["name"] = name,
    ["caption"] = caption,
    ["foreground"] = colors.gray,
    ["background"] = colors.blue,
    ["x"] = x,
    ["y"] = y,
    ["z"] = 0,
    ["width"] = width - 1,
    ["height"] = height,
    ["func"] = false
  }
  return uiAPI.widget[name]
end

function uiAPI.createWindow(name, caption, posX, posY, width, height)
  uiAPI.widget[name] = {
    ["type"] = "window",
    ["repaint"] = true,
    ["name"] = name,
    ["caption"] = caption,
    ["foreground"] = colors.gray,
    ["background"] = colors.lightblue,
    ["x"] = posX,
    ["y"] = posY,
    ["z"] = 0,
    ["width"] = width - 1,
    ["height"] = height,
    ["func"] = false
  }
  uiAPI.widget[name]["content"] = {}
  return uiAPI.widget[name]
end

-- -- -- -- uiAPI internal functions -- -- -- --

local function fillBox(posX, posY, width, height, color)
  -- Save current colors
  local bgColor = gpu.getBackground()
  -- Set colors
  gpu.setBackground(color, true)
  -- Fill box
  gpu.fill(posX, posY, width+1, height, " ")
  -- Load saved colors back  
  gpu.setBackground(bgColor, true)
end

local function borderBox(posX, posY, width, height, forground, background, border)
  -- Save current colors
  local bgColor = gpu.getBackground()
  local fgColor = gpu.getForeground()
  -- Set colors
  gpu.setBackground(background, true)
  if border then
    -- Set border color
    gpu.setForeground(border, true)
    -- Draw sides
    gpu.fill(posX+1, posY, width-1, 1, unicode.char(0x2500))
    gpu.fill(posX+1, posY+height-1, width-1, 1, unicode.char(0x2500))
    gpu.fill(posX, posY+1, 1, height-2, unicode.char(0x2502))
    gpu.fill(posX+width, posY+1, 1, height-2, unicode.char(0x2502))
    -- Draw cornes
    gpu.fill(posX, posY, 1, 1, unicode.char(0x256D))
    gpu.fill(posX+width, posY, 1, 1, unicode.char(0x256E))
    gpu.fill(posX, posY+height-1, 1, 1, unicode.char(0x2570))
    gpu.fill(posX+width, posY+height-1, 1, 1, unicode.char(0x256F))
  else
    -- Draw frame sides
    gpu.fill(posX, posY, width, 1, " ")
    gpu.fill(posX, posY+height-1, width, 1, " ")
    gpu.fill(posX, posY, 1, height, " ")
    gpu.fill(posX+width, posY, 1, height, " ")
  end
  -- Load saved colors back
  gpu.getForeground(fgColor, true)
  gpu.setBackground(bgColor, true)
end

local function centerCaption(org_caption, posX, posY, width, height, foreground, background)
  -- Save current colors
  local fgColor = gpu.getForeground()
  local bgColor = gpu.getBackground()
  -- Set colors
  gpu.setForeground(foreground, true)
  gpu.setBackground(background, true)
  -- Handle caption
  local caption = org_caption
  if string.len(caption) > width then
    caption = string.sub(caption, 1, width)
  end
  local textPosX = posX + math.floor(width / 2) - math.floor(string.len(caption) / 2)
  local textPosY = posY + math.floor(height / 2)
  term.setCursor(textPosX, textPosY)
  term.write(caption)
  -- Load saved colors back
  gpu.setForeground(fgColor, true)
  gpu.setBackground(bgColor, true)
end

local function topCaption(org_caption, posX, posY, width, foreground, background)
 -- Save current colors
  local fgColor = gpu.getForeground()
  local bgColor = gpu.getBackground()
  -- Set colors
  gpu.setForeground(foreground, true)
  gpu.setBackground(background, true)
  -- Handle caption
  local caption = org_caption
  if string.len(caption) > width then
    caption = string.sub(caption, 1, width)
  end
  local textPosX = posX + math.floor(width / 2) - math.floor(string.len(caption) / 2)
  term.setCursor(textPosX, posY)
  term.write(caption)
  -- Load saved colors back
  gpu.setForeground(fgColor, true)
  gpu.setBackground(bgColor, true)
end


-- -- -- -- uiAPI common widget functions -- -- -- --

function uiAPI.set(name, field, value)
  uiAPI.widget[name][field] = value
  -- uiAPI.widget[name].repaint = true
end

function uiAPI.get(name, value)
  return uiAPI.widget[name][value]
end

function uiAPI.addContent(name, value)
  uiAPI.widget[name].content[value] = value
end


-- -- -- -- uiAPI external functions -- -- -- --

function uiAPI.screenDraw()
  local cursorX, cursorY = term.getCursor()
  local bgColor = gpu.getBackground()
  local fgColor = gpu.getForeground()
  for var,val in pairs(uiAPI.widget) do

    if val.type == "button" and val.repaint then
      fillBox(val.x, val.y, val.width, val.height, val.background)
      if val.border then
        borderBox(val.x, val.y, val.width, val.height, val.forground, val.background, val.border)
      end
      centerCaption(val.caption, val.x, val.y, val.width, val.height, val.foreground, val.background)

    elseif val.type == "frame" and val.repaint then
      borderBox(val.x, val.y, val.width, val.height, val.forground, val.background, val.border)
      topCaption(val.caption, val.x, val.y, val.width, val.foreground, val.background)

    elseif val.type == "framefullscreen" and val.repaint then
      local width, height = gpu.getResolution()
      width = width - 1
      borderBox(1, 1, width, height, val.foreground, val.background, val.border)
      topCaption(val.caption, 1, 1, width, val.foreground, val.background)
    end
    val.repaint = false
  end
  gpu.setBackground(bgColor, true)
  gpu.setForeground(fgColor, true)
  term.setCursor(cursorX, cursorY)
end

function uiAPI.windowDraw()
  -- Save colors and cursor
  local cursorX, cursorY = term.getCursor()
  local bgColor = gpu.getBackground()
  local fgColor = gpu.getForeground()
  for var,val in pairs(uiAPI.widget) do
    if val.type == "window" and val.repaint then
      -- Activate content for repaint
      for count,wid in pairs(uiAPI.widget[val.name].content) do
        uiAPI.widget[uiAPI.widget[val.name].content[wid]].repaint = true
      end
      -- Draw window background
      fillBox(val.x, val.y, val.width, val.height, val.background)
      -- Draw window content
      uiAPI.screenDraw()
    end
  end
  -- Load saved colors and cursor
  gpu.setBackground(bgColor, true)
  gpu.setForeground(fgColor, true)
  term.setCursor(cursorX, cursorY)
end

function uiAPI.checkClick(x, y, event)
  for var,val in pairs(uiAPI.widget) do
    if val.type == "button" and val.func then
      if x >= val.x and x <= val.x + val.width and y >= val.y and y <= val.y + val.height then
        val["func"](val.name, event)
      end
    end  
  end
end

function uiAPI.runOnce()
  uiAPI.screenDraw()
  uiAPI.windowDraw()
  e = {event.pull()}
  if e[1] == "touch" then
    uiAPI.checkClick(e[3], e[4], e)
  else
    return e
  end
  uiAPI.windowDraw()
  -- uiAPI.screenDraw()
end

function uiAPI.run()
  while not uiAPI.terminate do
    uiAPI.runOnce()
  end
end

return uiAPI

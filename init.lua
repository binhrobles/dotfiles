-- Windox max
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end)

-- Window to left side
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.w = max.w / 2
  win:setFrame(f)
end)

-- Window to right side
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "L", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.w = max.w / 2
  win:setFrame(f)
end)

-- Window up
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "K", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.y = max.y
  f.h = max.h / 2
  win:setFrame(f)
end)

-- Window down
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "J", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.y = max.y + (max.h / 2)
  f.h = max.h / 2
  win:setFrame(f)
end)

-- Window centered vertically (for vert monitors)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "N", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.y = max.y + (max.h / 5)
  f.h = max.h * 2 / 3
  win:setFrame(f)
end)


-- Send window to left monitor
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function()
  local win = hs.window.focusedWindow()
  win:moveOneScreenWest()
end)

-- Send window to right monitor
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", function()
  local win = hs.window.focusedWindow()
  win:moveOneScreenEast()
end)

-- === Default laptop layout: maximize all windows ===
local function applyLaptopLayout()
  for _, win in ipairs(hs.window.visibleWindows()) do
    if win:application() then
      win:setFrame(win:screen():frame())
    end
  end
  hs.notify.new({title="Hammerspoon", informativeText="Laptop layout applied"}):send()
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "D", applyLaptopLayout)

-- === Auto-layout when docking to Studio Display ===
local WORK_MONITOR = "Studio Display"
local HOME_MONITOR = "DELL U3219Q"

local function applyWorkLayout()
  local screens = hs.screen.allScreens()
  if #screens < 2 then return end

  local workScreen = hs.screen.find(WORK_MONITOR)
  if not workScreen then return end

  -- The other screen is the laptop
  local laptopScreen
  for _, s in ipairs(screens) do
    if s:name() ~= WORK_MONITOR then
      laptopScreen = s
      break
    end
  end
  if not laptopScreen then return end

  for _, win in ipairs(hs.window.visibleWindows()) do
    local app = win:application()
    if app then
      if app:name() == "iTerm2" then
        win:moveToScreen(workScreen)
      else
        win:moveToScreen(laptopScreen)
      end
      local screen = win:screen()
      win:setFrame(screen:frame())
    end
  end

  hs.notify.new({title="Hammerspoon", informativeText="Work layout applied"}):send()
end

-- === Home layout: DELL U3219Q + laptop ===
local function applyHomeLayout()
  local screens = hs.screen.allScreens()
  if #screens < 2 then return end

  local homeScreen = hs.screen.find(HOME_MONITOR)
  if not homeScreen then return end

  local laptopScreen
  for _, s in ipairs(screens) do
    if s:name() ~= HOME_MONITOR then
      laptopScreen = s
      break
    end
  end
  if not laptopScreen then return end

  for _, win in ipairs(hs.window.visibleWindows()) do
    local app = win:application()
    if app then
      if app:name() == "Slack" then
        win:moveToScreen(laptopScreen)
      else
        win:moveToScreen(homeScreen)
      end
      win:setFrame(win:screen():frame())
    end
  end

  hs.notify.new({title="Hammerspoon", informativeText="Home layout applied"}):send()
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "E", applyHomeLayout)

-- Manual trigger
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", applyWorkLayout)

-- Auto-trigger when screens change (docking/undocking)
screenWatcher = hs.screen.watcher.new(function()
  hs.timer.doAfter(2, function()
    if hs.screen.find(WORK_MONITOR) then
      applyWorkLayout()
    elseif hs.screen.find(HOME_MONITOR) then
      applyHomeLayout()
    end
  end)
end)
screenWatcher:start()

-- Toggle input source (U.S. <-> Telex)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "I", function()
  if hs.keycodes.currentMethod() == "Telex" then
    hs.keycodes.setLayout("U.S.")
  else
    hs.keycodes.setMethod("Telex")
  end
  local name = hs.keycodes.currentMethod() or hs.keycodes.currentLayout()
  hs.alert.show(name, 0.5)
end)

-- Easy reload
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

-- === Hotkey cheat sheet (hold Cmd+Alt+Ctrl) ===
local cheatsheet = nil

local hotkeyList = {
  { key = "M", desc = "Maximize window" },
  { key = "H", desc = "Window to left half" },
  { key = "L", desc = "Window to right half" },
  { key = "K", desc = "Window to top half" },
  { key = "J", desc = "Window to bottom half" },
  { key = "N", desc = "Center vertically (vertical monitor)" },
  { key = "←", desc = "Send window to left monitor" },
  { key = "→", desc = "Send window to right monitor" },
  { key = "D", desc = "Laptop layout (maximize all)" },
  { key = "E", desc = "Home layout (dock to Dell U3219Q)" },
  { key = "W", desc = "Work layout (dock to Studio Display)" },
  { key = "I", desc = "Toggle input source" },
  { key = "R", desc = "Reload config" },
}

local function showCheatsheet()
  if cheatsheet then return end

  local screen = hs.screen.mainScreen():frame()
  local rowHeight = 32
  local padding = 20
  local headerHeight = 44
  local panelW = 420
  local panelH = headerHeight + (#hotkeyList * rowHeight) + padding * 2
  local panelX = (screen.w - panelW) / 2 + screen.x
  local panelY = (screen.h - panelH) / 2 + screen.y

  cheatsheet = hs.canvas.new({ x = panelX, y = panelY, w = panelW, h = panelH })

  -- Background
  cheatsheet:appendElements({
    type = "rectangle",
    action = "fill",
    roundedRectRadii = { xRadius = 12, yRadius = 12 },
    fillColor = { red = 0.1, green = 0.1, blue = 0.12, alpha = 0.92 },
  })

  -- Header
  cheatsheet:appendElements({
    type = "text",
    text = "⌃ ⌥ ⌘  +",
    textAlignment = "center",
    textColor = { white = 0.5 },
    textFont = "Menlo",
    textSize = 16,
    frame = { x = 0, y = padding * 0.6, w = panelW, h = headerHeight },
  })

  -- Rows
  for i, entry in ipairs(hotkeyList) do
    local y = headerHeight + padding + (i - 1) * rowHeight

    -- Key badge
    cheatsheet:appendElements({
      type = "rectangle",
      action = "fill",
      roundedRectRadii = { xRadius = 6, yRadius = 6 },
      fillColor = { red = 0.25, green = 0.25, blue = 0.3, alpha = 1 },
      frame = { x = padding, y = y, w = 44, h = 26 },
    })
    cheatsheet:appendElements({
      type = "text",
      text = entry.key,
      textAlignment = "center",
      textColor = { white = 1 },
      textFont = "Menlo-Bold",
      textSize = 14,
      frame = { x = padding, y = y + 2, w = 44, h = 24 },
    })

    -- Description
    cheatsheet:appendElements({
      type = "text",
      text = entry.desc,
      textAlignment = "left",
      textColor = { white = 0.85 },
      textFont = "Menlo",
      textSize = 14,
      frame = { x = padding + 60, y = y + 2, w = panelW - padding * 2 - 60, h = 24 },
    })
  end

  cheatsheet:level(hs.canvas.windowLevels.overlay)
  cheatsheet:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
  cheatsheet:show()
end

local function hideCheatsheet()
  if cheatsheet then
    cheatsheet:delete()
    cheatsheet = nil
  end
end

cheatsheetTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
  local flags = event:getFlags()
  if flags.cmd and flags.alt and flags.ctrl and not flags.shift then
    showCheatsheet()
  else
    hideCheatsheet()
  end
end)
cheatsheetTap:start()

hs.notify.new({title="Hammerspoon", informativeText="Config reloaded"}):send()

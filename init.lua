-- Enables the `hs` CLI
require("hs.ipc")

local HYPER = {"cmd", "alt", "ctrl"}

-- === Hotkey registry: every hyper binding is listed in the cheat sheet ===
local sections = {
  window  = { title = "WINDOW",  keys = {} },
  system  = { title = "SYSTEM",  keys = {} },
  layouts = { title = "LAYOUTS", keys = {} },
  apps    = { title = "APPS",    keys = {} },
}
local hotkeyColumns = {
  { sections.window, sections.system },
  { sections.layouts, sections.apps },
}
local keyLabels = { Left = "←", Right = "→" }

local dismissCheatsheet -- defined with the cheat sheet below

local function bind(section, key, desc, fn)
  table.insert(sections[section].keys, { key = keyLabels[key] or key, desc = desc })
  hs.hotkey.bind(HYPER, key, function()
    dismissCheatsheet()
    fn()
  end)
end

-- === Window ===
-- No-op when nothing is focused (e.g. the desktop)
local function withWindow(fn)
  return function()
    local win = hs.window.focusedWindow()
    if win then fn(win) end
  end
end

-- fn(f, max) adjusts window frame f within screen frame max
local function snap(fn)
  return withWindow(function(win)
    local f, max = win:frame(), win:screen():frame()
    fn(f, max)
    win:setFrame(f)
  end)
end

bind("window", "M", "Maximize window", snap(function(f, max)
  f.x, f.y, f.w, f.h = max.x, max.y, max.w, max.h
end))
bind("window", "H", "Window to left half", snap(function(f, max)
  f.x, f.w = max.x, max.w / 2
end))
bind("window", "L", "Window to right half", snap(function(f, max)
  f.x, f.w = max.x + max.w / 2, max.w / 2
end))
bind("window", "K", "Window to top half", snap(function(f, max)
  f.y, f.h = max.y, max.h / 2
end))
bind("window", "J", "Window to bottom half", snap(function(f, max)
  f.y, f.h = max.y + max.h / 2, max.h / 2
end))
bind("window", "N", "Center vertically (vertical monitor)", snap(function(f, max)
  f.y, f.h = max.y + max.h / 5, max.h * 2 / 3
end))
bind("window", "Left", "Send window to left monitor", withWindow(function(win)
  win:moveOneScreenWest()
end))
bind("window", "Right", "Send window to right monitor", withWindow(function(win)
  win:moveOneScreenEast()
end))

-- === Layouts ===
local WORK_MONITOR = "Studio Display"
local HOME_MONITOR = "DELL U3219Q"

-- screenFor(appName, external, laptop) -> screen the app's windows belong on
local layouts = {
  work = {
    label = "Work",
    monitor = WORK_MONITOR,
    screenFor = function(appName, external, laptop)
      if appName == "iTerm2" then return external end
      return laptop
    end,
  },
  home = {
    label = "Home",
    monitor = HOME_MONITOR,
    screenFor = function(_, external) return external end,
  },
}

-- Active docked layout; new windows are routed per its rules. nil = laptop, no routing.
local layoutMode = nil

local function layoutScreens(layout)
  local external = hs.screen.find(layout.monitor)
  if not external then return nil end
  for _, s in ipairs(hs.screen.allScreens()) do
    if s:name() ~= layout.monitor then return external, s end
  end
end

local function detectLayoutMode()
  if hs.screen.find(WORK_MONITOR) then return "work" end
  if hs.screen.find(HOME_MONITOR) then return "home" end
  return nil
end

local function applyLayout(mode)
  local layout = layouts[mode]
  local external, laptop = layoutScreens(layout)
  if not laptop then return end

  layoutMode = mode
  for _, win in ipairs(hs.window.visibleWindows()) do
    local app = win:application()
    if app then
      win:moveToScreen(layout.screenFor(app:name(), external, laptop))
      win:setFrame(win:screen():frame())
    end
  end

  hs.notify.new({title="Hammerspoon", informativeText=layout.label .. " layout applied"}):send()
end

-- Default laptop layout: maximize all windows, stop routing new windows
local function applyLaptopLayout()
  layoutMode = nil
  for _, win in ipairs(hs.window.visibleWindows()) do
    if win:application() then
      win:setFrame(win:screen():frame())
    end
  end
  hs.notify.new({title="Hammerspoon", informativeText="Laptop layout applied"}):send()
end

bind("layouts", "D", "Laptop layout (maximize all)", applyLaptopLayout)
bind("layouts", "E", "Home layout (dock to Dell U3219Q)", function() applyLayout("home") end)
bind("layouts", "W", "Work layout (dock to Studio Display)", function() applyLayout("work") end)

local function screenSignature()
  local ids = {}
  for _, s in ipairs(hs.screen.allScreens()) do ids[#ids + 1] = s:getUUID() end
  table.sort(ids)
  return table.concat(ids, ",")
end

-- The watcher also fires on wake, resolution, and arrangement changes; only
-- re-apply when monitors are added or removed. Debounced to ride out flapping.
local lastScreens = screenSignature()
screenChangeTimer = hs.timer.delayed.new(2, function()
  local current = screenSignature()
  if current == lastScreens then return end
  lastScreens = current

  local mode = detectLayoutMode()
  if mode then
    applyLayout(mode)
  else
    layoutMode = nil
  end
end)
screenWatcher = hs.screen.watcher.new(function() screenChangeTimer:start() end)
screenWatcher:start()

-- On reload, resume routing for the current dock without rearranging windows
layoutMode = detectLayoutMode()

-- Route newly opened windows to their layout's screen (default filter: standard windows only)
newWindowFilter = hs.window.filter.new()
newWindowFilter:subscribe(hs.window.filter.windowCreated, function(win, appName)
  if not layoutMode then return end
  local layout = layouts[layoutMode]
  local external, laptop = layoutScreens(layout)
  if not laptop then return end
  local target = layout.screenFor(appName, external, laptop)
  if win:screen():id() ~= target:id() then
    win:moveToScreen(target)
  end
end)

-- === App launch/focus (right-hand keys; hyper is a left-hand chord) ===
local appHotkeys = {
  { key = "I", app = "iTerm" },
  { key = "O", app = "Zen" },
  { key = ";", app = "Slack" },
  { key = "Y", app = "Notion" },
  { key = "/", app = "zoom.us", desc = "Zoom" },
}

for _, entry in ipairs(appHotkeys) do
  bind("apps", entry.key, entry.desc or entry.app, function()
    hs.application.launchOrFocus(entry.app)
  end)
end

bind("system", "R", "Reload config", hs.reload)

-- === Zen: Cmd+` switches tabs in recently-used order ===
-- Sends Ctrl+Tab, which is MRU with browser.ctrlTab.sortByRecentlyUsed. Ctrl stays down
-- while Cmd is held, so repeated ` walks further back (Shift reverses), like Cmd+Tab.
local ZEN_BUNDLE_ID = "app.zen-browser.zen"
local SYNTHETIC_TAG = 0x7a656e -- marks our own events so the tap ignores them
local GRAVE = hs.keycodes.map["`"]
local zenCtrlHeld = false

local function postTagged(event)
  event:setProperty(hs.eventtap.event.properties.eventSourceUserData, SYNTHETIC_TAG):post()
end

zenTabTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.flagsChanged }, function(event)
  if event:getProperty(hs.eventtap.event.properties.eventSourceUserData) == SYNTHETIC_TAG then return false end
  local flags = event:getFlags()

  if event:getType() == hs.eventtap.event.types.flagsChanged then
    if zenCtrlHeld and not flags.cmd then
      zenCtrlHeld = false
      postTagged(hs.eventtap.event.newKeyEvent("ctrl", false))
    end
    return false
  end

  if event:getKeyCode() ~= GRAVE or not flags.cmd or flags.alt then return false end
  local app = hs.application.frontmostApplication()
  if not app or app:bundleID() ~= ZEN_BUNDLE_ID then return false end

  if not zenCtrlHeld then
    zenCtrlHeld = true
    postTagged(hs.eventtap.event.newKeyEvent("ctrl", true))
  end
  local mods = flags.shift and { "ctrl", "shift" } or { "ctrl" }
  postTagged(hs.eventtap.event.newKeyEvent(mods, "tab", true))
  postTagged(hs.eventtap.event.newKeyEvent(mods, "tab", false))
  return true
end)
zenTabTap:start()

-- === Hotkey cheat sheet (hold Cmd+Alt+Ctrl) ===
local CHEATSHEET_DELAY = 0.3
local cheatsheet = nil
local cheatsheetSuppressed = false -- a hyper hotkey fired; stay hidden until hyper is released

local function showCheatsheet()
  if cheatsheet then return end

  local screen = hs.screen.mainScreen():frame()
  local rowHeight = 32
  local sectionTitleHeight = 34
  local padding = 20
  local headerHeight = 44
  local colW = 370
  local colGap = 24
  local panelW = padding * 2 + colW * #hotkeyColumns + colGap * (#hotkeyColumns - 1)

  local maxColH = 0
  for _, column in ipairs(hotkeyColumns) do
    local colH = 0
    for _, section in ipairs(column) do
      colH = colH + sectionTitleHeight + #section.keys * rowHeight
    end
    if colH > maxColH then maxColH = colH end
  end
  local panelH = headerHeight + maxColH + padding * 2
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

  -- Current layout mode
  cheatsheet:appendElements({
    type = "text",
    text = "Mode: " .. (layoutMode and layouts[layoutMode].label or "Laptop"),
    textAlignment = "right",
    textColor = { white = 0.5 },
    textFont = "Menlo",
    textSize = 12,
    frame = { x = padding, y = padding * 0.6 + 3, w = panelW - padding * 2, h = headerHeight },
  })

  -- Columns of sections
  for ci, column in ipairs(hotkeyColumns) do
    local x = padding + (ci - 1) * (colW + colGap)
    local y = headerHeight + padding

    for _, section in ipairs(column) do
      -- Section title
      cheatsheet:appendElements({
        type = "text",
        text = section.title,
        textAlignment = "left",
        textColor = { white = 0.45 },
        textFont = "Menlo-Bold",
        textSize = 11,
        frame = { x = x, y = y + 12, w = colW, h = 16 },
      })
      y = y + sectionTitleHeight

      for _, entry in ipairs(section.keys) do
        -- Key badge
        cheatsheet:appendElements({
          type = "rectangle",
          action = "fill",
          roundedRectRadii = { xRadius = 6, yRadius = 6 },
          fillColor = { red = 0.25, green = 0.25, blue = 0.3, alpha = 1 },
          frame = { x = x, y = y, w = 44, h = 26 },
        })
        cheatsheet:appendElements({
          type = "text",
          text = entry.key,
          textAlignment = "center",
          textColor = { white = 1 },
          textFont = "Menlo-Bold",
          textSize = 14,
          frame = { x = x, y = y + 2, w = 44, h = 24 },
        })

        -- Description
        cheatsheet:appendElements({
          type = "text",
          text = entry.desc,
          textAlignment = "left",
          textColor = { white = 0.85 },
          textFont = "Menlo",
          textSize = 14,
          frame = { x = x + 60, y = y + 2, w = colW - 60, h = 24 },
        })
        y = y + rowHeight
      end
    end
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

cheatsheetTimer = hs.timer.delayed.new(CHEATSHEET_DELAY, showCheatsheet)

dismissCheatsheet = function()
  cheatsheetSuppressed = true
  cheatsheetTimer:stop()
  hideCheatsheet()
end

cheatsheetTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
  local flags = event:getFlags()
  if flags.cmd and flags.alt and flags.ctrl and not flags.shift then
    if not cheatsheet and not cheatsheetSuppressed and not cheatsheetTimer:running() then
      cheatsheetTimer:start()
    end
  else
    cheatsheetSuppressed = false
    cheatsheetTimer:stop()
    hideCheatsheet()
  end
end)
cheatsheetTap:start()

hs.notify.new({title="Hammerspoon", informativeText="Config reloaded"}):send()

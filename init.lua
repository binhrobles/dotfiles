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

-- Easy reload
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

hs.notify.new({title="Hammerspoon", informativeText="Config reloaded"}):send()

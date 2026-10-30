-- Lua 5.0. Several handlers can share one event. UPDATE is OnUpdate.
-- OnUpdate is attached only while at least one UPDATE handler is registered.

Balf = Balf or {}
Balf.Events = {}

local frame = CreateFrame("Frame")
local handlers = {}

local function callHandlers(list, a1, a2, a3, a4, a5, a6, a7, a8, a9)
  if not list then
    return
  end
  local i = 1
  while i <= table.getn(list) do
    local handler = list[i]
    handler(a1, a2, a3, a4, a5, a6, a7, a8, a9)
    if list[i] == handler then
      i = i + 1
    end
  end
end

local function onUpdate(elapsed)
  callHandlers(handlers["UPDATE"], elapsed or arg1)
end

frame:SetScript("OnEvent", function()
  if not event then
    return
  end
  callHandlers(handlers[event], arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end)

local function syncUpdate()
  if handlers["UPDATE"] then
    frame:SetScript("OnUpdate", onUpdate)
  else
    frame:SetScript("OnUpdate", nil)
  end
end

function Balf.Events.On(eventName, handler)
  if not handlers[eventName] then
    handlers[eventName] = {}
    if eventName ~= "UPDATE" then
      frame:RegisterEvent(eventName)
    end
  end
  local list = handlers[eventName]
  -- Lua 5.0: table.remove stores the size in `n`, and a raw list[i] = value
  -- does not update it. table.getn would then ignore every handler added later.
  table.insert(list, handler)
  if eventName == "UPDATE" then
    syncUpdate()
  end
end

function Balf.Events.Off(eventName, handler)
  local list = handlers[eventName]
  if not list then
    return
  end
  local i = 1
  while i <= table.getn(list) do
    if list[i] == handler then
      table.remove(list, i)
    else
      i = i + 1
    end
  end
  if table.getn(list) == 0 then
    handlers[eventName] = nil
    if eventName == "UPDATE" then
      syncUpdate()
    else
      frame:UnregisterEvent(eventName)
    end
  end
end

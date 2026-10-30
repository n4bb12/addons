-- Settings for which rows are shown, and the window. /ecs matches the 1.14 commands.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

if not CreateFrame then
  return
end

local config = CreateFrame("Frame", "ECS_ConfigFrame", UIParent)
config:SetWidth(420)
config:SetHeight(520)
config:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
if config.SetBackdrop then
  config:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  config:SetBackdropColor(0, 0, 0, 0.9)
end
config:SetMovable(true)
config:EnableMouse(true)
config:RegisterForDrag("LeftButton")
config:SetScript("OnDragStart", function()
  this:StartMoving()
end)
config:SetScript("OnDragStop", function()
  this:StopMovingOrSizing()
end)

local heading = config:CreateFontString(nil, "OVERLAY", "GameFontNormal")
heading:SetPoint("TOP", config, "TOP", 0, -10)
heading:SetText("Extended Character Stats")

local close = CreateFrame("Button", nil, config, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", config, "TOPRIGHT", -2, -2)

local scroll = CreateFrame("ScrollFrame", "ECS_ConfigScroll", config, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", config, "TOPLEFT", 8, -32)
scroll:SetPoint("BOTTOMRIGHT", config, "BOTTOMRIGHT", -28, 8)
local child = CreateFrame("Frame", "ECS_ConfigChild", scroll)
child:SetWidth(360)
scroll:SetScrollChild(child)

local watchers = {}
local entries = {}
local option = 0

local function remember(paint)
  table.insert(watchers, paint)
end

local function addEntry(indent, height, shown, place, hide)
  table.insert(entries, {
    indent = indent,
    height = height,
    gap = indent == 0,
    shown = shown,
    place = place,
    hide = hide,
  })
end

local function always()
  return true
end

local function addGroup(label)
  local text = child:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  text:SetJustifyH("LEFT")
  text:SetText(label)
  addEntry(0, 18, always, function(left, y)
    text:ClearAllPoints()
    text:SetPoint("TOPLEFT", child, "TOPLEFT", left, y)
    text:Show()
  end, function()
    text:Hide()
    text:ClearAllPoints()
  end)
end

local function addCheck(indent, label, getter, setter, shown)
  option = option + 1
  local check = CreateFrame("CheckButton", "ECS_Option" .. option, child, "UICheckButtonTemplate")
  check:SetWidth(22)
  check:SetHeight(22)
  local text = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  text:SetJustifyH("LEFT")
  text:SetText(label)
  check:SetScript("OnClick", function()
    setter(this:GetChecked() and true or false)
    Balf.Ecs.refresh()
  end)
  remember(function()
    check:SetChecked(getter() and 1 or nil)
  end)
  addEntry(indent, 22, shown, function(left, y)
    check:ClearAllPoints()
    check:SetPoint("TOPLEFT", child, "TOPLEFT", left, y + 2)
    check:Show()
    text:ClearAllPoints()
    text:SetPoint("LEFT", check, "RIGHT", 2, 0)
    text:Show()
  end, function()
    check:Hide()
    text:Hide()
    check:ClearAllPoints()
    text:ClearAllPoints()
  end)
end

local function addStepper(indent, label, getter, setter, step, low, high, shown)
  local text = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  text:SetJustifyH("LEFT")
  local minus = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
  minus:SetWidth(22)
  minus:SetHeight(18)
  minus:SetText("-")
  local plus = CreateFrame("Button", nil, child, "UIPanelButtonTemplate")
  plus:SetWidth(22)
  plus:SetHeight(18)
  plus:SetText("+")
  local function change(delta)
    local nextValue = getter() + delta
    if nextValue < low then
      nextValue = low
    end
    if nextValue > high then
      nextValue = high
    end
    setter(nextValue)
    Balf.Ecs.refresh()
  end
  minus:SetScript("OnClick", function()
    change(-step)
  end)
  plus:SetScript("OnClick", function()
    change(step)
  end)
  remember(function()
    text:SetText(label .. ": " .. getter())
  end)
  addEntry(indent, 22, shown, function(left, y)
    text:ClearAllPoints()
    text:SetPoint("TOPLEFT", child, "TOPLEFT", left + 4, y)
    text:Show()
    minus:ClearAllPoints()
    minus:SetPoint("TOPRIGHT", child, "TOPRIGHT", -28, y)
    minus:Show()
    plus:ClearAllPoints()
    plus:SetPoint("LEFT", minus, "RIGHT", 2, 0)
    plus:Show()
  end, function()
    text:Hide()
    minus:Hide()
    plus:Hide()
    text:ClearAllPoints()
    minus:ClearAllPoints()
    plus:ClearAllPoints()
  end)
end

local function roundStep(value)
  return Balf.Ecs.round(value, 2)
end

local function colorsOn()
  return Balf.Ecs.general().addColorsToStatTexts
end

local function qualityOn()
  return Balf.Ecs.general().showQualityColors
end

addGroup("General")
addCheck(1, "Hide ECS when opening character tab", function()
  return Balf.Ecs.general().statsWindowClosedOnOpen
end, function(value)
  Balf.Ecs.general().statsWindowClosedOnOpen = value
end, always)

addGroup("Appearance")
addCheck(1, "Colorize Stats", colorsOn, function(value)
  Balf.Ecs.general().addColorsToStatTexts = value
end, always)

option = option + 1
local colorMode = CreateFrame("Button", "ECS_ColorMode", child, "UIPanelButtonTemplate")
colorMode:SetWidth(220)
colorMode:SetHeight(18)
local COLOR_MODE = { full = "Full", texts = "Stat texts", values = "Stat values" }
local COLOR_NEXT = { full = "texts", texts = "values", values = "full" }
colorMode:SetScript("OnClick", function()
  local current = Balf.Ecs.general().statColorSelection or "full"
  Balf.Ecs.general().statColorSelection = COLOR_NEXT[current] or "full"
  Balf.Ecs.refresh()
end)
remember(function()
  local current = Balf.Ecs.general().statColorSelection or "full"
  colorMode:SetText("Colors: " .. (COLOR_MODE[current] or "Full"))
end)
addEntry(2, 22, colorsOn, function(left, y)
  colorMode:ClearAllPoints()
  colorMode:SetPoint("TOPLEFT", child, "TOPLEFT", left + 4, y)
  colorMode:Show()
end, function()
  colorMode:Hide()
  colorMode:ClearAllPoints()
end)

addCheck(1, "Show Item Quality Colors", qualityOn, function(value)
  Balf.Ecs.general().showQualityColors = value
end, always)
addStepper(2, "Quality Colors' Intensity", function()
  return Balf.Ecs.general().qualityColorsIntensity
end, function(value)
  Balf.Ecs.general().qualityColorsIntensity = roundStep(value)
end, 0.05, 0.1, 1, qualityOn)
addStepper(1, "Header Font Size", function()
  return Balf.Ecs.general().headerFontSize
end, function(value)
  Balf.Ecs.general().headerFontSize = value
end, 1, 8, 18, always)
addStepper(1, "Stat Font Size", function()
  return Balf.Ecs.general().statFontSize
end, function(value)
  Balf.Ecs.general().statFontSize = value
end, 1, 8, 18, always)

addGroup("Window")
local window = Balf.Ecs.general().window
addStepper(1, "Window Width", function()
  return window.width
end, function(value)
  window.width = value
end, 5, 160, 400, always)
addStepper(1, "Window Height", function()
  return window.height
end, function(value)
  window.height = value
end, 10, 220, 700, always)
addStepper(1, "Window X", function()
  return window.xOffset
end, function(value)
  window.xOffset = value
end, 5, -400, 400, always)
addStepper(1, "Window Y", function()
  return window.yOffset
end, function(value)
  window.yOffset = value
end, 5, -400, 400, always)

addGroup("Stats")

local function parentsOn(row)
  if row.group and not Balf.Ecs.shown(row.group) then
    return false
  end
  if row.parent and not Balf.Ecs.shown(row.parent) then
    return false
  end
  if row.school and not Balf.Ecs.shown(row.school) then
    return false
  end
  return true
end

local catalog = Balf.Ecs.catalog()
local index = 1
while index <= table.getn(catalog) do
  local row = catalog[index]
  local label = row.header or row.text
  local ref = row.ref
  addCheck(Balf.Ecs.rowDepth(row), label, function()
    return Balf.Ecs.shown(ref)
  end, function(value)
    Balf.Ecs.setShown(ref, value)
  end, function()
    return parentsOn(row)
  end)
  index = index + 1
end

local function layout()
  local y = -4
  index = 1
  while index <= table.getn(entries) do
    local entry = entries[index]
    if entry.shown() then
      if entry.gap and y < -4 then
        y = y - 10
      end
      entry.place(8 + entry.indent * 18, y)
      y = y - entry.height
    else
      entry.hide()
    end
    index = index + 1
  end
  Balf.Ecs.fitScroll(scroll, child, -y + 12)
end

function Balf.Ecs.paintConfig()
  local i = 1
  while i <= table.getn(watchers) do
    watchers[i]()
    i = i + 1
  end
  layout()
end

function Balf.Ecs.toggleConfig()
  if config:IsShown() then
    config:Hide()
  else
    Balf.Ecs.paintConfig()
    config:Show()
  end
end

if UISpecialFrames then
  table.insert(UISpecialFrames, "ECS_ConfigFrame")
end

config:Hide()
Balf.Ecs.paintConfig()

SLASH_ECS1 = "/ecs"
SlashCmdList = SlashCmdList or {}
SlashCmdList["ECS"] = function(msg)
  local cmd = string.lower(msg or "")
  if cmd == "toggle" then
    local stats = getglobal("ECS_StatsFrame")
    if stats:IsShown() then
      stats:Hide()
    else
      stats:Show()
      Balf.Ecs.invalidate()
      Balf.Ecs.paint()
    end
    Balf.Ecs.refresh()
  elseif cmd == "config" then
    Balf.Ecs.toggleConfig()
  else
    print("Available Commands")
    print("/ecs toggle - Toggles the visibility of the stats window")
    print("/ecs config - Shows the configuration window")
  end
end

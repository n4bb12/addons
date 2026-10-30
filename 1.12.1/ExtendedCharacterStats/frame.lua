-- Stats window beside the character sheet. PaperDollFrame is the 1.12 character
-- page; it has no child named PaperDollItemsFrame.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

if not CreateFrame or not PaperDollFrame then
  return
end

local window = CreateFrame("Frame", "ECS_StatsFrame", PaperDollFrame)
local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", window, "TOP", 0, -8)
title:SetText("ECS")

local settings = CreateFrame("Button", "ECS_SettingsButton", window, "UIPanelButtonTemplate")
settings:SetHeight(18)
settings:SetText("Settings")
settings:SetPoint("TOP", window, "TOP", 0, -26)
settings:SetScript("OnClick", function()
  if Balf.Ecs.toggleConfig then
    Balf.Ecs.toggleConfig()
  end
end)

local scroll = CreateFrame("ScrollFrame", "ECS_StatsScroll", window, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", window, "TOPLEFT", 8, -48)
scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -28, 8)
local child = CreateFrame("Frame", "ECS_StatsChild", scroll)
scroll:SetScrollChild(child)

local rows = Balf.Ecs.catalog()
local index = 1
while index <= table.getn(rows) do
  local row = rows[index]
  local label = child:CreateFontString(nil, "OVERLAY", row.header and "GameFontNormal" or "GameFontHighlightSmall")
  label:SetJustifyH("LEFT")
  row.label = label
  index = index + 1
end

local function fontPath()
  if STANDARD_TEXT_FONT then
    return STANDARD_TEXT_FONT
  end
  return "Fonts\\FRIZQT__.TTF"
end

local function rowVisible(row)
  if row.group and not Balf.Ecs.shown(row.group) then
    return false
  end
  if row.parent and not Balf.Ecs.shown(row.parent) then
    return false
  end
  if row.school and not Balf.Ecs.shown(row.school) then
    return false
  end
  if not Balf.Ecs.shown(row.ref) then
    return false
  end
  if row.show and not row.show() then
    return false
  end
  if not row.header and row.value() == nil then
    return false
  end
  return true
end

local function paint()
  local general = Balf.Ecs.general()
  local path = fontPath()
  local y = 0
  index = 1
  while index <= table.getn(rows) do
    local row = rows[index]
    if rowVisible(row) then
      if row.header and not row.group and y < 0 then
        y = y - 8
      end
      local left = 4 + Balf.Ecs.rowDepth(row) * 12
      row.label:Show()
      row.label:ClearAllPoints()
      row.label:SetPoint("TOPLEFT", child, "TOPLEFT", left, y)
      if row.header then
        row.label:SetFont(path, general.headerFontSize)
        row.label:SetText(row.header)
        y = y - 18
      else
        row.label:SetFont(path, general.statFontSize)
        row.label:SetText(Balf.Ecs.formatStat(row.text, row.value(), row.textColor, row.statColor))
        y = y - 15
      end
    elseif row.label then
      row.label:Hide()
      row.label:ClearAllPoints()
    end
    index = index + 1
  end
  Balf.Ecs.fitScroll(scroll, child, -y + 8)
end

Balf.Ecs.paint = paint

local function applyWindow()
  local general = Balf.Ecs.general()
  local width = general.window.width
  local height = general.window.height
  window:SetWidth(width)
  window:SetHeight(height)
  window:ClearAllPoints()
  window:SetPoint("LEFT", PaperDollFrame, "RIGHT", general.window.xOffset, general.window.yOffset)
  settings:SetWidth(width - 16)
  child:SetWidth(width - 44)
  if window.SetBackdrop then
    window:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      tileSize = 16,
      edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    window:SetBackdropColor(0, 0, 0, 0.85)
  end
end

Balf.Ecs.applyWindow = applyWindow

local toggle = CreateFrame("Button", "ECS_ToggleButton", PaperDollFrame, "UIPanelButtonTemplate")
toggle:SetWidth(44)
toggle:SetHeight(18)
toggle:SetPoint("BOTTOMRIGHT", PaperDollFrame, "BOTTOMRIGHT", -38, 87)

local function updateToggleText()
  if window:IsShown() then
    toggle:SetText("< ECS")
  else
    toggle:SetText("ECS >")
  end
end

toggle:SetScript("OnClick", function()
  if window:IsShown() then
    window:Hide()
  else
    window:Show()
    Balf.Ecs.invalidate()
    paint()
  end
  updateToggleText()
end)

local function onPaperDoll()
  if Balf.Ecs.general().statsWindowClosedOnOpen then
    window:Hide()
    updateToggleText()
    return
  end
  window:Show()
  Balf.Ecs.invalidate()
  applyWindow()
  paint()
  updateToggleText()
end

Balf.Hook("PaperDollFrame_OnShow", function(previous)
  previous()
  onPaperDoll()
end)

local function changed(unit)
  if unit and unit ~= "player" then
    return
  end
  if event == "CHARACTER_POINTS_CHANGED" then
    Balf.Ecs.invalidateTalents()
  end
  Balf.Ecs.invalidate()
  Balf.Ecs.updateGearColors()
  if window:IsShown() then
    paint()
  end
end

Balf.Events.On("UNIT_INVENTORY_CHANGED", changed)
Balf.Events.On("UNIT_AURA", changed)
Balf.Events.On("PLAYER_AURAS_CHANGED", changed)
Balf.Events.On("CHARACTER_POINTS_CHANGED", changed)
Balf.Events.On("UNIT_STATS", changed)
Balf.Events.On("PLAYER_DAMAGE_DONE_MODS", changed)

local loginAt
local loginMarks = { 5, 15, 30 }

local function onLogin()
  loginAt = GetTime()
  loginMarks = { 5, 15, 30 }
  Balf.Ecs.invalidate()
  Balf.Ecs.invalidateTalents()
end

local function onUpdate()
  if not loginAt then
    return
  end
  local waited = GetTime() - loginAt
  if loginMarks[1] and waited >= loginMarks[1] then
    table.remove(loginMarks, 1)
    Balf.Ecs.invalidate()
    Balf.Ecs.updateGearColors()
    if window:IsShown() then
      paint()
    end
  end
  if table.getn(loginMarks) == 0 then
    Balf.Events.Off("UPDATE", onUpdate)
  end
end

function Balf.Ecs.refresh()
  applyWindow()
  paint()
  Balf.Ecs.updateGearColors()
  updateToggleText()
  if Balf.Ecs.paintConfig then
    Balf.Ecs.paintConfig()
  end
end

window:Hide()
applyWindow()
updateToggleText()

Balf.Events.On("PLAYER_ENTERING_WORLD", function()
  onLogin()
  Balf.Events.Off("UPDATE", onUpdate)
  Balf.Events.On("UPDATE", onUpdate)
  Balf.Ecs.updateGearColors()
  if PaperDollFrame:IsVisible() then
    onPaperDoll()
  end
end)

-- Saved settings. The global name matches the 1.14 addon.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

local function defaults()
  return {
    statsWindowClosedOnOpen = false,
    addColorsToStatTexts = true,
    statColorSelection = "full",
    showQualityColors = true,
    qualityColorsIntensity = 0.75,
    headerFontSize = 11,
    statFontSize = 10,
    window = {
      height = 422,
      width = 195,
      xOffset = -30,
      yOffset = 30,
    },
  }
end

function Balf.Ecs.db()
  if not ExtendedCharacterStats or type(ExtendedCharacterStats) ~= "table" then
    ExtendedCharacterStats = {}
  end
  if not ExtendedCharacterStats.general then
    ExtendedCharacterStats.general = defaults()
  end
  if not ExtendedCharacterStats.general.window then
    ExtendedCharacterStats.general.window = defaults().window
  end
  if not ExtendedCharacterStats.shown then
    ExtendedCharacterStats.shown = {}
  end
  return ExtendedCharacterStats
end

function Balf.Ecs.general()
  return Balf.Ecs.db().general
end

-- Until a checkbox is saved. Melee is classes that fight up close. Ranged is a bow,
-- gun, crossbow, or thrown weapon. A school is one the class has a damage or
-- heal spell in. Holy Fire is holy, so priests have no fire. Starshards is a
-- night elf racial, so priests have no arcane. Weapon hits and poisons stay
-- under melee, and physical spell damage stays off.
local MELEE_CLASS = {
  [1] = true,
  [2] = true,
  [3] = true,
  [4] = true,
  [7] = true,
  [11] = true,
}

local RANGED_CLASS = {
  [1] = true,
  [3] = true,
  [4] = true,
}

local CLASS_SCHOOL = {
  [2] = { Holy = true },
  [3] = { Arcane = true, Fire = true, Nature = true, Shadow = true },
  [5] = { Holy = true, Shadow = true },
  [7] = { Fire = true, Frost = true, Nature = true },
  [8] = { Arcane = true, Fire = true, Frost = true },
  [9] = { Fire = true, Shadow = true },
  [11] = { Arcane = true, Nature = true },
}

function Balf.Ecs.defaultShown(ref)
  local classId = Balf.Ecs.classId()
  if not classId or classId == 0 then
    return true
  end
  if ref == "MeleeHeader" then
    return MELEE_CLASS[classId] and true or false
  end
  if ref == "RangedHeader" then
    return RANGED_CLASS[classId] and true or false
  end
  if ref == "SpellHeader" then
    return CLASS_SCHOOL[classId] and true or false
  end
  if string.sub(ref, -6) == "School" then
    local schools = CLASS_SCHOOL[classId]
    if not schools then
      return false
    end
    return schools[string.sub(ref, 1, -7)] and true or false
  end
  return true
end

function Balf.Ecs.shown(ref)
  local flag = Balf.Ecs.db().shown[ref]
  if flag == nil then
    return Balf.Ecs.defaultShown(ref)
  end
  return flag
end

function Balf.Ecs.setShown(ref, value)
  Balf.Ecs.db().shown[ref] = value and true or false
end

local function asNumber(value)
  if type(value) == "number" then
    return value
  end
  return 0
end

function Balf.Ecs.fitScroll(scroll, child, height)
  if not height or height < 1 then
    height = 1
  end
  child:SetHeight(1)
  child:SetHeight(height)
  if scroll.UpdateScrollChildRect then
    scroll:UpdateScrollChildRect()
  end
  local range = height - asNumber(scroll:GetHeight())
  if scroll.GetVerticalScrollRange then
    local reported = scroll:GetVerticalScrollRange()
    if type(reported) == "number" then
      range = reported
    end
  end
  if range < 0 then
    range = 0
  end
  if asNumber(scroll:GetVerticalScroll()) > range then
    scroll:SetVerticalScroll(range)
  end
end

function Balf.Ecs.colorize(text, color)
  return "|cFF" .. color .. text .. "|r"
end

function Balf.Ecs.formatStat(label, value, textColor, statColor)
  local general = Balf.Ecs.general()
  local labelColor = "A8A8A8"
  local valueColor = "FFFFFF"
  if general.addColorsToStatTexts then
    labelColor = textColor or "be9c91"
    valueColor = statColor or "8d6e63"
    if general.statColorSelection == "texts" then
      valueColor = "FFFFFF"
    elseif general.statColorSelection == "values" then
      labelColor = "A8A8A8"
    end
  end
  return Balf.Ecs.colorize(label .. ": ", labelColor) .. Balf.Ecs.colorize(value, valueColor)
end

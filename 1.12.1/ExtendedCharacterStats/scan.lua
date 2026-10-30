-- Reads worn gear and auras into the line totals. UnitBuff has no spell id, so the
-- text is the record. The line patterns live in lines.lua.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

local tip
local cached
local cachedAt

local function scanningTooltip()
  if not tip and CreateFrame then
    tip = CreateFrame("GameTooltip", "Balf_EcsTip", nil, "GameTooltipTemplate")
    tip:SetOwner(WorldFrame, "ANCHOR_NONE")
  end
  return tip
end

function Balf.Ecs.buffText(index)
  local tooltip = scanningTooltip()
  if not tooltip or not tooltip.SetUnitBuff then
    return ""
  end
  tooltip:ClearLines()
  tooltip:SetUnitBuff("player", index)
  local text = ""
  local i = 1
  while i <= tooltip:NumLines() do
    local left = getglobal(tooltip:GetName() .. "TextLeft" .. i)
    local line = left and left:GetText()
    if line then
      if text == "" then
        text = line
      else
        text = text .. " " .. line
      end
    end
    i = i + 1
  end
  return text
end

local function setPrefix()
  if ITEM_SET_BONUS then
    return string.gsub(ITEM_SET_BONUS, "%%s", "")
  end
  return "Set: "
end

local function appendTooltip(lines, tooltip, allowSet, aura)
  local prefix = setPrefix()
  local i = 1
  while i <= tooltip:NumLines() do
    local left = getglobal(tooltip:GetName() .. "TextLeft" .. i)
    local text = left and left:GetText()
    if text then
      local isSet = allowSet and string.find(text, prefix, 1, true) ~= nil
      local r, g, b = 1, 1, 1
      if left.GetTextColor then
        r, g, b = left:GetTextColor()
      end
      table.insert(lines, {
        text = text,
        isSet = isSet,
        isActive = r < 0.2 and g > 0.8 and b < 0.2,
        aura = aura,
      })
    end
    i = i + 1
  end
end

local function readAuras(lines, harmful)
  local tooltip = scanningTooltip()
  if not tooltip then
    return
  end
  if harmful and not UnitDebuff then
    return
  end
  if not harmful and not UnitBuff then
    return
  end
  local i = 1
  while true do
    local name
    if harmful then
      name = UnitDebuff("player", i)
    else
      name = UnitBuff("player", i)
    end
    if not name then
      return
    end
    tooltip:ClearLines()
    if harmful then
      tooltip:SetUnitDebuff("player", i)
    else
      tooltip:SetUnitBuff("player", i)
    end
    appendTooltip(lines, tooltip, false, name)
    i = i + 1
  end
end

function Balf.Ecs.slotText(slot)
  local tooltip = scanningTooltip()
  if not tooltip or not tooltip.SetInventoryItem then
    return ""
  end
  tooltip:ClearLines()
  if not tooltip:SetInventoryItem("player", slot) then
    return ""
  end
  local text = ""
  local i = 1
  while i <= tooltip:NumLines() do
    local left = getglobal(tooltip:GetName() .. "TextLeft" .. i)
    local line = left and left:GetText()
    if line then
      if text == "" then
        text = line
      else
        text = text .. " " .. line
      end
    end
    i = i + 1
  end
  return text
end

function Balf.Ecs.invalidate()
  cached = nil
end

function Balf.Ecs.stats()
  local now = GetTime and GetTime() or 0
  if cached and now - cachedAt < 2 then
    return cached
  end
  local lines = {}
  local tooltip = scanningTooltip()
  if tooltip and GetInventoryItemLink then
    local slot = 1
    while slot <= 19 do
      tooltip:ClearLines()
      if tooltip:SetInventoryItem("player", slot) then
        appendTooltip(lines, tooltip, true)
      end
      slot = slot + 1
    end
  end
  local auras = {}
  readAuras(auras, false)
  readAuras(auras, true)
  local gear = Balf.Ecs.sumLines(lines)
  local auraStats = Balf.Ecs.sumLines(auras)
  local spring = {}
  local auraIndex = 1
  while auraIndex <= table.getn(auras) do
    if auras[auraIndex].aura == "Mana Spring" then
      table.insert(spring, auras[auraIndex])
    end
    auraIndex = auraIndex + 1
  end
  gear.gearMp5 = gear.mp5
  gear.auraMp5 = auraStats.mp5
  gear.manaSpring = Balf.Ecs.sumLines(spring).periodic
  Balf.Ecs.mergeStats(gear, auraStats)
  cached = gear
  cachedAt = now
  return cached
end

function Balf.Ecs.itemId(link)
  if not link then
    return nil
  end
  local _, _, id = string.find(link, "item:(%d+)")
  return tonumber(id)
end

function Balf.Ecs.enchantId(link)
  if not link then
    return nil
  end
  local _, _, _, enchant = string.find(link, "item:(%d+):(%d+)")
  return tonumber(enchant)
end

local talentRanks

function Balf.Ecs.invalidateTalents()
  talentRanks = nil
end

function Balf.Ecs.talent(name)
  if not talentRanks then
    talentRanks = {}
    if GetNumTalentTabs then
      local tab = 1
      while tab <= GetNumTalentTabs() do
        local index = 1
        while index <= GetNumTalents(tab) do
          local talentName, _, _, _, rank = GetTalentInfo(tab, index)
          if talentName then
            talentRanks[talentName] = rank or 0
          end
          index = index + 1
        end
        tab = tab + 1
      end
    end
  end
  return talentRanks[name] or 0
end

function Balf.Ecs.classId()
  if not UnitClass then
    return nil
  end
  local _, _, id = UnitClass("player")
  return id
end

function Balf.Ecs.buffNamed(name)
  if not UnitBuff then
    return false
  end
  local i = 1
  while true do
    local aura = UnitBuff("player", i)
    if not aura then
      return false
    end
    if aura == name then
      return true
    end
    i = i + 1
  end
end

function Balf.Ecs.shapeshifted()
  return Balf.Ecs.buffNamed("Cat Form") or Balf.Ecs.buffNamed("Bear Form") or Balf.Ecs.buffNamed("Dire Bear Form")
end

function Balf.Ecs.shieldEquipped()
  local link = GetInventoryItemLink and GetInventoryItemLink("player", 17)
  if not link or not GetItemInfo then
    return false
  end
  local _, _, _, _, _, _, subType = GetItemInfo(link)
  return subType == "Shields"
end

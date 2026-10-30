-- Mana per 5. Spirit regen is the server table. Item and buff mana are tooltip
-- lines, because GetManaRegen and GetItemStats do not exist. The Earthshatterer
-- 8-piece is conditional on Lightning Shield, so the line alone is not enough.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

local EARTHSHATTERER = {
  [22464] = true,
  [22465] = true,
  [22466] = true,
  [22467] = true,
  [22468] = true,
  [22469] = true,
  [22470] = true,
  [22471] = true,
  [23065] = true,
}

local function earthshattererPieces()
  if not GetInventoryItemLink then
    return 0
  end
  local count = 0
  local slot = 1
  while slot <= 17 do
    local id = Balf.Ecs.itemId(GetInventoryItemLink("player", slot))
    if id and EARTHSHATTERER[id] then
      count = count + 1
    end
    slot = slot + 1
  end
  return count
end

local function earthshatterer()
  if earthshattererPieces() >= 8 and Balf.Ecs.buffNamed("Lightning Shield") then
    return 15
  end
  return 0
end

-- Wisdom and Mana Spring restore mana on a timer. The 4-piece adds 25% to Mana Spring only.
local function periodicMana()
  local stats = Balf.Ecs.stats()
  local periodic = stats.periodic or 0
  local spring = stats.manaSpring or 0
  if earthshattererPieces() >= 4 then
    periodic = periodic + spring * 0.25
  end
  return periodic
end

local function castingShare()
  local share = Balf.Ecs.stats().casting
  local classId = Balf.Ecs.classId()
  if classId == 5 then
    share = share + 0.05 * Balf.Ecs.talent("Meditation")
  elseif classId == 8 then
    share = share + 0.05 * Balf.Ecs.talent("Arcane Meditation")
  elseif classId == 11 then
    share = share + 0.05 * Balf.Ecs.talent("Reflection")
  end
  if share > 1 then
    return 1
  end
  return share
end

function Balf.Ecs.hasMana()
  local classId = Balf.Ecs.classId()
  return classId ~= 1 and classId ~= 4
end

function Balf.Ecs.mp5Items()
  return Balf.Ecs.round(Balf.Ecs.stats().gearMp5 or 0, 2)
end

function Balf.Ecs.mp5Buffs()
  return Balf.Ecs.round((Balf.Ecs.stats().auraMp5 or 0) + earthshatterer(), 2)
end

function Balf.Ecs.mp5Spirit()
  local _, spirit = UnitStat("player", 5)
  return Balf.Ecs.round(Balf.Ecs.spiritMp5(Balf.Ecs.classId(), spirit), 2)
end

function Balf.Ecs.mp5Casting()
  local flat = Balf.Ecs.mp5Items() + Balf.Ecs.mp5Buffs()
  return Balf.Ecs.round(Balf.Ecs.mp5Spirit() * castingShare() + flat + periodicMana(), 2)
end

function Balf.Ecs.mp5NotCasting()
  return Balf.Ecs.round(Balf.Ecs.mp5Spirit() + Balf.Ecs.mp5Items() + Balf.Ecs.mp5Buffs() + periodicMana(), 2)
end

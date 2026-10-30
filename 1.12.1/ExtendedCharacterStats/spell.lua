-- Spells. There is no GetSpellBonusDamage, GetSpellCritChance, GetSpellHitModifier,
-- or GetSpellPenetration. Flat bonuses are the equip and aura lines. Crit from
-- intellect is the server rule.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

local BENEDICTION = 18608

local TEN_STORMS = {
  [16943] = true,
  [16944] = true,
  [16945] = true,
  [16946] = true,
  [16947] = true,
  [16948] = true,
  [16949] = true,
  [16950] = true,
}

local function level()
  return UnitLevel("player")
end

local function intellect()
  local _, value = UnitStat("player", 4)
  return value or 0
end

local function spellHit(school)
  local hit = Balf.Ecs.stats().spellHit
  local classId = Balf.Ecs.classId()
  if classId == 7 then
    hit = hit + Balf.Ecs.talent("Nature's Guidance")
  elseif classId == 8 then
    if school == Balf.Ecs.ARCANE then
      hit = hit + 2 * Balf.Ecs.talent("Arcane Focus")
    elseif school == Balf.Ecs.FIRE or school == Balf.Ecs.FROST then
      hit = hit + 2 * Balf.Ecs.talent("Elemental Precision")
    end
  elseif classId == 5 and school == Balf.Ecs.SHADOW then
    hit = hit + 2 * Balf.Ecs.talent("Shadow Focus")
  end
  return hit
end

function Balf.Ecs.schoolHitText(school)
  return Balf.Ecs.percent(spellHit(school))
end

function Balf.Ecs.schoolMissText(school, levelDifference)
  return Balf.Ecs.percent(Balf.Ecs.spellMiss(levelDifference, spellHit(school)))
end

-- The 1.12 client has no spell-damage call. vMaNGOS folds spirit × percent into that field,
-- so a priest's Spiritual Guidance has to be added here. 5% of spirit per rank, cut down.
local function spiritualGuidance()
  if Balf.Ecs.classId() ~= 5 then
    return 0
  end
  local rank = Balf.Ecs.talent("Spiritual Guidance")
  if rank <= 0 then
    return 0
  end
  local _, spirit = UnitStat("player", 5)
  return math.floor((spirit or 0) * rank * 5 / 100)
end

-- Enchant 2628. A weapon line that already says the bonus is left to the tooltip scan.
local function wizardOil()
  local link = GetInventoryItemLink and GetInventoryItemLink("player", 16)
  if Balf.Ecs.enchantId(link) ~= 2628 then
    return 0, 0
  end
  local text = Balf.Ecs.slotText and Balf.Ecs.slotText(16) or ""
  local crit = 1
  local damage = 36
  -- Skip only the lines the tooltip scan already counts. "spell damage by up to" is not one of them.
  if string.find(text, "Spell Critical Strike", 1, true)
    or string.find(text, "Spell Critical chance", 1, true)
    or string.find(text, "spell critical chance", 1, true)
    or string.find(text, "critical strike with spells", 1, true)
    or string.find(text, "critical hit with a spell", 1, true)
  then
    crit = 0
  end
  if string.find(text, "Spell Damage +", 1, true)
    or string.find(text, "Healing and Spell Damage", 1, true)
    or string.find(text, "damage done by magical spells", 1, true)
  then
    damage = 0
  end
  return crit, damage
end

local function baseDamage()
  local stats = Balf.Ecs.stats()
  local _, oilDamage = wizardOil()
  return stats.damageAndHealing + stats.damageOnly + spiritualGuidance() + oilDamage
end

function Balf.Ecs.spellDamageText()
  return tostring(baseDamage())
end

function Balf.Ecs.healingText()
  local stats = Balf.Ecs.stats()
  -- Shared spell damage, including Spiritual Guidance, plus healing-only lines.
  return tostring(baseDamage() + stats.healingOnly)
end

function Balf.Ecs.schoolDamageText(school)
  if school == Balf.Ecs.PHYSICAL then
    return tostring(Balf.Ecs.round(Balf.Ecs.stats().school[school] or 0, 0))
  end
  local extra = Balf.Ecs.stats().school[school] or 0
  local total = baseDamage() + extra
  if extra > 0 then
    return total .. " (+" .. extra .. ")"
  end
  return tostring(total)
end

local function generalSpellCrit()
  local classId = Balf.Ecs.classId()
  local crit = Balf.Ecs.spellCritFromIntellect(classId, level(), intellect())
  crit = crit + Balf.Ecs.stats().spellCrit
  local oilCrit = wizardOil()
  crit = crit + oilCrit
  if classId == 8 then
    crit = crit + Balf.Ecs.talent("Arcane Instability")
  end
  if Balf.Ecs.buffNamed("Rallying Cry of the Dragonslayer") then
    crit = crit + 10
  end
  if Balf.Ecs.buffNamed("Moonkin Aura") then
    crit = crit + 3
  end
  return crit
end

local function combustionStacks()
  if not UnitBuff then
    return 0
  end
  local i = 1
  while true do
    local name, _, _, count = UnitBuff("player", i)
    if not name then
      return 0
    end
    if name == "Combustion" then
      return (count or 0) * 10
    end
    i = i + 1
  end
end

local function tenStormsBonus()
  if Balf.Ecs.classId() ~= 7 or not GetInventoryItemLink then
    return 0
  end
  local count = 0
  local slot = 1
  while slot <= 17 do
    local id = Balf.Ecs.itemId(GetInventoryItemLink("player", slot))
    if id and TEN_STORMS[id] then
      count = count + 1
    end
    slot = slot + 1
  end
  if count >= 5 then
    return 3
  end
  return 0
end

function Balf.Ecs.schoolCritText(school)
  local extra = Balf.Ecs.stats().schoolCrit[school] or 0
  local classId = Balf.Ecs.classId()
  if school == Balf.Ecs.FIRE then
    if classId == 8 then
      extra = extra + 2 * Balf.Ecs.talent("Critical Mass")
    elseif classId == 9 then
      extra = extra + Balf.Ecs.talent("Devastation")
    end
    extra = extra + combustionStacks()
    if Balf.Ecs.buffNamed("Fire Blast") then
      extra = extra + 50
    end
  elseif school == Balf.Ecs.HOLY then
    if classId == 2 then
      extra = extra + Balf.Ecs.talent("Holy Power")
    elseif classId == 5 then
      extra = extra + Balf.Ecs.talent("Holy Specialization")
    end
    if GetInventoryItemLink and Balf.Ecs.itemId(GetInventoryItemLink("player", 16)) == BENEDICTION then
      extra = extra + 2
    end
  elseif school == Balf.Ecs.NATURE then
    if classId == 7 then
      extra = extra + Balf.Ecs.talent("Tidal Mastery")
      extra = extra + tenStormsBonus()
    end
  end
  return Balf.Ecs.percent(generalSpellCrit() + extra)
end

function Balf.Ecs.hasteText()
  return Balf.Ecs.percent(Balf.Ecs.stats().haste)
end

function Balf.Ecs.penetrationText()
  local pen = Balf.Ecs.stats().spellPen
  if Balf.Ecs.classId() == 8 then
    pen = pen + 5 * Balf.Ecs.talent("Arcane Subtlety")
  end
  return tostring(Balf.Ecs.round(pen, 0))
end

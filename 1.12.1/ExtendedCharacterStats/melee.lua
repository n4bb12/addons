-- Melee. Attack power and speed are the client totals. Crit, hit, miss, and glancing
-- are not: GetCritChance and GetHitModifier are absent on 1.12.1.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

local function level()
  return UnitLevel("player")
end

local function agility()
  local _, value = UnitStat("player", 2)
  return value or 0
end

local function weaponSkill()
  local base, mod = UnitAttackBothHands("player")
  return (base or 0) + (mod or 0)
end

local function offhandSpeed()
  local _, off = UnitAttackSpeed("player")
  return off or 0
end

function Balf.Ecs.meleeHitAmount()
  local hit = Balf.Ecs.stats().physicalHit
  local classId = Balf.Ecs.classId()
  if classId == 3 then
    hit = hit + Balf.Ecs.talent("Surefooted")
  elseif classId == 7 then
    hit = hit + Balf.Ecs.talent("Nature's Guidance")
  elseif classId == 2 or classId == 4 then
    hit = hit + Balf.Ecs.talent("Precision")
  end
  return hit
end

function Balf.Ecs.meleeCritAmount()
  local classId = Balf.Ecs.classId()
  local playerLevel = level()
  local crit = Balf.Ecs.critFromAgility(classId, playerLevel, agility())
  crit = crit + Balf.Ecs.critFromWeaponSkill(weaponSkill(), playerLevel)
  crit = crit + Balf.Ecs.stats().meleeCrit
  if classId == 1 then
    crit = crit + Balf.Ecs.talent("Cruelty")
  elseif classId == 2 then
    crit = crit + Balf.Ecs.talent("Conviction")
  elseif classId == 4 then
    crit = crit + Balf.Ecs.talent("Malice")
  elseif classId == 3 then
    crit = crit + Balf.Ecs.talent("Killer Instinct")
  elseif classId == 7 then
    crit = crit + Balf.Ecs.talent("Thundering Strikes")
  elseif classId == 11 and Balf.Ecs.shapeshifted() then
    crit = crit + 2 * Balf.Ecs.talent("Sharpened Claws")
  end
  if Balf.Ecs.buffNamed("Rallying Cry of the Dragonslayer") then
    crit = crit + 5
  end
  local subType
  local link = GetInventoryItemLink("player", 16)
  if link and GetItemInfo then
    local _, _, _, _, _, _, weaponType = GetItemInfo(link)
    subType = weaponType
  end
  -- Subclass text is "One-Handed Axes", "Polearms", "Daggers", "Fist Weapons".
  if subType and classId == 1 and string.find(subType, "Axe", 1, true) then
    crit = crit + Balf.Ecs.talent("Axe Specialization")
  elseif subType and classId == 1 and string.find(subType, "Polearm", 1, true) then
    crit = crit + Balf.Ecs.talent("Polearm Specialization")
  elseif subType and classId == 4 and string.find(subType, "Dagger", 1, true) then
    crit = crit + Balf.Ecs.talent("Dagger Specialization")
  elseif subType and classId == 4 and string.find(subType, "Fist", 1, true) then
    crit = crit + Balf.Ecs.talent("Fist Weapon Specialization")
  end
  if crit < 0 then
    return 0
  end
  return crit
end

local function miss(extraLevels)
  local playerLevel = level()
  local defense = (playerLevel + extraLevels) * 5
  -- Cat and bear attack with level × 5 skill and no off-hand.
  local skill = weaponSkill()
  local dual = offhandSpeed() > 0
  if Balf.Ecs.shapeshifted() then
    skill = playerLevel * 5
    dual = false
  end
  return Balf.Ecs.whiteMiss(skill, defense, Balf.Ecs.meleeHitAmount(), dual)
end

function Balf.Ecs.meleeAttackPower()
  local base, pos, neg = UnitAttackPower("player")
  return (base or 0) + (pos or 0) + (neg or 0)
end

function Balf.Ecs.meleeSpeed()
  local main = UnitAttackSpeed("player")
  return Balf.Ecs.round(main or 0, 2)
end

function Balf.Ecs.canDualWield()
  local classId = Balf.Ecs.classId()
  if classId == 1 or classId == 4 then
    return true
  end
  return classId == 7 and Balf.Ecs.talent("Dual Wield") > 0
end

function Balf.Ecs.meleeOffhandSpeed()
  local off = offhandSpeed()
  if off <= 0 then
    return 0
  end
  return Balf.Ecs.round(off, 2)
end

function Balf.Ecs.meleeHit()
  return Balf.Ecs.percent(Balf.Ecs.meleeHitAmount())
end

function Balf.Ecs.meleeCrit()
  return Balf.Ecs.percent(Balf.Ecs.meleeCritAmount())
end

function Balf.Ecs.meleeMiss()
  return Balf.Ecs.percent(miss(0))
end

function Balf.Ecs.meleeMissBoss()
  return Balf.Ecs.percent(miss(3))
end

function Balf.Ecs.meleeGlance()
  local playerLevel = level()
  local chance = Balf.Ecs.glancingChance(playerLevel, weaponSkill(), playerLevel * 5)
  return Balf.Ecs.percent(chance * 100)
end

function Balf.Ecs.meleeGlanceBoss()
  local playerLevel = level()
  local chance = Balf.Ecs.glancingChance(playerLevel, weaponSkill(), (playerLevel + 3) * 5)
  return Balf.Ecs.percent(chance * 100)
end

function Balf.Ecs.meleeGlanceDamage()
  local playerLevel = level()
  local factor = Balf.Ecs.glancingDamage(weaponSkill(), playerLevel * 5)
  return Balf.Ecs.percent(factor * 100)
end

function Balf.Ecs.meleeGlanceDamageBoss()
  local playerLevel = level()
  local factor = Balf.Ecs.glancingDamage(weaponSkill(), (playerLevel + 3) * 5)
  return Balf.Ecs.percent(factor * 100)
end

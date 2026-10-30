-- Ranged. UnitRangedAttackPower is a real 1.12 field, unlike the 1.14 client
-- behind Hermes, where that call stays 0. Crit still has no API.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

local BIZNICK_SCOPE = 2523

function Balf.Ecs.hasRanged()
  return not (UnitHasRelicSlot and UnitHasRelicSlot("player"))
end

local function level()
  return UnitLevel("player")
end

local function agility()
  local _, value = UnitStat("player", 2)
  return value or 0
end

local function weaponSkill()
  local base, mod = UnitRangedAttack("player")
  return (base or 0) + (mod or 0)
end

function Balf.Ecs.rangedHitAmount()
  local hit = Balf.Ecs.stats().physicalHit + Balf.Ecs.stats().rangedHit
  local link = GetInventoryItemLink("player", 18)
  if Balf.Ecs.enchantId(link) == BIZNICK_SCOPE then
    hit = hit + 3
  end
  if Balf.Ecs.classId() == 3 then
    hit = hit + Balf.Ecs.talent("Surefooted")
  end
  return hit
end

function Balf.Ecs.rangedCritAmount()
  local classId = Balf.Ecs.classId()
  local playerLevel = level()
  local crit = Balf.Ecs.critFromAgility(classId, playerLevel, agility())
  crit = crit + Balf.Ecs.critFromWeaponSkill(weaponSkill(), playerLevel)
  crit = crit + Balf.Ecs.stats().rangedCrit
  if classId == 3 then
    crit = crit + Balf.Ecs.talent("Lethal Shots")
    crit = crit + Balf.Ecs.talent("Killer Instinct")
  elseif classId == 4 then
    crit = crit + Balf.Ecs.talent("Malice")
  elseif classId == 7 then
    crit = crit + Balf.Ecs.talent("Thundering Strikes")
  end
  if Balf.Ecs.buffNamed("Rallying Cry of the Dragonslayer") then
    crit = crit + 5
  end
  if crit < 0 then
    return 0
  end
  return crit
end

local function miss(extraLevels)
  local playerLevel = level()
  local defense = (playerLevel + extraLevels) * 5
  local skill = weaponSkill()
  return Balf.Ecs.whiteMiss(skill, defense, Balf.Ecs.rangedHitAmount(), false)
end

function Balf.Ecs.rangedAttackPower()
  local base, pos, neg = UnitRangedAttackPower("player")
  local fromApi = (base or 0) + (pos or 0) + (neg or 0)
  if fromApi ~= 0 then
    return fromApi
  end
  local stats = Balf.Ecs.stats()
  local total = Balf.Ecs.baseRangedAttackPower(Balf.Ecs.classId(), level(), agility(), Balf.Ecs.shapeshifted())
  total = total + (stats.attackPower or 0) + (stats.rangedAttackPower or 0)
  if total < 0 then
    return 0
  end
  return math.floor(total)
end

function Balf.Ecs.rangedSpeed()
  local speed = UnitRangedDamage("player")
  return Balf.Ecs.round(speed or 0, 2)
end

function Balf.Ecs.rangedHit()
  if not Balf.Ecs.hasRanged() then
    return nil
  end
  return Balf.Ecs.percent(Balf.Ecs.rangedHitAmount())
end

function Balf.Ecs.rangedCrit()
  if not Balf.Ecs.hasRanged() then
    return nil
  end
  return Balf.Ecs.percent(Balf.Ecs.rangedCritAmount())
end

function Balf.Ecs.rangedMiss()
  if not Balf.Ecs.hasRanged() then
    return nil
  end
  return Balf.Ecs.percent(miss(0))
end

function Balf.Ecs.rangedMissBoss()
  if not Balf.Ecs.hasRanged() then
    return nil
  end
  return Balf.Ecs.percent(miss(3))
end

function Balf.Ecs.rangedAttackPowerText()
  if not Balf.Ecs.hasRanged() then
    return nil
  end
  return tostring(Balf.Ecs.rangedAttackPower())
end

function Balf.Ecs.rangedSpeedText()
  if not Balf.Ecs.hasRanged() then
    return nil
  end
  return tostring(Balf.Ecs.rangedSpeed())
end

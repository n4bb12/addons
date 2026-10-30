-- Defense. Dodge, parry, block chance, armor, and defense are client totals.
-- Block value is not: there is no GetShieldBlock.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

local PARRY = { [1] = true, [2] = true, [3] = true, [4] = true, [7] = true }
local BLOCK = { [1] = true, [2] = true, [7] = true }

local function level()
  return UnitLevel("player")
end

local function defense()
  local base, mod = UnitDefense("player")
  return (base or 0) + (mod or 0)
end

local function canBlock()
  return BLOCK[Balf.Ecs.classId()] and Balf.Ecs.shieldEquipped()
end

function Balf.Ecs.armorText()
  local _, effective = UnitArmor("player")
  return tostring(Balf.Ecs.round(effective or 0, 0))
end

function Balf.Ecs.defenseText()
  return tostring(defense())
end

local function critReduction()
  local above = defense() - level() * 5
  if above < 0 then
    above = 0
  end
  return above / 25
end

local function sleightOfHand()
  if Balf.Ecs.classId() == 4 then
    return Balf.Ecs.talent("Sleight of Hand")
  end
  return 0
end

function Balf.Ecs.meleeCritReductionText()
  return Balf.Ecs.percent(critReduction() + sleightOfHand())
end

function Balf.Ecs.rangedCritReductionText()
  return Balf.Ecs.percent(critReduction() + sleightOfHand())
end

function Balf.Ecs.spellCritReductionText()
  return Balf.Ecs.percent(0)
end

local function enemyMiss(enemyLevel)
  return 5 + (defense() - enemyLevel * 5) * 0.04
end

local function dodge(enemyLevel)
  return (GetDodgeChance() or 0) + (level() - enemyLevel) * 0.2
end

local function parry(enemyLevel)
  if not PARRY[Balf.Ecs.classId()] then
    return nil
  end
  return (GetParryChance() or 0) + (level() - enemyLevel) * 0.2
end

local function block(enemyLevel)
  if not canBlock() then
    return nil
  end
  return (GetBlockChance() or 0) + (level() - enemyLevel) * 0.2
end

local function avoidance(enemyLevel)
  local total = enemyMiss(enemyLevel) + dodge(enemyLevel)
  local parryChance = parry(enemyLevel)
  local blockChance = block(enemyLevel)
  if parryChance then
    total = total + parryChance
  end
  if blockChance then
    total = total + blockChance
  end
  return total
end

function Balf.Ecs.dodgeText()
  return Balf.Ecs.percent(dodge(level()))
end

function Balf.Ecs.parryText()
  local chance = parry(level())
  if not chance then
    return nil
  end
  return Balf.Ecs.percent(chance)
end

function Balf.Ecs.blockChanceText()
  local chance = block(level())
  if not chance then
    return nil
  end
  return Balf.Ecs.percent(chance)
end

local function shieldBlockMultiplier()
  local classId = Balf.Ecs.classId()
  if classId == 2 then
    return 1 + 0.10 * Balf.Ecs.talent("Shield Specialization")
  elseif classId == 7 then
    return 1 + 0.05 * Balf.Ecs.talent("Shield Specialization")
  end
  return 1
end

function Balf.Ecs.blockValueText()
  if not canBlock() then
    return nil
  end
  local _, strength = UnitStat("player", 1)
  return tostring(Balf.Ecs.blockValue(Balf.Ecs.stats().block, strength, shieldBlockMultiplier()))
end

function Balf.Ecs.enemyMissText()
  return Balf.Ecs.percent(enemyMiss(level()))
end

function Balf.Ecs.enemyMissBossText()
  return Balf.Ecs.percent(enemyMiss(level() + 3))
end

function Balf.Ecs.avoidanceText()
  return Balf.Ecs.percent(avoidance(level()))
end

function Balf.Ecs.avoidanceBossText()
  return Balf.Ecs.percent(avoidance(level() + 3))
end

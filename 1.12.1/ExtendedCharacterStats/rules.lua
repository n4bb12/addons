-- Pure combat rules. The 1.12.1 client never exposes these as Lua calls, so the
-- window computes them the way vMaNGOS does.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

Balf.Ecs.PHYSICAL = 1
Balf.Ecs.HOLY = 2
Balf.Ecs.FIRE = 3
Balf.Ecs.NATURE = 4
Balf.Ecs.FROST = 5
Balf.Ecs.SHADOW = 6
Balf.Ecs.ARCANE = 7

Balf.Ecs.SCHOOL = {
  Physical = Balf.Ecs.PHYSICAL,
  Holy = Balf.Ecs.HOLY,
  Fire = Balf.Ecs.FIRE,
  Nature = Balf.Ecs.NATURE,
  Frost = Balf.Ecs.FROST,
  Shadow = Balf.Ecs.SHADOW,
  Arcane = Balf.Ecs.ARCANE,
}

-- Agility per 1% melee and ranged crit at level 60 (vMaNGOS player_crit_per_agility,
-- the Wowhead row; the hunter value is the client's 52.91). The client has the
-- per-level table and no Lua call that reads it. The divisor grows with level the
-- same way spell crit's does, so level 60 is that row and a lower level is the
-- same fraction of it. A warrior at 60 needs 20 agility; at level 1, about 5.7.
local AGI_PER_CRIT_60 = {
  [1] = 20,
  [2] = 20,
  [3] = 52.91,
  [4] = 29,
  [5] = 20,
  [7] = 20,
  [8] = 20,
  [9] = 20,
  [11] = 20,
}

-- Added on top of agility. Player::UpdateCritPercentage.
local MELEE_CRIT_BASE = {
  [2] = 0.7,
  [8] = 3.2,
  [5] = 3.0,
  [7] = 1.7,
  [9] = 2.0,
  [11] = 0.9,
}

-- Unit::GetSpellCritFromIntellect. Classes missing here gain none from intellect.
local SPELL_CRIT = {
  [2] = { base = 3.70, rate0 = 14.77, rate1 = 0.65 },
  [5] = { base = 2.97, rate0 = 10.03, rate1 = 0.82 },
  [7] = { base = 3.54, rate0 = 11.51, rate1 = 0.80 },
  [8] = { base = 3.70, rate0 = 14.77, rate1 = 0.65 },
  [9] = { base = 3.18, rate0 = 11.30, rate1 = 0.82 },
  [11] = { base = 3.33, rate0 = 12.41, rate1 = 0.79 },
}

-- Unit::GetRegenMPPerSpirit. Mana per 2 second tick is spirit / divisor + flat.
local SPIRIT_REGEN = {
  [2] = { divisor = 5, flat = 15 },
  [3] = { divisor = 5, flat = 15 },
  [5] = { divisor = 4, flat = 12.5 },
  [7] = { divisor = 5, flat = 17 },
  [8] = { divisor = 4, flat = 12.5 },
  [9] = { divisor = 5, flat = 15 },
  [11] = { divisor = 5, flat = 15 },
}

local function spellDivisorShape(level)
  local mage = SPELL_CRIT[8]
  return (mage.rate0 + mage.rate1 * level) / (mage.rate0 + mage.rate1 * 60)
end

function Balf.Ecs.round(num, places)
  if not num then
    return 0
  end
  local mult = 10 ^ places
  return math.floor(num * mult + 0.5) / mult
end

function Balf.Ecs.percent(num)
  return Balf.Ecs.round(num, 2) .. "%"
end

function Balf.Ecs.agiPerCrit(classId, level)
  local at60 = AGI_PER_CRIT_60[classId]
  if not at60 then
    return 0
  end
  if not level or level < 1 then
    level = 1
  end
  return at60 * spellDivisorShape(level)
end

function Balf.Ecs.critFromAgility(classId, level, agility)
  local rate = Balf.Ecs.agiPerCrit(classId, level)
  if rate == 0 then
    return 0
  end
  return (agility or 0) / rate + (MELEE_CRIT_BASE[classId] or 0)
end

-- (weapon skill - 5 per level) * 0.04, from UpdateCritPercentage.
function Balf.Ecs.critFromWeaponSkill(skill, level)
  return ((skill or 0) - (level or 0) * 5) * 0.04
end

function Balf.Ecs.spellCritFromIntellect(classId, level, intellect)
  local rule = SPELL_CRIT[classId]
  if not rule or not level or level < 1 then
    return 0
  end
  return rule.base + (intellect or 0) / (rule.rate0 + rule.rate1 * level)
end

function Balf.Ecs.spiritMp5(classId, spirit)
  local rule = SPIRIT_REGEN[classId]
  if not rule then
    return 0
  end
  local perTick = (spirit or 0) / rule.divisor + rule.flat
  return perTick / 2 * 5
end

-- Player::GetShieldBlockValue. Gear block is the shield line plus enchants.
-- Paladin Shield Specialization is 10% per rank, shaman 5% per rank, applied
-- before the value is cut to a whole number.
function Balf.Ecs.blockValue(gearBlock, strength, multiplier)
  return math.floor(math.max(0, ((gearBlock or 0) + (strength or 0) / 20 - 1) * (multiplier or 1)))
end

-- White-hit miss against a creature, before dual wield and hit.
-- SpellCaster::GetMeleeMissChance: 5% plus 0.1% per point of defense above weapon
-- skill, or 0.2% for the whole gap once that gap is more than 10. A level-63 boss
-- (315 defense, 300 skill) is 8% at 0 hit.
function Balf.Ecs.missChance(weaponSkill, defenseValue)
  local delta = defenseValue - weaponSkill
  if delta > 10 then
    return 5 + delta * 0.2
  end
  return 5 + delta * 0.1
end

-- The same function drops the first 1% of hit when the gap is more than 10.
-- One point of hit against a boss still leaves the 8% miss. Nine points clear it.
-- Miss stays between 0 and 60.
function Balf.Ecs.missAfterHit(chance, hit, delta)
  hit = hit or 0
  if (delta or 0) > 10 and hit > 0 then
    hit = hit - 1
  end
  chance = (chance or 0) - hit
  if chance < 0 then
    return 0
  elseif chance > 60 then
    return 60
  end
  return chance
end

-- Dual wield adds 19% before the low-level scale. A victim under level 10 scales
-- that whole miss by level / 10, and hit is subtracted after the scale.
function Balf.Ecs.whiteMiss(weaponSkill, defenseValue, hit, dualWield)
  local delta = defenseValue - weaponSkill
  local miss = Balf.Ecs.missChance(weaponSkill, defenseValue)
  if dualWield then
    miss = miss + 19
  end
  local victimLevel = (defenseValue or 0) / 5
  if victimLevel > 0 and victimLevel < 10 then
    miss = miss * victimLevel / 10
  end
  return Balf.Ecs.missAfterHit(miss, hit, delta)
end

-- Unit::GetAttackPowerFromStrengthAndAgility, ranged. A druid in cat or bear
-- has no base. Every other class is agility - 10, and hunter, rogue, and
-- warrior add level on top of that.
function Balf.Ecs.baseRangedAttackPower(classId, level, agility, shapeshifted)
  level = level or 0
  agility = agility or 0
  if classId == 3 then
    return level * 2 + agility * 2 - 10
  elseif classId == 1 or classId == 4 then
    return level + agility - 10
  elseif classId == 11 and shapeshifted then
    return 0
  end
  return agility - 10
end

function Balf.Ecs.glancingChance(level, weaponSkill, defenseValue)
  local chance = 0.1 + (defenseValue - math.min(level * 5, weaponSkill)) * 0.02
  if chance > 1 then
    return 1
  end
  return chance
end

function Balf.Ecs.glancingDamage(weaponSkill, defenseValue)
  local difference = defenseValue - weaponSkill
  local low = math.min(0.91, 1.3 - 0.05 * difference)
  if low < 0.01 then
    low = 0.01
  end
  local high = 1.2 - 0.03 * difference
  if high > 0.99 then
    high = 0.99
  elseif high < 0.2 then
    high = 0.2
  end
  local average = (high + low) / 2
  if average < 0 then
    return 0
  end
  return average
end

-- MagicSpellHitChance for an NPC. Equal level is 4%. A boss (+3) is 17%.
-- Hit never falls below 22%, so miss never rises above 78%.
function Balf.Ecs.spellMiss(levelDifference, hitBonus)
  local miss = 0
  if levelDifference >= -3 and levelDifference <= 2 then
    miss = 4 + levelDifference
  elseif levelDifference >= 3 then
    miss = 6 + 11 * (levelDifference - 2)
  end
  miss = miss - (hitBonus or 0)
  if miss < 1 then
    miss = 1
  elseif miss > 78 then
    miss = 78
  end
  return miss
end

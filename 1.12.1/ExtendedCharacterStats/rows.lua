-- The same rows as the 1.14 default profile, in the same order.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

local HIT = { "85bb5c", "558b2f" }
local CRIT = { "ff6659", "d32f2f" }
local POWER = { "ffd149", "ffa000" }
local SPEED = { "009688", "00766c" }
local MANA = { "5472d3", "0d47a1" }
local HASTE = { "c8a600", "ffd740" }
local HEAL = { "ffffff", "f5f5f5" }
local PLAIN = { "A8A8A8", "FFFFFF" }

local SCHOOLS = {
  { "Arcane", Balf.Ecs.ARCANE, "b4ffff", "80deea" },
  { "Fire", Balf.Ecs.FIRE, "ff5131", "d50000" },
  { "Frost", Balf.Ecs.FROST, "69e2ff", "00b0ff" },
  { "Holy", Balf.Ecs.HOLY, "ff9e40", "ffd600" },
  { "Nature", Balf.Ecs.NATURE, "9cff57", "64dd17" },
  { "Physical", Balf.Ecs.PHYSICAL, "9e9e9e", "cfcfcf" },
  { "Shadow", Balf.Ecs.SHADOW, "e254ff", "aa00ff" },
}

local function add(rows, row)
  table.insert(rows, row)
end

local function header(ref, text, group, sub)
  return { ref = ref, header = text, group = group, sub = sub }
end

function Balf.Ecs.rowDepth(row)
  if row.school or row.parent then
    return 2
  end
  if row.group then
    return 1
  end
  return 0
end

local function stat(ref, text, value, colors, group, parent, show)
  return {
    ref = ref,
    text = text,
    value = value,
    textColor = colors[1],
    statColor = colors[2],
    group = group,
    parent = parent,
    show = show,
  }
end

function Balf.Ecs.catalog()
  local rows = {}
  add(rows, header("GeneralHeader", "General"))
  add(rows, stat("MovementSpeed", "Movement Speed", function()
    return tostring(Balf.Ecs.round(100 + (Balf.Ecs.stats().speed or 0), 0)) .. "%"
  end, PLAIN, "GeneralHeader"))

  add(rows, header("MeleeHeader", "Melee"))
  add(rows, stat("MeleeAttackPower", "Attack Power", function()
    return tostring(Balf.Ecs.meleeAttackPower())
  end, POWER, "MeleeHeader"))
  add(rows, stat("MeleeCritChance", "Crit Chance", Balf.Ecs.meleeCrit, CRIT, "MeleeHeader"))
  add(rows, header("MeleeHitHeader", "Hit", "MeleeHeader", true))
  add(rows, stat("MeleeHitBonus", "Bonus", Balf.Ecs.meleeHit, HIT, "MeleeHeader", "MeleeHitHeader"))
  add(rows, stat("MeleeHitSameLevel", "Miss", Balf.Ecs.meleeMiss, HIT, "MeleeHeader", "MeleeHitHeader"))
  add(rows, stat("MeleeHitBossLevel", "Miss (Lvl + 3)", Balf.Ecs.meleeMissBoss, HIT, "MeleeHeader", "MeleeHitHeader"))
  add(rows, header("GlanceChanceHeader", "Glancing Blow", "MeleeHeader", true))
  add(rows, stat("GlanceHitChanceSameLevel", "Chance", Balf.Ecs.meleeGlance, PLAIN, "MeleeHeader", "GlanceChanceHeader"))
  add(rows, stat("GlanceDamageSameLevel", "Damage", Balf.Ecs.meleeGlanceDamage, PLAIN, "MeleeHeader", "GlanceChanceHeader"))
  add(rows, stat("GlanceHitChanceBossLevel", "Chance (Lvl + 3)", Balf.Ecs.meleeGlanceBoss, PLAIN, "MeleeHeader", "GlanceChanceHeader"))
  add(rows, stat("GlanceDamageBossLevel", "Damage (Lvl + 3)", Balf.Ecs.meleeGlanceDamageBoss, PLAIN, "MeleeHeader", "GlanceChanceHeader"))
  add(rows, header("MeleeAttackSpeedHeader", "Attack Speed", "MeleeHeader", true))
  add(rows, stat("MeleeAttackSpeedMainHand", "Main Hand", function()
    return tostring(Balf.Ecs.meleeSpeed())
  end, SPEED, "MeleeHeader", "MeleeAttackSpeedHeader"))
  add(rows, stat("MeleeAttackSpeedOffHand", "Off Hand", function()
    return tostring(Balf.Ecs.meleeOffhandSpeed())
  end, SPEED, "MeleeHeader", "MeleeAttackSpeedHeader", Balf.Ecs.canDualWield))

  add(rows, header("RangedHeader", "Ranged", nil, false))
  rows[table.getn(rows)].show = Balf.Ecs.hasRanged
  add(rows, stat("RangeAttackpower", "Attack Power", Balf.Ecs.rangedAttackPowerText, POWER, "RangedHeader", nil, Balf.Ecs.hasRanged))
  add(rows, stat("RangedCritChance", "Crit Chance", Balf.Ecs.rangedCrit, CRIT, "RangedHeader", nil, Balf.Ecs.hasRanged))
  add(rows, stat("RangedAttackSpeed", "Attack Speed", Balf.Ecs.rangedSpeedText, SPEED, "RangedHeader", nil, Balf.Ecs.hasRanged))
  add(rows, header("RangedHitHeader", "Hit", "RangedHeader", true))
  rows[table.getn(rows)].show = Balf.Ecs.hasRanged
  add(rows, stat("RangedHitBonus", "Bonus", Balf.Ecs.rangedHit, HIT, "RangedHeader", "RangedHitHeader", Balf.Ecs.hasRanged))
  add(rows, stat("RangedHitSameLevel", "Miss", Balf.Ecs.rangedMiss, HIT, "RangedHeader", "RangedHitHeader", Balf.Ecs.hasRanged))
  add(rows, stat("RangedHitBossLevel", "Miss (Lvl + 3)", Balf.Ecs.rangedMissBoss, HIT, "RangedHeader", "RangedHitHeader", Balf.Ecs.hasRanged))

  add(rows, header("DefenseHeader", "Defense"))
  add(rows, stat("Armor", "Armor", Balf.Ecs.armorText, PLAIN, "DefenseHeader"))
  add(rows, stat("MeleeCritReduction", "Melee Crit Reduction", Balf.Ecs.meleeCritReductionText, PLAIN, "DefenseHeader"))
  add(rows, stat("RangedCritReduction", "Ranged Crit Reduction", Balf.Ecs.rangedCritReductionText, PLAIN, "DefenseHeader"))
  add(rows, stat("SpellCritReduction", "Spell Crit Reduction", Balf.Ecs.spellCritReductionText, PLAIN, "DefenseHeader"))
  add(rows, stat("Avoidance", "Avoidance", Balf.Ecs.avoidanceText, PLAIN, "DefenseHeader"))
  add(rows, stat("AvoidanceBoss", "Avoidance (Lvl +3)", Balf.Ecs.avoidanceBossText, PLAIN, "DefenseHeader"))
  add(rows, stat("EnemyMissChance", "Enemy Miss", Balf.Ecs.enemyMissText, PLAIN, "DefenseHeader"))
  add(rows, stat("EnemyMissChanceBoss", "Enemy Miss (Lvl +3)", Balf.Ecs.enemyMissBossText, PLAIN, "DefenseHeader"))
  add(rows, stat("DefenseValue", "Defense", Balf.Ecs.defenseText, PLAIN, "DefenseHeader"))
  add(rows, stat("BlockChance", "Block Chance", Balf.Ecs.blockChanceText, PLAIN, "DefenseHeader"))
  add(rows, stat("BlockValue", "Block Value", Balf.Ecs.blockValueText, PLAIN, "DefenseHeader"))
  add(rows, stat("ParryChance", "Parry Chance", Balf.Ecs.parryText, PLAIN, "DefenseHeader"))
  add(rows, stat("DodgeChance", "Dodge Chance", Balf.Ecs.dodgeText, PLAIN, "DefenseHeader"))

  add(rows, header("ManaHeader", "Mana"))
  rows[table.getn(rows)].show = Balf.Ecs.hasMana
  add(rows, stat("MP5Items", "MP5 (Items)", function()
    return tostring(Balf.Ecs.mp5Items())
  end, MANA, "ManaHeader", nil, Balf.Ecs.hasMana))
  add(rows, stat("MP5Spirit", "MP5 (Spirit)", function()
    return tostring(Balf.Ecs.mp5Spirit())
  end, MANA, "ManaHeader", nil, Balf.Ecs.hasMana))
  add(rows, stat("MP5Buffs", "MP5 (Buffs)", function()
    return tostring(Balf.Ecs.mp5Buffs())
  end, MANA, "ManaHeader", nil, Balf.Ecs.hasMana))
  add(rows, stat("MP5Casting", "MP5 (Casting)", function()
    return tostring(Balf.Ecs.mp5Casting())
  end, MANA, "ManaHeader", nil, Balf.Ecs.hasMana))
  add(rows, stat("MP5NotCasting", "MP5 (Not casting)", function()
    return tostring(Balf.Ecs.mp5NotCasting())
  end, MANA, "ManaHeader", nil, Balf.Ecs.hasMana))

  add(rows, header("SpellHeader", "Spell"))
  add(rows, stat("SpellHasteBonus", "Haste Bonus", Balf.Ecs.hasteText, HASTE, "SpellHeader"))
  add(rows, stat("SpellPenetration", "Spell Penetration", Balf.Ecs.penetrationText, PLAIN, "SpellHeader"))
  add(rows, stat("BaseSpellDmg", "Spell Damage", Balf.Ecs.spellDamageText, PLAIN, "SpellHeader"))
  add(rows, stat("BonusHealing", "Healing Power", Balf.Ecs.healingText, HEAL, "SpellHeader"))

  local index = 1
  while index <= table.getn(SCHOOLS) do
    local name = SCHOOLS[index][1]
    local school = SCHOOLS[index][2]
    local colors = { SCHOOLS[index][3], SCHOOLS[index][4] }
    local gate = name .. "School"
    add(rows, header(gate, name, "SpellHeader", true))
    add(rows, stat(name .. "Dmg", "Damage", function()
      return Balf.Ecs.schoolDamageText(school)
    end, colors, "SpellHeader", nil, nil))
    rows[table.getn(rows)].school = gate
    add(rows, stat(name .. "CritChance", "Crit", function()
      return Balf.Ecs.schoolCritText(school)
    end, colors, "SpellHeader", nil, nil))
    rows[table.getn(rows)].school = gate
    add(rows, stat(name .. "HitBonus", "Hit Bonus", function()
      return Balf.Ecs.schoolHitText(school)
    end, colors, "SpellHeader", nil, nil))
    rows[table.getn(rows)].school = gate
    add(rows, stat(name .. "MissChance", "Miss", function()
      return Balf.Ecs.schoolMissText(school, 0)
    end, colors, "SpellHeader", nil, nil))
    rows[table.getn(rows)].school = gate
    add(rows, stat(name .. "MissChanceBoss", "Miss (Lvl + 3)", function()
      return Balf.Ecs.schoolMissText(school, 3)
    end, colors, "SpellHeader", nil, nil))
    rows[table.getn(rows)].school = gate
    index = index + 1
  end

  return rows
end

-- One tooltip line, turned into the numbers the window adds up. Gear and auras both
-- come through here. A set line counts once, and only while it is green.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

local function capture(text, pattern)
  local _, _, amount = string.find(text, pattern)
  if amount then
    return tonumber(amount)
  end
end

function Balf.Ecs.blankStats()
  return {
    spellCrit = 0,
    schoolCrit = { 0, 0, 0, 0, 0, 0, 0 },
    meleeCrit = 0,
    rangedCrit = 0,
    spellHit = 0,
    physicalHit = 0,
    rangedHit = 0,
    block = 0,
    mp5 = 0,
    periodic = 0,
    casting = 0,
    damageAndHealing = 0,
    damageOnly = 0,
    healingOnly = 0,
    school = { 0, 0, 0, 0, 0, 0, 0 },
    spellPen = 0,
    haste = 0,
    speed = 0,
    attackPower = 0,
    rangedAttackPower = 0,
  }
end

local function addSchool(list, name, amount)
  local school = Balf.Ecs.SCHOOL[name]
  if school and amount then
    list[school] = list[school] + amount
  end
end

function Balf.Ecs.addLine(totals, text)
  if not text then
    return
  end

  local both = capture(text, "Healing and Spell Damage %+(%d+)")
  if both then
    totals.damageAndHealing = totals.damageAndHealing + both
  else
    local spellDamage = capture(text, "Spell Damage %+(%d+)")
    if spellDamage then
      totals.damageOnly = totals.damageOnly + spellDamage
    end
  end

  local damageAndHealing = capture(text, "damage and healing done by magical spells and effects by up to (%d+)")
  if damageAndHealing then
    totals.damageAndHealing = totals.damageAndHealing + damageAndHealing
  end
  local damageOnly = capture(text, "damage done by magical spells and effects by up to (%d+)")
  if damageOnly then
    totals.damageOnly = totals.damageOnly + damageOnly
  end

  local _, _, first, second, pairAmount = string.find(text, "damage done by (%a+) and (%a+) spells and effects by up to (%d+)")
  if first then
    local amount = tonumber(pairAmount)
    addSchool(totals.school, first, amount)
    addSchool(totals.school, second, amount)
  else
    local _, _, schoolName, schoolAmount = string.find(text, "damage done by (%a+) spells and effects by up to (%d+)")
    if schoolName and schoolName ~= "magical" then
      addSchool(totals.school, schoolName, tonumber(schoolAmount))
    end
  end

  -- "damage and healing" is the shared bonus. A healing-only line must not match it too.
  if not string.find(text, "damage and healing", 1, true) then
    local healing = capture(text, "healing done by magical spells and effects by up to (%d+)")
      or capture(text, "healing done by spells and effects by up to (%d+)")
      or capture(text, "Healing Spells %+(%d+)")
      or capture(text, "Healing %+(%d+) and %d+ mana")
      or capture(text, "Increases Healing %+(%d+)")
    if healing then
      totals.healingOnly = totals.healingOnly + healing
    end
  end

  local allCrit = capture(text, "melee, ranged, or spell critical by (%d+)%%")
  if allCrit then
    totals.meleeCrit = totals.meleeCrit + allCrit
    totals.rangedCrit = totals.rangedCrit + allCrit
    totals.spellCrit = totals.spellCrit + allCrit
  end

  local spellCrit = capture(text, "critical strike with spells by (%d+)%%")
    or capture(text, "%+(%d+)%% Spell Critical Strike")
    or capture(text, "Spell Critical chance by (%d+)%%")
    or capture(text, "spell critical chance by (%d+)%%")
    or capture(text, "critical hit with a spell increased by (%d+)%%")
  if spellCrit then
    totals.spellCrit = totals.spellCrit + spellCrit
  end

  if string.find(text, "critical", 1, true) then
    local _, _, critSchool, critAmount = string.find(text, "with (%a+) spells by (%d+)%%")
    if critSchool and critSchool ~= "magical" then
      addSchool(totals.schoolCrit, critSchool, tonumber(critAmount))
    end
  end

  local meleeOnly = capture(text, "melee attacks by (%d+)%%") or capture(text, "melee weapons by (%d+)%%")
  if meleeOnly and string.find(text, "critical", 1, true) then
    totals.meleeCrit = totals.meleeCrit + meleeOnly
  end
  local genericCrit = capture(text, "critical strike by (%d+)%%")
    or capture(text, "%+(%d+)%% Critical Strike")
  if genericCrit and not string.find(text, "Spell Critical", 1, true) and not string.find(text, "spells", 1, true) then
    totals.meleeCrit = totals.meleeCrit + genericCrit
    totals.rangedCrit = totals.rangedCrit + genericCrit
  end

  local spellHit = capture(text, "hit with spells by (%d+)%%") or capture(text, "Spell Hit %+(%d+)%%")
  if spellHit then
    totals.spellHit = totals.spellHit + spellHit
  end
  local physicalHit = capture(text, "chance to hit by (%d+)%%")
  if physicalHit then
    totals.physicalHit = totals.physicalHit + physicalHit
  end
  local rangedHit = capture(text, "/Hit %+(%d+)%%")
  if rangedHit then
    totals.rangedHit = totals.rangedHit + rangedHit
  end

  local block = capture(text, "^(%d+) Block$")
    or capture(text, "Block Value %+(%d+)")
    or capture(text, "block value of your shield by (%d+)")
  if block then
    totals.block = totals.block + block
  end

  -- Earthshatterer's 15 is added in mana.lua, and only while Lightning Shield is up.
  if not string.find(text, "Lightning Shield", 1, true) then
    local per5 = capture(text, "(%d+) mana per 5 sec")
      or capture(text, "Mana Regen (%d+) per 5 sec")
      or capture(text, "Mana Regen %+(%d+)")
    if per5 then
      totals.mp5 = totals.mp5 + per5
    else
      local _, _, amount, every = string.find(text, "(%d+) mana every (%d+)")
      if amount and tonumber(every) > 0 then
        -- Wisdom and Mana Spring. The Buffs row is the flat mana per 5, so this stays separate.
        totals.periodic = totals.periodic + tonumber(amount) * 5 / tonumber(every)
      end
    end
  end

  local casting = capture(text, "(%d+)%% of your Mana regeneration")
    or capture(text, "(%d+)%% of your mana regeneration")
  if casting then
    totals.casting = totals.casting + casting / 100
  end

  local pen = capture(text, "magical resistances of your spell targets by (%d+)")
  if pen then
    totals.spellPen = totals.spellPen + pen
  end

  local haste = capture(text, "casting speed by (%d+)%%") or capture(text, "casting time reduced by (%d+)%%")
  if haste then
    totals.haste = totals.haste + haste
  end
  local slow = capture(text, "casting time increased by (%d+)%%")
  if slow then
    totals.haste = totals.haste - slow
  end

  local speed = capture(text, "movement speed by (%d+)%%") or capture(text, "run speed by (%d+)%%")
  if speed then
    totals.speed = totals.speed + speed
  end

  -- "Ranged Attack Power +24" also contains "Attack Power", so the ranged line goes first.
  local rangedPower = capture(text, "Ranged Attack Power %+(%d+)")
    or capture(text, "Ranged Attack Power by (%d+)")
    or capture(text, "ranged attack power by (%d+)")
  if rangedPower then
    totals.rangedAttackPower = totals.rangedAttackPower + rangedPower
  elseif not string.find(text, "Ranged Attack Power", 1, true) then
    local power = capture(text, "Attack Power %+(%d+)")
      or capture(text, "%+(%d+) Attack Power")
      or capture(text, "Attack Power by (%d+)")
    if power then
      totals.attackPower = totals.attackPower + power
    end
  end
end

function Balf.Ecs.sumLines(lines)
  local totals = Balf.Ecs.blankStats()
  local seen = {}
  local i = 1
  while i <= table.getn(lines) do
    local line = lines[i]
    local count = true
    if line.isSet then
      count = line.isActive and not seen[line.text]
      if count then
        seen[line.text] = true
      end
    end
    if count then
      Balf.Ecs.addLine(totals, line.text)
    end
    i = i + 1
  end
  return totals
end

function Balf.Ecs.mergeStats(into, extra)
  into.spellCrit = into.spellCrit + extra.spellCrit
  into.meleeCrit = into.meleeCrit + extra.meleeCrit
  into.rangedCrit = into.rangedCrit + extra.rangedCrit
  into.spellHit = into.spellHit + extra.spellHit
  into.physicalHit = into.physicalHit + extra.physicalHit
  into.rangedHit = into.rangedHit + extra.rangedHit
  into.block = into.block + extra.block
  into.mp5 = into.mp5 + extra.mp5
  into.periodic = (into.periodic or 0) + (extra.periodic or 0)
  into.casting = into.casting + extra.casting
  into.damageAndHealing = into.damageAndHealing + extra.damageAndHealing
  into.damageOnly = into.damageOnly + extra.damageOnly
  into.healingOnly = into.healingOnly + extra.healingOnly
  into.spellPen = into.spellPen + extra.spellPen
  into.haste = into.haste + extra.haste
  into.speed = into.speed + extra.speed
  into.attackPower = into.attackPower + extra.attackPower
  into.rangedAttackPower = into.rangedAttackPower + extra.rangedAttackPower
  local school = 1
  while school <= 7 do
    into.school[school] = into.school[school] + extra.school[school]
    into.schoolCrit[school] = into.schoolCrit[school] + extra.schoolCrit[school]
    school = school + 1
  end
end

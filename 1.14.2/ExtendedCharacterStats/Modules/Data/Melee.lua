---@class Data
local Data = ECSLoader:ImportModule("Data")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

-- keep-sorted start case=no
local _, _, classId = UnitClass("player")
local _Melee = {}
local HUNTER = Data.HUNTER
local PALADIN = Data.PALADIN
local ROGUE = Data.ROGUE
local SHAMAN = Data.SHAMAN
-- keep-sorted end

---@return number
function Data:GetMeleeAttackPower()
    local melee, posBuff, negBuff = UnitAttackPower("player")
    return melee + posBuff + negBuff
end

---@return number
function Data:GetMeleeAttackSpeedMainHand()
    local mainHand, _ = UnitAttackSpeed("player")
    return DataUtils:Round(mainHand, 2)
end

---@return number
function Data:GetMeleeAttackSpeedOffHand()
    local _, offHand = UnitAttackSpeed("player")
    return DataUtils:Round(offHand, 2)
end

---@return string
function Data:MeleeCrit()
    return DataUtils:Round(GetCritChance(), 2) .. "%"
end

---@return string
function Data:MeleeHitBonus()
    return DataUtils:Round(_Melee:GetHitRatingBonus(), 2) .. "%"
end

---@return number
function _Melee:GetHitRatingBonus()
    local hit = _Melee:GetHitTalentBonus() + Data:GetGearPhysicalHit()
    -- GetHitModifier returns nil on dungeon entering/teleport
    return hit + (GetHitModifier() or 0)
end

---@return number
function _Melee:GetHitTalentBonus()
    local mod = 0
    if classId == HUNTER then
        mod = 1 * DataUtils:GetActiveTalentSpell(Data.Talent[HUNTER].SUREFOOTED)
    elseif classId == Data.SHAMAN then
        mod = 1 * DataUtils:GetActiveTalentSpell(Data.Talent[SHAMAN].NATURES_GUIDANCE)
    elseif classId == Data.ROGUE then
        mod = 1 * DataUtils:GetActiveTalentSpell(Data.Talent[ROGUE].PRECISION)
    elseif classId == PALADIN then
        -- 1.12 Precision is melee hit only. Spell hit was added in 2.3.0.
        mod = 1 * DataUtils:GetActiveTalentSpell(Data.Talent[PALADIN].PRECISION)
    end

    return mod
end

--- Cat and bear attack with level × 5 skill and no off-hand, the same table as a capped weapon.
---@param extraLevels number
---@return string
local function meleeMiss(extraLevels)
    local playerLevel = UnitLevel("player")
    local defense = (playerLevel + extraLevels) * 5
    local skill
    local dualWield = Data:GetMeleeAttackSpeedOffHand() > 0
    if DataUtils:IsShapeshifted() then
        skill = playerLevel * 5
        dualWield = false
    else
        local mainBase, mainMod = UnitAttackBothHands("player")
        skill = mainBase + mainMod
    end
    local miss = DataUtils.CreatureMiss(skill, defense, _Melee:GetHitRatingBonus(), dualWield)
    return DataUtils:Round(miss, 2) .. "%"
end

---@return string
function Data:MeleeHitMissChanceSameLevel()
    return meleeMiss(0)
end

---@return string
function Data:MeleeHitMissChanceBossLevel()
    return meleeMiss(3)
end

function Data:GlanceHitChanceSameLevel()
    return Data:GlanceHitChanceByLevel(0)
end

function Data:GlanceHitChanceBossLevel()
    return Data:GlanceHitChanceByLevel(3)
end

---@return string
function Data:GlanceHitChanceByLevel(level)
    local mainBase, mainMod, _, _ = UnitAttackBothHands("player")
    local playerLevel = UnitLevel("player")
    local enemyDefenseValue = (playerLevel + level) * 5

    local glancingChance = DataUtils:GetGlancingChanceByDifference(playerLevel, mainBase + mainMod, enemyDefenseValue)

    return DataUtils:Round(glancingChance*100, 2) .. "%"
end

---@return string
function Data:GlanceDamageSameLevel()
    return Data:GlanceDamageByLevel(0)
end

---@return string
function Data:GlanceDamageBossLevel()
    return Data:GlanceDamageByLevel(3)
end
---@return string
function Data:GlanceDamageByLevel(level)
    local mainBase, mainMod, _, _ = UnitAttackBothHands("player")
    local playerLevel = UnitLevel("player")
    local enemyDefenseValue = (playerLevel + level) * 5

    local glancePenalty = DataUtils:GetGlancingDamage(mainBase + mainMod, enemyDefenseValue)

    return DataUtils:Round(glancePenalty*100, 2) .. "%"
end

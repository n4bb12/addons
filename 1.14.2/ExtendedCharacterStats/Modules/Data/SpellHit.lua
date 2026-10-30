---@class Data
local Data = ECSLoader:ImportModule("Data")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

-- keep-sorted start case=no
local _, _, classId = UnitClass("player")
local _SpellHit = {}
local MAGE = Data.MAGE
local PRIEST = Data.PRIEST
local SHAMAN = Data.SHAMAN
-- keep-sorted end

---@param school number
---@param levelDifference number
---@param IsPvP boolean
---@return number
function Data:SpellMissChance(school,levelDifference,IsPvP)
    -- https://royalgiraffe.github.io/resist-guide
    local missChance = 0
    local minimumMissChance = 1
    local maximumMissChance = 78 -- vMaNGOS never lets the hit chance fall below 22%

    if levelDifference >= -3 and levelDifference <= 2 then
        missChance = 4 + levelDifference
    elseif levelDifference >= 3 then
        missChance = 6 + (IsPvP and 7 or 11)*(levelDifference - 2)
    end

    missChance = missChance - _SpellHit:GetSpellHitBonus(school)
    missChance = max(missChance,minimumMissChance)
    missChance = min(missChance,maximumMissChance)

    return missChance
end

---@param school number
---@return string
function Data:SpellMissChanceSameLevel(school)
    return DataUtils:Round(Data:SpellMissChance(school,0,false), 2) .. "%"
end

---@param school number
---@return string
function Data:SpellMissChanceBossLevel(school)
    return DataUtils:Round(Data:SpellMissChance(school,3,false), 2) .. "%"
end

---If a talent spell has the "Apply Aura: Modifies Hit Chance" effect, then we need to handle it here.
---If the effect is "Apply Aura: Mod Spell Hit Chance %", then GetSpellHitModifier() already accounts for it and we don't need to handle it here.
---@param school number
---@return number
function _SpellHit:GetTalentSpellHitBonus(school)
    local bonus = 0

    if classId == MAGE then
        if school == Data.ARCANE_SCHOOL then
            bonus = bonus + 2 * DataUtils:GetActiveTalentSpell(Data.Talent[MAGE].ARCANE_FOCUS)
        elseif school == Data.FIRE_SCHOOL or school == Data.FROST_SCHOOL then
            -- 1.12 Elemental Precision is resist reduction on Frost and Fire, which is spell hit.
            bonus = bonus + 2 * DataUtils:GetActiveTalentSpell(Data.Talent[MAGE].ELEMENTAL_PRECISION)
        end
    elseif classId == PRIEST then
        if school == Data.SHADOW_SCHOOL then
            bonus = bonus + 2 * DataUtils:GetActiveTalentSpell(Data.Talent[PRIEST].SHADOW_FOCUS)
        end
    elseif classId == SHAMAN then
        bonus = bonus + 1 * DataUtils:GetActiveTalentSpell(Data.Talent[SHAMAN].NATURES_GUIDANCE)
    end

    return bonus
end

---@return number
function _SpellHit:GetSpellHitBonus(school)
    local hit = _SpellHit:GetTalentSpellHitBonus(school) + Data:GetGearSpellHit()
    -- GetSpellHitModifier returns nil on dungeon entering/teleport
    return hit + (GetSpellHitModifier() or 0)
end

---@param school number
---@return string
function Data.SpellHitBonus(school)
    local hit = _SpellHit:GetSpellHitBonus(school)
    return DataUtils:Round(hit, 2) .. "%"
end

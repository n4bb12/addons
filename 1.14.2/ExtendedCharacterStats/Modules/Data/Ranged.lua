---@class Data
local Data = ECSLoader:ImportModule("Data")
---@type Utils
local Utils = ECSLoader:ImportModule("Utils")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

local _Ranged = {}

-- Unit::GetAttackPowerFromStrengthAndAgility, ranged. Hunter, rogue, and warrior add level.
-- Every other class is agility − 10. A druid in cat or bear has no base.

---@return number
function _Ranged:GetBuffAttackPower()
    local total = 0
    local i = 1
    repeat
        local aura = DataUtils:GetAura("player", i, false)
        i = i + 1
        if aura and aura.spellId then
            local perStack = Data.Aura.RangedAttackPower[aura.spellId]
            if perStack then
                total = total + perStack * math.max(1, aura.applications or 1)
            end
        end
    until (not aura)
    return total
end

--- The server sends no ranged attack power field, so UnitRangedAttackPower is 0 for every class.
--- The sum is the server's base value, the gear and set bonuses read from tooltips, and ranged buffs.
---@return number
function Data:GetRangeAttackPower()
    local melee, posBuff, negBuff = UnitRangedAttackPower("player")
    local fromApi = (melee or 0) + (posBuff or 0) + (negBuff or 0)
    if fromApi > 0 then
        return fromApi
    end

    local _, _, classId = UnitClass("player")
    local _, agility = UnitStat("player", 2)
    local level = UnitLevel("player")
    local total
    if classId == Data.DRUID and DataUtils:IsShapeshifted() then
        total = 0
    elseif classId == Data.HUNTER then
        total = level * 2 + agility * 2 - 10
    elseif classId == Data.ROGUE or classId == Data.WARRIOR then
        total = level + agility - 10
    else
        total = agility - 10
    end
    total = total + Data:GetGearAttackPower() + Data:GetGearRangedOnlyAttackPower() + _Ranged:GetBuffAttackPower()
    return math.max(0, math.floor(total))
end

---@return number
function Data:GetRangedAttackSpeed()
    local speed, _ = UnitRangedDamage("player")
    return DataUtils:Round(speed, 2)
end

---@return string
function Data:RangedCrit()
    return DataUtils:Round(GetRangedCritChance(), 2) .. "%"
end

---@return string
function Data:RangeHitBonus()
    return DataUtils:Round(_Ranged:GetHitBonus(), 2) .. "%"
end

---@return number
function _Ranged:GetHitBonus()
    local hitValue = 0

    local rangedEnchant = DataUtils:GetEnchantForEquipSlot(Utils.CHAR_EQUIP_SLOTS["Range"])
    if rangedEnchant and rangedEnchant == Data.Enchant.Ids.BIZNICK_SCOPE then
        hitValue = hitValue + 3
    end

    local _, _, classId = UnitClass("player")
    if classId == Data.HUNTER then
        -- Surefooted has no weapon restriction, so ranged attacks get the same hit aura.
        hitValue = hitValue + DataUtils:GetActiveTalentSpell(Data.Talent[Data.HUNTER].SUREFOOTED)
    end

    return hitValue + Data:GetGearPhysicalHit() + Data:GetGearRangedHit() + (GetHitModifier() or 0)
end

---@param extraLevels number
---@return string
local function rangedMiss(extraLevels)
    local rangedAttackBase, rangedAttackMod = UnitRangedAttack("player")
    local playerLevel = UnitLevel("player")
    local defense = (playerLevel + extraLevels) * 5
    local miss = DataUtils.CreatureMiss(rangedAttackBase + rangedAttackMod, defense, _Ranged:GetHitBonus(), false)
    return DataUtils:Round(miss, 2) .. "%"
end

---@return string
function Data:RangeMissChanceSameLevel()
    return rangedMiss(0)
end

---@return string
function Data.RangeMissChanceBossLevel()
    return rangedMiss(3)
end

return Data

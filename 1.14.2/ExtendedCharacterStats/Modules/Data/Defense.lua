---@class Data
local Data = ECSLoader:ImportModule("Data")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

-- keep-sorted start case=no
local _, _, classId = UnitClass("player")
local _Defense = {}
-- Every 25 defense reduce the chance to be critically hit by 1 %
local DEFENSE_FOR_CRIT_REDUCTION = 25
local PALADIN = Data.PALADIN
local ROGUE = Data.ROGUE
local SHAMAN = Data.SHAMAN
-- keep-sorted end

---@return number
function Data:GetArmorValue()
    local _, effectiveArmor = UnitArmor("player")
    return DataUtils:Round(effectiveArmor, 2)
end

---@return number, number, number
function _Defense:GetCritReduction()
    local defBonus = Data:GetDefenseValue()

    local buffBonus = 0
    local meleeCritReduction = 0
    local rangedCritReduction = 0
    local spellCritReduction = 0
    local i = 1
    repeat
        local aura = DataUtils:GetAura("player", i, false)
        i = i + 1
        if aura and aura.spellId then
            buffBonus = buffBonus + (Data.Aura.CritReductionAll[aura.spellId] or 0)
            meleeCritReduction = meleeCritReduction + (Data.Aura.CritReductionMelee[aura.spellId] or 0)
        end
    until (not aura)
    i = 1
    repeat
        local aura = DataUtils:GetAura("player", i, true)
        i = i + 1
        if aura and aura.spellId then
            buffBonus = buffBonus + (Data.Aura.CritReductionAll[aura.spellId] or 0)
            meleeCritReduction = meleeCritReduction + (Data.Aura.CritReductionMelee[aura.spellId] or 0)
            spellCritReduction = spellCritReduction + (Data.Aura.CritReductionSpell[aura.spellId] or 0)
        end
    until (not aura)

    -- Only defense above the level's maximum skill (5 per level, 300 at 60) counts. The server
    -- takes 0.04% per point from melee and ranged crit (Unit::CalculateEffectiveCritChance), and
    -- nothing from spell crit.
    local critReductionFromDefense = (defBonus - UnitLevel("player") * 5) / DEFENSE_FOR_CRIT_REDUCTION
    if critReductionFromDefense < 0 then
        critReductionFromDefense = 0
    end

    meleeCritReduction = meleeCritReduction + critReductionFromDefense + buffBonus
    rangedCritReduction = rangedCritReduction + critReductionFromDefense + buffBonus
    spellCritReduction = spellCritReduction + buffBonus

    if classId == ROGUE then
        local rank = DataUtils:GetActiveTalentSpell(Data.Talent[ROGUE].SLEIGHT_OF_HAND)
        meleeCritReduction = meleeCritReduction + rank
        rangedCritReduction = rangedCritReduction + rank
    end

    return meleeCritReduction, rangedCritReduction, spellCritReduction
end

---@return string
function Data:GetMeleeCritReduction()
    local melee, _, _ = _Defense:GetCritReduction()
    return DataUtils:Round(melee, 2) .. "%"
end

---@return string
function Data:GetRangedCritReduction()
    local _, ranged, _ = _Defense:GetCritReduction()
    return DataUtils:Round(ranged, 2) .. "%"
end

---@return string
function Data:GetSpellCritReduction()
    local _, _, spell = _Defense:GetCritReduction()
    return DataUtils:Round(spell, 2) .. "%"
end

---@param enemyLevel number
---@return number
function _Defense:GetEnemyMissChance(enemyLevel)
    local enemyAttackRating = enemyLevel * 5
    local defense = Data:GetDefenseValue()
    local enemyMissChance = 5 + (((defense) - enemyAttackRating) * .04)
    return enemyMissChance
end

---@param enemyLevel number
---@return number
function _Defense:GetBlockChance(enemyLevel)
    local block = 0
    if IsSpellKnown(107) and C_PaperDollInfo.OffhandHasShield() then
       block = GetBlockChance() + ((UnitLevel("player") - enemyLevel) * .20)
    end
    return block
end

---@param enemyLevel number
---@return number
function _Defense:GetParryChance(enemyLevel)
    local parry = 0
    if IsSpellKnown(3127) or IsSpellKnown(18848) or IsSpellKnown(3124) then
        -- In theory we should compare the player's base defense skill with
        -- the attacker's weapon skill. Unfortunately there's no API function
        -- to retrieve the former. The following formula leads to the same
        -- results except when the player just gained a level and his/her
        -- defense skill did not catch up yet.
        parry = GetParryChance() + ((UnitLevel("player") - enemyLevel) * .20)
    end
    return parry
end

---@param enemyLevel number
---@return number
function _Defense:GetDodgeChance(enemyLevel)
    local dodge = 0
    if IsSpellKnown(81) then
        dodge = GetDodgeChance() + ((UnitLevel("player") - enemyLevel) * .20)
    end
    return dodge
end

---@param enemyLevel number
---@return number
function _Defense:GetAvoidance(enemyLevel)
    return _Defense:GetEnemyMissChance(enemyLevel) + _Defense:GetBlockChance(enemyLevel) + _Defense:GetParryChance(enemyLevel) + _Defense:GetDodgeChance(enemyLevel)
end

---@return number
function Data:GetDefenseValue()
    local skillRank, skillModifier = UnitDefense("player")
    return skillRank + skillModifier
end

---@param enemyLevel number
---@return string
function Data:GetDodgeChance(enemyLevel)
    return DataUtils:Round(_Defense:GetDodgeChance(enemyLevel), 2) .. "%"
end

---@param enemyLevel number
---@return string
function Data:GetParryChance(enemyLevel)
    return DataUtils:Round(_Defense:GetParryChance(enemyLevel), 2) .. "%"
end

---@param enemyLevel number
---@return string
function Data:GetBlockChance(enemyLevel)
    return DataUtils:Round(_Defense:GetBlockChance(enemyLevel), 2) .. "%"
end

---@param enemyLevel number
---@return string
function Data:GetEnemyMissChance(enemyLevel)
    return DataUtils:Round(_Defense:GetEnemyMissChance(enemyLevel), 2) .. "%"
end

---@param enemyLevel number
---@return string
function Data:GetAvoidance(enemyLevel)
    return DataUtils:Round(_Defense:GetAvoidance(enemyLevel), 2) .. "%"
end

---@return number
function Data:GetBlockValue()
    local blockValue = 0
    if IsSpellKnown(107) and C_PaperDollInfo.OffhandHasShield() then
        -- PLAYER_SHIELD_BLOCK is not on the 1.12 object, so GetShieldBlock() stays 0.
        -- The server's rule (Player::GetShieldBlockValue): (gear block value + Strength / 20 - 1)
        -- times the shield-block percent (1.0, or 1.10/1.20/1.30 for a paladin, or 1.05 per shaman
        -- rank), never below 0, cut to a whole number.
        local _, strength = UnitStat("player", 1)
        local flat = Data:GetGearBlockValue() + (strength or 0) / 20 - 1
        blockValue = math.floor(math.max(0, flat * _Defense:GetShieldBlockMultiplier()))
    end
    return DataUtils:Round(blockValue, 2)
end

--- Paladin Shield Specialization is 10% per rank. Shaman Shield Specialization is 5% per rank.
--- One rank is active, so the server multiplier is 1 + that percent.
---@return number
function _Defense:GetShieldBlockMultiplier()
    if classId == PALADIN then
        return 1 + 0.10 * DataUtils:GetActiveTalentSpell(Data.Talent[PALADIN].SHIELD_SPECIALIZATION)
    elseif classId == SHAMAN then
        return 1 + 0.05 * DataUtils:GetActiveTalentSpell(Data.Talent[SHAMAN].SHIELD_SPECIALIZATION)
    end
    return 1
end

---@class Data
local Data = ECSLoader:ImportModule("Data")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

-- keep-sorted start case=no
local _, _, classId = UnitClass("player")
local _SpellCrit = {}
local BRILLIANT_WIZARD_OIL = 2628
-- Spell crit the client never publishes. Melee and ranged crit from Songflower stay on the crit calls.
local SPELL_CRIT_AURA = {
    [15366] = 5, -- Songflower Serenade
    [22820] = 3, -- Slip'kik's Savvy
    [28142] = 2, -- Power of the Guardian, the mage trinket
}
local MAGE = Data.MAGE
local PALADIN = Data.PALADIN
local PRIEST = Data.PRIEST
local SHAMAN = Data.SHAMAN
local WARLOCK = Data.WARLOCK
-- keep-sorted end

---@param school number
---@return string
function Data:GetSpellCrit(school)
    local crit = _SpellCrit:GetTalentModifier(school)
    crit = crit + _SpellCrit:GetItemModifierBySchool(school)
    crit = crit + Data:GetGearSpellCrit()
    crit = crit + _SpellCrit:GetSetBonus(school)
    -- PLAYER_SPELL_CRIT_PERCENTAGE is not on the 1.12 object, so GetSpellCritChance() stays 0.
    crit = crit + _SpellCrit:GetIntellectCrit()
    crit = crit + _SpellCrit:GetSpellCritFromBuffs(school)

    return DataUtils:Round(crit, 2) .. "%"
end

---@return number
function _SpellCrit:GetSpellCritFromBuffs(school)
    local mod = 0
    local i = 1
    repeat
        local aura = DataUtils:GetAura("player", i, false)
        i = i + 1
        if aura and aura.spellId then
            -- Rallying Cry of the Dragonslayer. Count is 0 on a buff that does not stack.
            if aura.spellId == 22888 then
                mod = mod + 10
            elseif aura.spellId == 24907 then
                -- Moonkin Aura. Count is 0 on a buff that does not stack.
                mod = mod + 3
            end
            if school == Data.FIRE_SCHOOL then
                if aura.spellId == 28682 then
                    mod = mod + (aura.applications * 10) -- 10% for each stack from Combustion
                elseif aura.spellId == 1213317 then
                    mod = mod + 50 -- Fire Blast
                end
            end
            mod = mod + (SPELL_CRIT_AURA[aura.spellId] or 0)
        end
    until (not aura)
    return mod + _SpellCrit:GetBrilliantWizardOil()
end

--- +1% spell crit from enchant 2628. The gear scan already counts a weapon line that says
--- "+N% Spell Critical Strike", so this adds the bonus only when that line is absent.
---@return number
function _SpellCrit:GetBrilliantWizardOil()
    if not GetInventoryItemLink then
        return 0
    end
    local link = GetInventoryItemLink("player", 16)
    if DataUtils:GetEnchantFromItemLink(link) ~= BRILLIANT_WIZARD_OIL then
        return 0
    end
    if not CreateFrame then
        return 1
    end
    local tooltip = DataUtils:GetScanningTooltip()
    tooltip:ClearLines()
    if tooltip:SetInventoryItem("player", 16) then
        local name = tooltip:GetName()
        for i = 1, tooltip:NumLines() do
            local line = _G[name .. "TextLeft" .. i]
            local text = line and line.GetText and line:GetText()
            if text and string.match(text, "%+(%d+)%% Spell Critical Strike") then
                return 0
            end
        end
    end
    return 1
end

---@param school number
---@return number
function _SpellCrit:GetTalentModifier(school)
    local modifier = _SpellCrit:GetGeneralTalentModifier()
    local modifierForSchool = _SpellCrit:GetTalentModifierBySchool(school)

    return modifier + modifierForSchool
end

---@return number
function _SpellCrit:GetGeneralTalentModifier()
    local mod = 0

    if classId == MAGE then
        mod = mod + 1 * DataUtils:GetActiveTalentSpell(Data.Talent[MAGE].ARCANE_INSTABILITY)
    end

    return mod
end

---@param school number
---@return number
function _SpellCrit:GetTalentModifierBySchool(school)
    if school == Data.HOLY_SCHOOL then
        return _SpellCrit:GetTalentModifierHolyCrit()
    elseif school == Data.FIRE_SCHOOL then
        return _SpellCrit:GetTalentModifierFireCrit()
    elseif school == Data.NATURE_SCHOOL then
        return _SpellCrit:GetTalentModifierNatureCrit()
    else
        return 0
    end
end

---@return number
function _SpellCrit:GetTalentModifierNatureCrit()
    local mod = 0
    if classId == SHAMAN then
        -- Healing and lightning spells are the nature school. Shock spells are not.
        mod = 1 * DataUtils:GetActiveTalentSpell(Data.Talent[SHAMAN].TIDAL_MASTERY)
    end
    return mod
end

---@return number
function _SpellCrit:GetTalentModifierHolyCrit()
    local mod = 0
    if classId == PRIEST then
        mod = 1 * DataUtils:GetActiveTalentSpell(Data.Talent[PRIEST].HOLY_SPECIALIZATION)
    elseif classId == PALADIN then
        mod = 1 * DataUtils:GetActiveTalentSpell(Data.Talent[PALADIN].HOLY_POWER)
    end
    return mod
end

---@return number
function _SpellCrit:GetTalentModifierFireCrit()
    local mod = 0

    if classId == MAGE then
        mod = mod + 2 * DataUtils:GetActiveTalentSpell(Data.Talent[MAGE].CRITICAL_MASS)
    elseif classId == WARLOCK then
        -- Devastation covers every Destruction spell, including Shadow Bolt. The fire line is the
        -- one that stays honest: a shadow line would show the bonus on Affliction spells.
        mod = mod + 1 * DataUtils:GetActiveTalentSpell(Data.Talent[WARLOCK].DEVASTATION)
    end

    return mod
end

---@return number
function _SpellCrit:GetItemModifierBySchool(school)
    if school == Data.HOLY_SCHOOL then
        return _SpellCrit:GetItemModifierHolyCrit()
    end

    return 0
end

---@return number
function _SpellCrit:GetItemModifierHolyCrit()
    local mainHand, _ = GetInventoryItemID("player", 16)
    if mainHand == 18608 then
        return 2 -- 2% Holy Crit from Benediction
    end
    return 0
end

---@return number
function _SpellCrit:GetSetBonus(school)
    local bonus = 0

    if school == Data.NATURE_SCHOOL and Data:HasNatureCritBonusModifier() then
        bonus = 3 -- 3% Nature Crit from Shaman T2
    end

    return bonus
end

-- The server's own rule (vMaNGOS, Unit::GetSpellCritFromIntellect):
-- crit % = base + intellect / (rate0 + rate1 * level). The client never gets the result, so the
-- same numbers are repeated here. Classes without a row have no spell crit from intellect.
local SPELL_CRIT_FROM_INTELLECT = {
    [Data.PALADIN] = { base = 3.70, rate0 = 14.77, rate1 = 0.65 },
    [Data.PRIEST] = { base = 2.97, rate0 = 10.03, rate1 = 0.82 },
    [Data.SHAMAN] = { base = 3.54, rate0 = 11.51, rate1 = 0.80 },
    [Data.MAGE] = { base = 3.70, rate0 = 14.77, rate1 = 0.65 },
    [Data.WARLOCK] = { base = 3.18, rate0 = 11.30, rate1 = 0.82 },
    [Data.DRUID] = { base = 3.33, rate0 = 12.41, rate1 = 0.79 },
}

---@return number
function _SpellCrit:GetIntellectCrit()
    local rule = SPELL_CRIT_FROM_INTELLECT[classId]
    if not rule then
        return 0
    end

    local _, intellect = UnitStat("player", 4)
    local level = UnitLevel("player")
    if not intellect or not level or level < 1 then
        return 0
    end

    return rule.base + intellect / (rule.rate0 + rule.rate1 * level)
end

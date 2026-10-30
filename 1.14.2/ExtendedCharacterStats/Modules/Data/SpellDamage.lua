---@class Data
local Data = ECSLoader:ImportModule("Data")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

local magicSchools = { Data.FIRE_SCHOOL, Data.NATURE_SCHOOL, Data.FROST_SCHOOL, Data.SHADOW_SCHOOL, Data.ARCANE_SCHOOL }

-- Healing-only buffs. "Damage and healing" auras are already in GetSpellBonusDamage.
local HEALING_ONLY_AURA = {
    [28144] = 62, -- Power of the Guardian, the priest trinket
}

--- The client total. Checked in game: a warlock with Shadow Mastery 5/5 (+10% shadow) reads the
--- same on every school, so the percent talents are not in this field and need no correction.
local function flatSpellDamage(school)
    return DataUtils:Round(GetSpellBonusDamage(school) or 0, 0)
end

--- Total bonus for the school. Magic schools also show the amount above base spell damage,
--- so +600 spell damage and +24 frost reads as "624 (+24)". Physical has no shared bonus.
---@param school number
---@return number|string
function Data:GetSpellDamage(school)
    local spellDmg = flatSpellDamage(school)
    if school == Data.PHYSICAL_SCHOOL then
        return spellDmg
    end

    local schoolOnly = spellDmg - Data:GetBaseSpellDamage()
    if schoolOnly > 0 then
        return spellDmg .. " (+" .. schoolOnly .. ")"
    end
    return spellDmg
end

--- Shared flat bonus: the minimum magic school after percent talents are removed.
---@return number
function Data:GetBaseSpellDamage()
    local spellDmg = flatSpellDamage(Data.HOLY_SCHOOL)
    for _, school in ipairs(magicSchools) do
        spellDmg = math.min(spellDmg, flatSpellDamage(school))
    end
    return spellDmg or 0
end

--- A healing buff the spell-damage field does not carry.
---@return number
local function healingOnlyAuras()
    if not UnitBuff then
        return 0
    end
    local total = 0
    local i = 1
    repeat
        local aura = DataUtils:GetAura("player", i, false)
        i = i + 1
        if aura and aura.spellId then
            total = total + (HEALING_ONLY_AURA[aura.spellId] or 0)
        end
    until (not aura)
    return total
end

---@return number
function Data:GetHealingPower()
    -- PLAYER_FIELD_MOD_HEALING_DONE_POS is not on the 1.12 object, so GetSpellBonusHealing() is 0
    -- (checked in game: 0 next to 181 spell damage). Shared "damage and healing" is already in the
    -- spell damage fields. Healing-only gear and enchants are flats (GearLines.lua). The healing
    -- percent talents never enter. Spiritual Guidance is already in the spell-damage field.
    return Data:GetBaseSpellDamage() + Data:GetGearHealing() + healingOnlyAuras()
end

--- Casting-speed percent from auras. Haste rating is not a 1.12 stat.
---@return string
function Data:GetSpellHasteBonus()
    local hasteBonus = 0
    if type(GetHaste) == "function" then
        hasteBonus = GetHaste() or 0
    end

    local i = 1
    repeat
        local aura = DataUtils:GetAura("player", i, false)
        i = i + 1
        if aura and aura.spellId then
            hasteBonus = hasteBonus + (Data.Aura.SpellHaste[aura.spellId] or 0)
        end
    until (not aura)

    i = 1
    repeat
        local aura = DataUtils:GetAura("player", i, true)
        i = i + 1
        if aura and aura.spellId then
            hasteBonus = hasteBonus + (Data.Aura.SpellHaste[aura.spellId] or 0)
        end
    until (not aura)

    return DataUtils:Round(hasteBonus, 2) .. "%"
end

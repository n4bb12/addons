---@class Data
local Data = ECSLoader:ImportModule("Data")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")
-- keep-sorted start case=no
local _, _, classId = UnitClass("player")
local _MP5 = {}
local DRUID = Data.DRUID
local MAGE = Data.MAGE
local PRIEST = Data.PRIEST
-- Mana Spring buffs. The 4-piece multiplies the tick; Blessing of Wisdom is not one of these.
local MANA_SPRING = {
    [5677] = true,
    [10491] = true,
    [10493] = true,
    [10494] = true,
    [24853] = true,
    [25569] = true,
}
-- keep-sorted end

---@return number
function Data:GetValueFromAuraTooltip(index,type)
    local scanningTooltip = DataUtils:GetScanningTooltip()
    scanningTooltip:ClearLines()
    scanningTooltip:SetUnitAura("player",index, type)
    local region = select(5,scanningTooltip:GetRegions())
    if region and region:GetObjectType() == "FontString" then
        local tooltip = region:GetText()
        if tooltip then
            return tonumber(string.match(tooltip, '%d[%d,.]*'))
        end
    end
    return 0
end

-- Get MP5 from items
---@return number
function Data:GetMP5FromItems()
    return _MP5:GetMP5ValueOnItems() + Data:GetSetBonusValueMP5()
end

---@return number
function _MP5:GetMP5ValueOnItems()
    local mp5 = 0
    for i = 1, 18 do
        local itemLink = GetInventoryItemLink("player", i)
        if itemLink then
            local stats = GetItemStats(itemLink)
            if stats then
                local statMP5 = stats["ITEM_MOD_POWER_REGEN0_SHORT"]
                if statMP5 then
                    mp5 = mp5 + statMP5 + 1
                end
            end
            -- Check for socketed gems (TODO: check for socket bonus)
            local gem1, gem2, gem3 = DataUtils:GetSocketedGemsFromItemLink(itemLink)
            if gem1 then
                mp5 = mp5 + (Data.Gem.MP5[tonumber(gem1)] or 0)
            end
            if gem2 then
                mp5 = mp5 + (Data.Gem.MP5[tonumber(gem2)] or 0)
            end
            if gem3 then
                mp5 = mp5 + (Data.Gem.MP5[tonumber(gem3)] or 0)
            end
        end
    end

    -- Permanent enchants read from their tooltip lines
    mp5 = mp5 + Data:GetGearEnchantMP5()

    -- Check weapon enchants (e.g. Mana Oil)
    local hasMainEnchant, _, _, mainHandEnchantID = GetWeaponEnchantInfo()
    if (hasMainEnchant) then
        mp5 = mp5 + (Data.Enchant.MP5[mainHandEnchantID] or 0)
    end

    return mp5
end

-- The server's spirit regeneration (vMaNGOS, Unit::GetRegenMPPerSpirit): mana per 2 second
-- tick = spirit / divisor + flat. GetManaRegen() is the client's own copy and differs for a
-- shaman (flat 15 instead of 17) and below level 60.
local SPIRIT_REGEN = {
    [Data.DRUID] = { divisor = 5, flat = 15 },
    [Data.HUNTER] = { divisor = 5, flat = 15 },
    [Data.MAGE] = { divisor = 4, flat = 12.5 },
    [Data.PALADIN] = { divisor = 5, flat = 15 },
    [Data.PRIEST] = { divisor = 4, flat = 12.5 },
    [Data.SHAMAN] = { divisor = 5, flat = 17 },
    [Data.WARLOCK] = { divisor = 5, flat = 15 },
}

--- Mana per 5 seconds from Spirit while not casting.
---@return number
function Data:GetMP5FromSpirit()
    local rule = SPIRIT_REGEN[classId]
    if not rule then
        return 0
    end
    local _, spirit = UnitStat("player", 5)
    local perTick = (spirit or 0) / rule.divisor + rule.flat
    return DataUtils:Round(perTick / 2 * 5, 2)
end

-- Get mana regen while casting. Flat mana per 5 from items and buffs always applies. Only the
-- share of Spirit regeneration the casting modifier allows (up to 100%) counts.
---@return number
function Data:GetMP5WhileCasting()
    local castingModifier, mp5BuffBonus, periodicMana = Data:GetMP5FromBuffs()
    castingModifier = min(1, castingModifier + _MP5:GetTalentModifier() + Data:GetSetBonusModifierMP5())
    local casting = Data:GetMP5FromSpirit() * castingModifier + Data:GetMP5FromItems() + mp5BuffBonus + periodicMana

    return DataUtils:Round(casting, 2)
end

---@return number
function Data:GetMP5OutsideCasting()
    local mp5FromSpirit = Data:GetMP5FromSpirit()
    local _, mp5BuffBonus, periodicMana = Data:GetMP5FromBuffs()
    local mp5FromItems = Data:GetMP5FromItems()

    local totalMP5 = mp5FromSpirit + mp5FromItems + mp5BuffBonus + periodicMana
    return DataUtils:Round(totalMP5, 2)
end

---@return number, number, number
function Data:GetMP5FromBuffs()
    local mod = 0
    local bonus = 0
    local periodic = 0
    local maxmana = UnitPowerMax("player", Enum.PowerType.Mana)

    local i = 1
    repeat
        local aura = DataUtils:GetAura("player", i, false)
        if aura and aura.spellId then
            bonus = bonus + (Data.Aura.MP5[aura.spellId] or 0)
            bonus = bonus + (Data.Aura.PercentageMp5[aura.spellId] or 0) * maxmana
            periodic = periodic + (Data.Aura.PeriodicallyGiveMana[aura.spellId] or 0)
            mod = mod + (Data.Aura.AllowCastingManaRegeneration[aura.spellId] or 0) -- assuming buffs stacking, to be investigated
            if Data.Aura.IsLightningShield[aura.spellId] and Data:IsSetBonusActive(Data.setNames.THE_EARTHSHATTERER, 8) then
                bonus = bonus + 15 -- 15 MP5 from Shaman T3 8 piece bonus when Lightning Shield is active
            end
            if Data.Aura.MP5Tooltip[aura.spellId] then
                bonus = bonus + Data.Aura.MP5Tooltip[aura.spellId] * Data:GetValueFromAuraTooltip(i, "HELPFUL")
            end
            if Data.Aura.PeriodicallyGiveManaTooltip[aura.spellId] then
                local amount = Data.Aura.PeriodicallyGiveManaTooltip[aura.spellId] * Data:GetValueFromAuraTooltip(i, "HELPFUL")
                -- The Earthshatterer 4-piece is +25% mana from Mana Spring totems.
                if MANA_SPRING[aura.spellId] and Data.IsSetBonusActive and Data:IsSetBonusActive(Data.setNames.THE_EARTHSHATTERER, 4) then
                    amount = amount * 1.25
                end
                periodic = periodic + amount
            end
        end
        i = i + 1
    until (not aura)
    i = 1
    repeat
        local aura = DataUtils:GetAura("player", i, true)
        if aura and aura.spellId then
            bonus = bonus + (Data.Aura.PercentageMp5[aura.spellId] or 0) * maxmana
        end
        i = i + 1
    until (not aura)
    return min(mod,1), bonus, periodic
end

---@return number
function _MP5:GetTalentModifier()
    local mod = 0

    if classId == PRIEST then
        mod = mod + 0.05 * DataUtils:GetActiveTalentSpell(Data.Talent[PRIEST].MEDITATION)
    elseif classId == MAGE then
        mod = mod + 0.05 * DataUtils:GetActiveTalentSpell(Data.Talent[MAGE].ARCANE_MEDITATION)
    elseif classId == DRUID then
        mod = mod + 0.05 * DataUtils:GetActiveTalentSpell(Data.Talent[DRUID].INTENSITY_REFLECTION)
    end
    return mod
end

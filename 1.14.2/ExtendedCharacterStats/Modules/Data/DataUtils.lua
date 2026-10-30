---@class DataUtils
local DataUtils = ECSLoader:CreateModule("DataUtils")
---@type Data
local Data = ECSLoader:ImportModule("Data")

--- Rounds every number down to the given decimal places
---@param num number
---@param decimalPlaces number
---@return number
function DataUtils:Round(num, decimalPlaces)
    if (not num) then
        return 0
    end
    local mult = 10^(decimalPlaces)
    return math.floor(num * mult + 0.5) / mult
end

--- One buff or debuff. Returns are name, icon, count, debuffType, duration, expirationTime,
--- source, isStealable, nameplateShowPersonal, spellId. Count is the 3rd and spellId the 10th.
---@param unit string
---@param index number
---@param harmful boolean
---@return table|nil
function DataUtils:GetAura(unit, index, harmful)
    local name, _, count, _, _, _, _, _, _, spellId
    if harmful then
        name, _, count, _, _, _, _, _, _, spellId = UnitDebuff(unit, index)
    else
        name, _, count, _, _, _, _, _, _, spellId = UnitBuff(unit, index)
    end
    if not name then
        return nil
    end
    return { spellId = spellId, applications = count }
end

--- The hidden tooltip every scan reads from.
---@return table
function DataUtils:GetScanningTooltip()
    if not ECS.scanningTooltip then
        ECS.scanningTooltip = CreateFrame("GameTooltip", "scanningTooltip", nil, "GameTooltipTemplate")
        ECS.scanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    return ECS.scanningTooltip
end

local EQUIPPED_LINES_SECONDS = 2
local equippedLines, equippedLinesAt

--- Every tooltip line of worn gear, read once and reused for a moment. Many stats scan the same
--- 19 tooltips on each update, and spell lines (Equip effects, set bonuses) fill in a little
--- after login, so the cache is short.
---@return table[] each { text, isSet, isActive }
function DataUtils:GetEquippedLines()
    local now = GetTime()
    if equippedLines and now - equippedLinesAt < EQUIPPED_LINES_SECONDS then
        return equippedLines
    end

    local tooltip = DataUtils:GetScanningTooltip()
    local setPrefix = string.gsub(ITEM_SET_BONUS or "Set: %s", "%%s", "")
    local lines = {}
    for slot = 1, 19 do
        tooltip:ClearLines()
        if tooltip:SetInventoryItem("player", slot) then
            for i = 1, tooltip:NumLines() do
                local line = _G[tooltip:GetName() .. "TextLeft" .. i]
                local text = line and line:GetText()
                if text then
                    local r, g, b = line:GetTextColor()
                    lines[#lines + 1] = {
                        text = text,
                        isSet = string.find(text, setPrefix, 1, true) ~= nil,
                        isActive = r < 0.2 and g > 0.8 and b < 0.2,
                    }
                end
            end
        end
    end

    equippedLines = lines
    equippedLinesAt = now
    return lines
end

--- Drops the cached lines, for when the gear changes.
function DataUtils:InvalidateEquippedLines()
    equippedLines = nil
end

--- Adds up a number printed on a line of worn gear. matchLine gets one tooltip line and returns
--- the amount on it, or nil. A set bonus line counts once, and only while it is green.
---@param matchLine fun(text: string): number|nil
---@return number
function DataUtils:SumEquippedLines(matchLine)
    local seenSetLines = {}
    local total = 0
    for _, line in ipairs(DataUtils:GetEquippedLines()) do
        local amount = matchLine(line.text)
        if amount then
            if not line.isSet then
                total = total + amount
            elseif line.isActive and not seenSetLines[line.text] then
                seenSetLines[line.text] = true
                total = total + amount
            end
        end
    end
    return total
end

---@return boolean
function DataUtils:IsShapeshifted()
    local i = 1
    repeat
        local aura = DataUtils:GetAura("player", i, false)
        i = i + 1
        if aura and aura.spellId then
            if Data.Aura.IsFeralForm[aura.spellId] then
                return true
            end
        end
    until (not aura)
    return false
end

--- White-hit miss before dual wield, the low-level scale, and hit.
--- SpellCaster::GetMeleeMissChance: 5% plus 0.1% per point of defense above weapon skill,
--- or 0.2% for the whole gap once defense is more than 10 above weapon skill.
--- 300 skill vs 315 defense is 8% at 0 hit.
---@param weaponSkill number
---@param defenseValue number
---@return number
function DataUtils.GetMissChanceByDifference(weaponSkill, defenseValue)
    local delta = defenseValue - weaponSkill
    if delta > 10 then
        return 5 + delta * 0.2
    end
    return 5 + delta * 0.1
end

--- The miss a creature roll uses. Dual wield adds 19% before the low-level scale.
--- The first 1% of hit is ignored when defense is more than 10 above weapon skill,
--- so one point of hit against a boss still leaves 8% miss. Miss stays between 0 and 60.
---@param weaponSkill number
---@param defenseValue number
---@param hit number
---@param dualWield boolean
---@return number
function DataUtils.CreatureMiss(weaponSkill, defenseValue, hit, dualWield)
    local delta = defenseValue - weaponSkill
    local miss = DataUtils.GetMissChanceByDifference(weaponSkill, defenseValue)
    if dualWield then
        miss = miss + 19
    end
    local victimLevel = defenseValue / 5
    if victimLevel > 0 and victimLevel < 10 then
        miss = miss * victimLevel / 10
    end
    hit = hit or 0
    if delta > 10 and hit > 0 then
        hit = hit - 1
    end
    miss = miss - hit
    if miss < 0 then
        return 0
    elseif miss > 60 then
        return 60
    end
    return miss
end

---@param level number
---@param weaponSkill number
---@param defenseValue number
---@return number
function DataUtils:GetGlancingChanceByDifference(level, weaponSkill, defenseValue)
    local glancingChance = 0.1 + (defenseValue - math.min(level*5, weaponSkill)) * 0.02

    -- Ensure the glancing chance does not exceed 1.0 (100%)
    if glancingChance > 1.0 then
        glancingChance = 1.0
    end
    return glancingChance
end

---@param weaponSkill number
---@param defenseValue number
---@return number
function DataUtils:GetGlancingDamage(weaponSkill, defenseValue)
    local difference = defenseValue - weaponSkill
    local low = math.min(0.91 ,(1.3 - 0.05 * difference))

    -- Ensure low does not go below 0.01
    if low < 0.01 then
        low = 0.01
    end
    local high = 1.2 - (0.03 * difference)

    if high > 0.99 then
        high = 0.99
    elseif high < 0.2 then
        high = 0.2
    end
    local averageDamageFactor = (high + low) / 2

    -- Ensure the average damage factor is not negative (damage reduction is not > 100%)
    if averageDamageFactor < 0 then
        averageDamageFactor = 0
    end
    return averageDamageFactor
end

---@param equipSlot EquipSlot
---@return number|nil
function DataUtils:GetEnchantForEquipSlot(equipSlot)
    local slotId, _ = GetInventorySlotInfo(equipSlot)
    local itemLink = GetInventoryItemLink("player", slotId)

    return DataUtils:GetEnchantFromItemLink(itemLink)
end

---@param itemLink ItemLink
---@return number|nil
function DataUtils:GetEnchantFromItemLink(itemLink)
    if not itemLink then
        return nil
    end
    local itemStringLink = itemLink
    if GetItemInfo then
        local _, linked = GetItemInfo(itemLink)
        if linked then
            itemStringLink = linked
        end
    end
    -- The enchant is the second number. GetItemInfo can be nil until the item is cached.
    local _, _, enchant = string.find(itemStringLink, "item:%d+:(%d+)")
    return tonumber(enchant)
end

---@param itemLink ItemLink
---@return string | nil, string | nil, string | nil
function DataUtils:GetSocketedGemsFromItemLink(itemLink)
    if itemLink then
        local _, itemStringLink = GetItemInfo(itemLink)
        if itemStringLink then
            local _, _, gem1, gem2, gem3, _ = strsplit(":", itemStringLink, 6)
            return gem1, gem2, gem3
        end
    end
    return nil
end

---@return boolean
function DataUtils:CanParry()
    return (IsSpellKnown(3127) or IsSpellKnown(18848) or IsSpellKnown(3124))
end

---@return boolean
function DataUtils:CanBlock()
    return IsSpellKnown(107)
end

--- Spent rank of a talent, by the name of its first-rank spell. The talent API is the source,
--- because the 1.12 server never sends the talent rank spells, so IsSpellKnown is false for them.
---@param talentList table<number> spell ids, lowest rank first
---@return number
function DataUtils:GetActiveTalentSpell(talentList)
    local name = GetSpellInfo(talentList[1])
    if not name then
        return 0
    end
    for tab = 1, GetNumTalentTabs() do
        for index = 1, GetNumTalents(tab) do
            local talentName, _, _, _, rank = GetTalentInfo(tab, index)
            if talentName == name then
                return rank or 0
            end
        end
    end
    return 0
end

return DataUtils

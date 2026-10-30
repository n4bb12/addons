---@class Data
local Data = ECSLoader:ImportModule("Data")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

-- Stats the 1.12 server applies but never sends as a player field, read from the text of worn gear.
-- The patterns are the 1.14 client's wording for 1.12 items, equip effects, enchants, and set bonuses.
-- Checked against the tooltips ExtendedCharacterStatsProbe records.

local SPELL_CRIT = {
    "chance to get a critical strike with spells by (%d+)%%", -- Equip: and Set:
    "%+(%d+)%% Spell Critical Strike", -- enchant, e.g. "Spell Damage +15 and +1% Spell Critical Strike"
}
local SPELL_HIT = {
    "chance to hit with spells by (%d+)%%",
    "Spell Hit %+(%d+)%%", -- enchant, e.g. "Healing and Spell Damage +18/Spell Hit +1%"
}
-- "with spells" does not match, because the words after "hit" differ.
local PHYSICAL_HIT = {
    "chance to hit by (%d+)%%",
}
-- Falcon's Call: "Ranged Attack Power +24/Stamina +10/Hit +1%". Ranged only.
local RANGED_HIT = {
    "/Hit %+(%d+)%%",
}
local BLOCK_VALUE = {
    "^(%d+) Block$", -- the shield's own value
    "Block Value %+(%d+)", -- enchant, e.g. "Defense +7/Stamina +10/Block Value +15"
    "block value of your shield by (%d+)",
}
-- Equip lines are not here: GetItemStats carries them. These are the enchant lines.
local MANA_PER_5 = {
    "Mana Regen (%d+) per 5 sec", -- enchant
    "Mana Regen %+(%d+)/", -- Prophetic Aura: "Mana Regen +4/Stamina +10/Healing Spells +24"
    "and (%d+) mana per 5 sec", -- enchant, e.g. "Healing +31 and 5 mana per 5 sec."
}
-- The item's own healing is a stat. These are the enchant lines.
local HEALING_ENCHANT = {
    "Healing Spells %+(%d+)", -- also inside "Defense +7/Stamina +10/Healing Spells +24"
    "^%+(%d+) Healing Spells$", -- Zandalar Signet of Serenity. The item's own line starts with a color code.
    "Healing %+(%d+) and %d+ mana per 5 sec",
    "^Increases Healing %+(%d+)$", -- old weapon enchants
}
local HEALING_SET = "Increases healing done by spells and effects by up to (%d+)"

-- Attack power. The 1.12 equip spells "Attack Power N" carry both the melee aura and the ranged aura
-- (Spell.dbc), so an item's +Attack Power counts for ranged. Its stat is ITEM_MOD_ATTACK_POWER_SHORT.
-- These are the enchant lines, which GetItemStats never lists.
local ATTACK_POWER_ENCHANT = {
    "^%+(%d+) Attack Power$", -- Zandalar enchants
    "^Attack Power %+(%d+)", -- "Attack Power +26 and +1% Critical Strike", "Attack Power +28/Dodge +1%"
}
-- "Ranged Attack Power +24/Stamina +10/Hit +1%" (Falcon's Call) is ranged only.
local RANGED_ATTACK_POWER_ENCHANT = {
    "^Ranged Attack Power %+(%d+)",
    "^%+(%d+) Ranged Attack Power$",
}
-- Set bonuses, such as the Cryptstalker 4-piece: "Increases Attack Power by 50 for both you and your pet."
local ATTACK_POWER_SET = {
    "Increases Attack Power by (%d+)",
    "%+(%d+) Attack Power",
}

local function sumMatching(patterns)
    return DataUtils:SumEquippedLines(function(text)
        for _, pattern in ipairs(patterns) do
            local amount = string.match(text, pattern)
            if amount then
                return tonumber(amount)
            end
        end
    end)
end

---@return number percent
function Data:GetGearSpellCrit()
    return sumMatching(SPELL_CRIT)
end

---@return number percent
function Data:GetGearSpellHit()
    return sumMatching(SPELL_HIT)
end

--- Melee and ranged share the line.
---@return number percent
function Data:GetGearPhysicalHit()
    return sumMatching(PHYSICAL_HIT)
end

--- Hit on ranged gear only, such as Falcon's Call.
---@return number percent
function Data:GetGearRangedHit()
    return sumMatching(RANGED_HIT)
end

--- Shield value and block-value enchants. Strength is added by the caller.
---@return number
function Data:GetGearBlockValue()
    return sumMatching(BLOCK_VALUE)
end

--- Mana per 5 seconds from enchant lines.
---@return number
function Data:GetGearEnchantMP5()
    return sumMatching(MANA_PER_5)
end

--- GetItemStats numbers are one below the tooltip number, the same as the spell effect they come from.
---@param statKey string
---@return number
function Data:GetGearStat(statKey)
    local total = 0
    for slot = 1, 18 do
        local link = GetInventoryItemLink("player", slot)
        local stats = link and GetItemStats(link)
        if stats and stats[statKey] then
            total = total + stats[statKey] + 1
        end
    end
    return total
end

--- +Healing that is not already inside spell damage: the healing stat on each item, the healing
--- enchants, and an active set bonus. "Damage and healing" is in the spell damage field.
---@return number
function Data:GetGearHealing()
    local fromSets = DataUtils:SumEquippedLines(function(text)
        if string.find(text, "Set: ", 1, true) then
            return tonumber(string.match(text, HEALING_SET))
        end
    end)
    return Data:GetGearStat("ITEM_MOD_SPELL_HEALING_DONE_SHORT") + sumMatching(HEALING_ENCHANT) + fromSets
end

--- Attack power on worn gear that counts for both melee and ranged: item stats, enchants, and set bonuses.
---@return number
function Data:GetGearAttackPower()
    local fromSets = DataUtils:SumEquippedLines(function(text)
        if string.find(text, "Set: ", 1, true) then
            for _, pattern in ipairs(ATTACK_POWER_SET) do
                local amount = string.match(text, pattern)
                if amount and not string.find(text, "Ranged Attack Power", 1, true) then
                    return tonumber(amount)
                end
            end
        end
    end)
    return Data:GetGearStat("ITEM_MOD_ATTACK_POWER_SHORT") + sumMatching(ATTACK_POWER_ENCHANT) + fromSets
end

--- Attack power on ranged gear only, such as Falcon's Call.
---@return number
function Data:GetGearRangedOnlyAttackPower()
    return Data:GetGearStat("ITEM_MOD_RANGED_ATTACK_POWER_SHORT") + sumMatching(RANGED_ATTACK_POWER_ENCHANT)
end

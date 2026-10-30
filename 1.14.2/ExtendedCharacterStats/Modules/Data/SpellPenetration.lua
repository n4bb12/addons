---@class Data
local Data = ECSLoader:ImportModule("Data")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

-- 1.12 has no mod-target-resistance field. Hermes never fills it, so GetSpellPenetration() stays 0.
-- The equip line is the value the server applies.
local SPELL_PEN_PATTERN = "magical resistances of your spell targets by (%d+)"

local function spellPenOnLine(text)
    return tonumber(string.match(text, SPELL_PEN_PATTERN))
end

---@return number
function Data:GetSpellPenetration()
    local pen = DataUtils:SumEquippedLines(spellPenOnLine)
    if UnitClass and Data.Talent and Data.Talent[Data.MAGE] then
        local _, _, classId = UnitClass("player")
        local ids = Data.Talent[Data.MAGE].ARCANE_SUBTLETY
        if classId == Data.MAGE and ids and ids[1] then
            pen = pen + 5 * DataUtils:GetActiveTalentSpell(ids)
        end
    end
    return DataUtils:Round(pen, 2)
end

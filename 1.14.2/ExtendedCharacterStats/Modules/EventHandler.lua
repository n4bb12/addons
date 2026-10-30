---@class EventHandler
local EventHandler = ECSLoader:CreateModule("EventHandler")

---@type Stats
local Stats = ECSLoader:ImportModule("Stats")
---@type GearInfos
local GearInfos = ECSLoader:ImportModule("GearInfos")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

-- Equip effects and set bonuses are spell text the client fills in a while after login.
local LATE_TOOLTIP_SECONDS = { 5, 15, 30 }

local function DelayedUpdateInformation()
    local statsFrame = Stats:GetFrame()
    statsFrame:SetScript("OnUpdate", nil)
    -- update next frame
    C_Timer.After(0, function ()
        Stats.UpdateInformation()
    end)
end

local function DelayedUpdateGearColorFrames()
    -- update next frame
    C_Timer.After(0, function ()
        GearInfos.UpdateGearColorFrames()
    end)
end

local function DelayedUpdateInspectGearColorFrames()
    -- update next frame
    C_Timer.After(0, function ()
        GearInfos:UpdateInspectGearColorFrames()
    end)
end

---Event handler for all the events subscribed to in _Init.RegisterEvents
function EventHandler.HandleOnEvent(self,event, ...)
    local args = {...}

    if event == "PLAYER_ENTERING_WORLD" then
        for _, seconds in ipairs(LATE_TOOLTIP_SECONDS) do
            C_Timer.After(seconds, function()
                DataUtils:InvalidateEquippedLines()
                if Stats:GetFrame():IsVisible() then
                    Stats.UpdateInformation()
                end
            end)
        end
        return
    end

    if event == "PLAYER_EQUIPMENT_CHANGED" then
        DataUtils:InvalidateEquippedLines()
    end

    local statsFrame = Stats:GetFrame()

    if statsFrame:IsVisible() then
        if event == "CHARACTER_POINTS_CHANGED" or
            event == "COMBAT_RATING_UPDATE" or
            event == "PLAYER_LEVEL_UP" or
            event == "PLAYER_MOUNT_DISPLAY_CHANGED" or
            event == "SKILL_LINES_CHANGED" or
            event == "SPELL_POWER_CHANGED" or
            event == "UPDATE_SHAPESHIFT_FORM" or ((
                event == "PLAYER_DAMAGE_DONE_MODS" or
                event == "UNIT_ATTACK" or
                event == "UNIT_ATTACK_POWER" or
                event == "UNIT_ATTACK_SPEED" or
                event == "UNIT_AURA" or
                event == "UNIT_DAMAGE" or
                (event == "UNIT_MAXPOWER" and args[2] == "MANA") or
                event == "UNIT_SPELL_HASTE" or
                event == "UNIT_STATS" or
                event == "UNIT_RANGEDDAMAGE" or
                event == "UNIT_RANGED_ATTACK_POWER"
            ) and args[1] == "player") then
            statsFrame:SetScript("OnUpdate", DelayedUpdateInformation)
        elseif (event == "INSPECT_READY" and args[1] == UnitGUID("player")) or event == "PLAYER_EQUIPMENT_CHANGED" then
            statsFrame:SetScript("OnUpdate", DelayedUpdateInformation)
        end
    end

    if (event == "INSPECT_READY" and args[1] == UnitGUID("player")) or event == "PLAYER_EQUIPMENT_CHANGED" then
        DelayedUpdateGearColorFrames()
    end
    if InspectPaperDollFrame and event == "INSPECT_READY" and args[1] == UnitGUID("target") then
        DelayedUpdateInspectGearColorFrames()
    end
end

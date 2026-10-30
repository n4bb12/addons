---@type Config
local Config = ECSLoader:ImportModule("Config")
---@type Stats
local Stats = ECSLoader:ImportModule("Stats")

local function _HandleSlash(msg)
    local cmd = string.lower(msg) or "help"

    if cmd == "toggle" then
        Stats:ToggleWindow()

        if Stats:GetFrame():IsShown() then
            ECS:Print("The ECS stats window is now visible next to the character frame")
        else
            ECS:Print("The ECS stats window is now hidden")
        end
    elseif cmd == "config" then
        Config:ToggleWindow()
    else
        print("Available Commands")
        print("/ecs toggle - Toggles the visibility of the stats window")
        print("/ecs config - Shows the configuration window")
    end
end

SLASH_ECS1 = "/ecs"
SlashCmdList["ECS"] = _HandleSlash

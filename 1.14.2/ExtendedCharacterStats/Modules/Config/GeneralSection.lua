---@class Config
local Config = ECSLoader:ImportModule("Config")
local _Config = Config.private

---@type Stats
local Stats = ECSLoader:ImportModule("Stats")

function _Config:LoadGeneralSection()
    return {
        type = "group",
        order = 1.5,
        inline = false,
        width = 2,
        name = "General",
        args = {
            showGeneralStats = {
                type = "toggle",
                order = 0,
                name = "Show General Stats",
                desc = "Shows/Hides all general stats.",
                width = 1.5,
                get = function () return ExtendedCharacterStats.profile.general.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.general.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            movementSpeed = {
                type = "toggle",
                order = 1,
                name = "Show Movement Speed",
                desc = "Shows/Hides the movement speed value.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.general.display); end,
                get = function () return ExtendedCharacterStats.profile.general.movementSpeed.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.general.movementSpeed.display = value
                    Stats.RebuildStatInfos()
                end,
            },
        },
    }
end
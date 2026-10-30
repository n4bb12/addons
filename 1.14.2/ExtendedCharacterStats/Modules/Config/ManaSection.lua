---@class Config
local Config = ECSLoader:ImportModule("Config")
local _Config = Config.private

---@type Stats
local Stats = ECSLoader:ImportModule("Stats")

function _Config:LoadManaSection()
    return {
        type = "group",
        order = 5,
        inline = false,
        width = 2,
        name = "Mana",
        hidden = function() return not UnitHasMana("player") end,
        args = {
            showManaStats = {
                type = "toggle",
                order = 0,
                name = "Show Mana Stats",
                desc = "Shows/Hides all mana stats.",
                width = 1.5,
                get = function () return ExtendedCharacterStats.profile.regen.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.regen.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            mp5Items = {
                type = "toggle",
                order = 1,
                name = "MP5 Items",
                desc = "Shows/Hides the MP5 value from items.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.regen.display); end,
                get = function () return ExtendedCharacterStats.profile.regen.mp5Items.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.regen.mp5Items.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            mp5Spirit = {
                type = "toggle",
                order = 2,
                name = "MP5 Spirit",
                desc = "Shows/Hides the MP5 value from spirit.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.regen.display); end,
                get = function () return ExtendedCharacterStats.profile.regen.mp5Spirit.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.regen.mp5Spirit.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            mp5Buffs = {
                type = "toggle",
                order = 3,
                name = "MP5 Buffs",
                desc = "Shows/Hides the MP5 value from buffs.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.regen.display); end,
                get = function () return ExtendedCharacterStats.profile.regen.mp5Buffs.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.regen.mp5Buffs.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            mp5Casting = {
                type = "toggle",
                order = 4,
                name = "MP5 Casting",
                desc = "Shows/Hides the MP5 while casting value.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.regen.display); end,
                get = function () return ExtendedCharacterStats.profile.regen.mp5Casting.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.regen.mp5Casting.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            mp5NotCasting = {
                type = "toggle",
                order = 5,
                name = "MP5 (Not casting)",
                desc = "Shows/Hides the MP5 value when outside of the 5 second rule.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.regen.display); end,
                get = function () return ExtendedCharacterStats.profile.regen.mp5NotCasting.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.regen.mp5NotCasting.display = value
                    Stats.RebuildStatInfos()
                end,
            },
        },
    }
end

---@class Config
local Config = ECSLoader:ImportModule("Config")
local _Config = Config.private

---@type Stats
local Stats = ECSLoader:ImportModule("Stats")

function _Config:SpellSchoolsSection()
    return {
        type = "group",
        order = 6,
        inline = false,
        width = 2,
        name = "Spell Schools",
        args = {
            arcane = {
                type = "toggle",
                order = 1,
                name = "Arcane",
                desc = "Shows/Hides all arcane values.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                get = function () return ExtendedCharacterStats.profile.spell.arcane.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.arcane.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            fire = {
                type = "toggle",
                order = 2,
                name = "Fire",
                desc = "Shows/Hides all fire values.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                get = function () return ExtendedCharacterStats.profile.spell.fire.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.fire.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            frost = {
                type = "toggle",
                order = 3,
                name = "Frost",
                desc = "Shows/Hides all frost values.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                get = function () return ExtendedCharacterStats.profile.spell.frost.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.frost.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            holy = {
                type = "toggle",
                order = 4,
                name = "Holy",
                desc = "Shows/Hides all holy values.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                get = function () return ExtendedCharacterStats.profile.spell.holy.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.holy.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            nature = {
                type = "toggle",
                order = 5,
                name = "Nature",
                desc = "Shows/Hides all nature values.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                get = function () return ExtendedCharacterStats.profile.spell.nature.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.nature.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            physical = {
                type = "toggle",
                order = 6,
                name = "Physical",
                desc = "Shows/Hides all physical values.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                get = function () return ExtendedCharacterStats.profile.spell.physical.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.physical.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            shadow = {
                type = "toggle",
                order = 7,
                name = "Shadow",
                desc = "Shows/Hides all shadow values.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                get = function () return ExtendedCharacterStats.profile.spell.shadow.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.shadow.display = value
                    Stats.RebuildStatInfos()
                end,
            },
        },
    }
end

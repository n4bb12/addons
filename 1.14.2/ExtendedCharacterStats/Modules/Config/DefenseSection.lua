---@class Config
local Config = ECSLoader:ImportModule("Config")
local _Config = Config.private

---@type Stats
local Stats = ECSLoader:ImportModule("Stats")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

function _Config:LoadDefenseSection()
    return {
        type = "group",
        order = 4,
        inline = false,
        width = 2,
        name = "Defense",
        args = {
            showDefenseStats = {
                type = "toggle",
                order = 0,
                name = "Show Defense Stats",
                desc = "Shows/Hides all defense stats.",
                width = 1.5,
                get = function () return ExtendedCharacterStats.profile.defense.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            armor = {
                type = "toggle",
                order = 1,
                name = "Armor",
                desc = "Shows/Hides the armor value.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.armor.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.armor.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            meleeCritReduction = {
                type = "toggle",
                order = 1.81,
                name = "Melee Crit Reduction",
                desc = "Shows/Hides the reduction percentage of being critically hit by melee attacks.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.meleeCritReduction.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.meleeCritReduction.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            rangedCritReduction = {
                type = "toggle",
                order = 1.82,
                name = "Ranged Crit Reduction",
                desc = "Shows/Hides the reduction percentage of being critically hit by ranged attacks.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.rangedCritReduction.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.rangedCritReduction.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            spellCritReduction = {
                type = "toggle",
                order = 1.83,
                name = "Spell Crit Reduction",
                desc = "Shows/Hides the reduction percentage of being critically hit by spells.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.spellCritReduction.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.spellCritReduction.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            avoidance = {
                type = "toggle",
                order = 1.85,
                name = "Avoidance",
                desc = "Shows/Hides the total avoidance.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.avoidance.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.avoidance.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            avoidanceBoss = {
                type = "toggle",
                order = 1.86,
                name = "Avoidance (Lvl +3)",
                desc = "Shows/Hides the total avoidance (Lvl +3).",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.avoidanceBoss.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.avoidanceBoss.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            enemyMissChance = {
                type = "toggle",
                order = 1.87,
                name = "Enemy Miss",
                desc = "Shows/Hides the enemy miss chance.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.enemyMissChance.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.enemyMissChance.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            enemyMissChanceBoss = {
                type = "toggle",
                order = 1.88,
                name = "Enemy Miss (Lvl +3)",
                desc = "Shows/Hides the enemy miss chance (Lvl +3).",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.enemyMissChanceBoss.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.enemyMissChanceBoss.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            defense = {
                type = "toggle",
                order = 2,
                name = "Defense",
                desc = "Shows/Hides the defense value.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.defense.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.defense.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            blockChance = {
                type = "toggle",
                order = 3,
                name = "Block Chance",
                desc = "Shows/Hides the block chance.",
                width = 1.5,
                hidden = function() return not IsSpellKnown(107) end,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.blockChance.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.blockChance.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            blockValue = {
                type = "toggle",
                order = 4,
                name = "Block Value",
                desc = "Shows/Hides the block value.",
                width = 1.5,
                hidden = function() return not DataUtils:CanBlock() end,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.blockValue.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.blockValue.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            parry = {
                type = "toggle",
                order = 5,
                name = "Parry Chance",
                desc = "Shows/Hides the parry chance.",
                width = 1.5,
                hidden = function() return not DataUtils:CanParry() end,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.parry.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.parry.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            dodge = {
                type = "toggle",
                order = 6,
                name = "Dodge Chance",
                desc = "Shows/Hides the dodge chance.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.defense.display); end,
                get = function () return ExtendedCharacterStats.profile.defense.dodge.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.defense.dodge.display = value
                    Stats.RebuildStatInfos()
                end,
            },
        },
    }
end

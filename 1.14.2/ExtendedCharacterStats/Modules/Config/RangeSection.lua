---@class Config
local Config = ECSLoader:ImportModule("Config")
local _Config = Config.private

---@type Stats
local Stats = ECSLoader:ImportModule("Stats")

function _Config:LoadRangeSection()
    return {
        type = "group",
        order = 3,
        inline = false,
        width = 2,
        name = "Ranged",
        hidden = function() return UnitHasRelicSlot("player") end,
        args = {
            showRangeStats = {
                type = "toggle",
                order = 0,
                name = "Show Ranged Stats",
                desc = "Shows/Hides all ranged stats.",
                width = 1.5,
                get = function () return ExtendedCharacterStats.profile.ranged.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.ranged.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            rangedAttackPower = {
                type = "toggle",
                order = 1,
                name = "Ranged Attack Power",
                desc = "Shows/Hides the ranged attack power value.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.ranged.display); end,
                get = function () return ExtendedCharacterStats.profile.ranged.attackPower.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.ranged.attackPower.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            rangeCrit = {
                type = "toggle",
                order = 2,
                name = "Ranged Crit",
                desc = "Shows/Hides the ranged crit chance.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.ranged.display); end,
                get = function () return ExtendedCharacterStats.profile.ranged.crit.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.ranged.crit.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            rangedAttackSpeed = {
                type = "toggle",
                order = 3,
                name = "Attack Speed",
                desc = "Shows/Hides the ranged attack speed.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.ranged.display); end,
                get = function () return ExtendedCharacterStats.profile.ranged.attackSpeed.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.ranged.attackSpeed.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            rangeHit = {
                type = "toggle",
                order = 4,
                name = "Ranged Hit",
                desc = "Shows/Hides all ranged hit chance.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.ranged.display); end,
                get = function () return ExtendedCharacterStats.profile.ranged.hit.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.ranged.hit.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            rangeHitGroup = {
                type = "group",
                order = 5,
                inline = true,
                name = "Ranged Hit Values",
                args = {
                    rangeHitBonus = {
                        type = "toggle",
                        order = 2,
                        name = "Hit Bonus",
                        desc = "Shows/Hides the ranged hit bonus.",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.ranged.display) or
                                    (not ExtendedCharacterStats.profile.ranged.hit.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.ranged.hit.bonus.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.ranged.hit.bonus.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    rangeMiss = {
                        type = "toggle",
                        order = 3,
                        name = "Miss Chance",
                        desc = "Shows/Hides the ranged miss chance against enemies on the same level.",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.ranged.display) or
                                    (not ExtendedCharacterStats.profile.ranged.hit.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.ranged.hit.sameLevel.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.ranged.hit.sameLevel.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    rangeMissBoss = {
                        type = "toggle",
                        order = 4,
                        name = "Miss Chance Boss",
                        desc = "Shows/Hides the ranged miss chance against boss enemies (+3 Level).",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.ranged.display) or
                                    (not ExtendedCharacterStats.profile.ranged.hit.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.ranged.hit.bossLevel.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.ranged.hit.bossLevel.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                }
            },
        },
    }
end

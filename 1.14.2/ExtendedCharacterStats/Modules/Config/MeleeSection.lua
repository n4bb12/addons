---@class Config
local Config = ECSLoader:ImportModule("Config")
local _Config = Config.private

---@type Stats
local Stats = ECSLoader:ImportModule("Stats")

function _Config:LoadMeleeSection()
    return {
        type = "group",
        order = 2,
        inline = false,
        width = 2,
        name = "Melee",
        args = {
            showMeleeStats = {
                type = "toggle",
                order = 0,
                name = "Show Melee Stats",
                desc = "Shows/Hides all melee stats.",
                width = 1.5,
                get = function () return ExtendedCharacterStats.profile.melee.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.melee.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            meleeAttackPower = {
                type = "toggle",
                order = 1,
                name = "Melee Attack Power",
                desc = "Shows/Hides the melee attack power value.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.melee.display); end,
                get = function () return ExtendedCharacterStats.profile.melee.attackPower.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.melee.attackPower.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            meleeCrit = {
                type = "toggle",
                order = 2,
                name = "Melee Crit",
                desc = "Shows/Hides the melee crit chance.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.melee.display); end,
                get = function () return ExtendedCharacterStats.profile.melee.crit.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.melee.crit.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            meleeHit = {
                type = "toggle",
                order = 3,
                name = "Melee Hit",
                desc = "Shows/Hides all melee hit chance.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.melee.display); end,
                get = function () return ExtendedCharacterStats.profile.melee.hit.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.melee.hit.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            meleeHitGroup = {
                type = "group",
                order = 4,
                inline = true,
                name = "Melee Hit Values",
                args = {
                    meleeHitBonus = {
                        type = "toggle",
                        order = 2,
                        name = "Hit Bonus",
                        desc = "Shows/Hides the melee hit bonus.",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.melee.display) or
                                    (not ExtendedCharacterStats.profile.melee.hit.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.melee.hit.bonus.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.melee.hit.bonus.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    meleeMiss = {
                        type = "toggle",
                        order = 3,
                        name = "Miss Chance",
                        desc = "Shows/Hides the melee miss chance against enemies on the same level.",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.melee.display) or
                                    (not ExtendedCharacterStats.profile.melee.hit.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.melee.hit.sameLevel.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.melee.hit.sameLevel.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    meleeMissBoss = {
                        type = "toggle",
                        order = 4,
                        name = "Miss Chance Boss",
                        desc = "Shows/Hides the melee miss chance against boss enemies (+3 Level).",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.melee.display) or
                                    (not ExtendedCharacterStats.profile.melee.hit.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.melee.hit.bossLevel.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.melee.hit.bossLevel.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                },
            },
            glancingBlow = {
                type = "toggle",
                order = 5,
                name = "Glancing Blow",
                desc = "Shows/Hides all glancing blow stats",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.melee.display); end,
                get = function () return ExtendedCharacterStats.profile.melee.glance.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.melee.glance.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            meleeGlanceGroup = {
                type = "group",
                order = 6,
                inline = true,
                name = "Melee Glance Values",
                args = {
                    meleeGlance = {
                        type = "toggle",
                        order = 1,
                        name = "Glancing Blow Chance",
                        desc = "Shows/Hides the glancing chance against enemies on same level.",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.melee.display) or
                                    (not ExtendedCharacterStats.profile.melee.glance.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.melee.glance.sameLevel.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.melee.glance.sameLevel.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    meleeGlanceBoss = {
                        type = "toggle",
                        order = 2,
                        name = "Glancing Blow Chance Boss",
                        desc = "Shows/Hides the glancing chance against boss enemies (+3 Level).",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.melee.display) or
                                    (not ExtendedCharacterStats.profile.melee.glance.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.melee.glance.bossLevel.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.melee.glance.bossLevel.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    meleeGlanceDamage = {
                        type = "toggle",
                        order = 3,
                        name = "Glancing Blow Damage",
                        desc = "Shows/Hides the damage reduction against enemies on the same level.",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.melee.display) or
                                    (not ExtendedCharacterStats.profile.melee.glance.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.melee.glance.damageSameLevel.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.melee.glance.damageSameLevel.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    meleeGlanceDamageBoss = {
                        type = "toggle",
                        order = 4,
                        name = "Glancing Blow Damage Boss",
                        desc = "Shows/Hides the damage reduction against boss enemies (+3 Level).",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.melee.display) or
                                    (not ExtendedCharacterStats.profile.melee.glance.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.melee.glance.damageBossLevel.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.melee.glance.damageBossLevel.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                }
            },
            meleeAttackSpeed = {
                type = "toggle",
                order = 7,
                name = "Attack Speed",
                desc = "Shows/Hides the melee attack speed.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.melee.display); end,
                get = function () return ExtendedCharacterStats.profile.melee.attackSpeed.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.melee.attackSpeed.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            meleeAttackSpeedGroup = {
                type = "group",
                order = 8,
                inline = true,
                name = "Attack Speed",
                args = {
                    mainHand = {
                        type = "toggle",
                        order = 1,
                        name = "Main Hand",
                        desc = "Shows/Hides the attack speed of the main hand.",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.melee.display) or
                                    (not ExtendedCharacterStats.profile.melee.attackSpeed.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.melee.attackSpeed.mainHand.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.melee.attackSpeed.mainHand.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    offHand = {
                        type = "toggle",
                        order = 2,
                        name = "Off Hand",
                        hidden = function() return not CanDualWield() end,
                        desc = "Shows/Hides the attack speed of the off hand.",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.melee.display) or
                                    (not ExtendedCharacterStats.profile.melee.attackSpeed.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.melee.attackSpeed.offHand.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.melee.attackSpeed.offHand.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                }
            },
        },
    }
end

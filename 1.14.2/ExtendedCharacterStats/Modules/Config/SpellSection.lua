---@class Config
local Config = ECSLoader:ImportModule("Config")
local _Config = Config.private

---@type Stats
local Stats = ECSLoader:ImportModule("Stats")

function _Config:LoadSpellSection()
    return {
        type = "group",
        order = 7,
        inline = false,
        width = 2,
        name = "Spell",
        args = {
            showSpellStats = {
                type = "toggle",
                order = 0,
                name = "Show Spell Stats",
                desc = "Shows/Hides all spell stats.",
                width = 1.5,
                get = function () return ExtendedCharacterStats.profile.spell.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            spellCrit = {
                type = "toggle",
                order = 1,
                name = "Spell Crit",
                desc = "Shows/Hides the spell crit chance.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                get = function () return ExtendedCharacterStats.profile.spell.crit.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.crit.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            hasteBonus = {
                type = "toggle",
                order = 3,
                name = "Haste Bonus",
                desc = "Shows/Hides the spell haste bonus value.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                get = function () return ExtendedCharacterStats.profile.spell.hasteBonus.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.hasteBonus.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            spellPenetration = {
                type = "toggle",
                order = 4,
                name = "Spell Penetration",
                desc = "Shows/Hides the spell penetration value.",
                width = 1.5,
                disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                get = function () return ExtendedCharacterStats.profile.spell.penetration.display; end,
                set = function (_, value)
                    ExtendedCharacterStats.profile.spell.penetration.display = value
                    Stats.RebuildStatInfos()
                end,
            },
            spellHitGroup = {
                type = "group",
                order = 5,
                inline = true,
                name = "Spell Hit Values",
                args = {
                    spellHitBonus = {
                        type = "toggle",
                        order = 2,
                        name = "Hit Bonus",
                        desc = "Shows/Hides the spell hit bonus.",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.spell.display) or
                                    (not ExtendedCharacterStats.profile.spell.hit.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.spell.hit.bonus.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spell.hit.bonus.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    spellMiss = {
                        type = "toggle",
                        order = 3,
                        name = "Miss Chance",
                        desc = "Shows/Hides the spell miss chance against enemies on the same level.",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.spell.display) or
                                    (not ExtendedCharacterStats.profile.spell.hit.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.spell.hit.sameLevel.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spell.hit.sameLevel.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    spellMissBoss = {
                        type = "toggle",
                        order = 4,
                        name = "Miss Chance Boss",
                        desc = "Shows/Hides the spell miss chance against boss enemies (+3 Level).",
                        width = 1.5,
                        disabled = function()
                            return ((not ExtendedCharacterStats.profile.spell.display) or
                                    (not ExtendedCharacterStats.profile.spell.hit.display))
                        end,
                        get = function () return ExtendedCharacterStats.profile.spell.hit.bossLevel.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spell.hit.bossLevel.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                }
            },
            spellPower = {
                type = "group",
                order = 6,
                inline = true,
                name = "Spell Power",
                args = {
                    baseSpellDmg = {
                        type = "toggle",
                        order = 1,
                        name = "Spell Damage",
                        desc = "Shows/Hides the base spell damage value (lowest of all spell schools).",
                        width = 1.5,
                        disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                        get = function () return ExtendedCharacterStats.profile.spellBonus.baseSpellDmg.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spellBonus.baseSpellDmg.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    bonusHealing = {
                        type = "toggle",
                        order = 2,
                        name = "Healing Power",
                        desc = "Shows/Hides the healing power value.",
                        width = 1.5,
                        disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                        get = function () return ExtendedCharacterStats.profile.spellBonus.bonusHealing.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spellBonus.bonusHealing.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    arcaneDmg = {
                        type = "toggle",
                        order = 3,
                        name = "Arcane Damage",
                        desc = "Shows/Hides the arcane damage value.",
                        width = 1.5,
                        disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                        get = function () return ExtendedCharacterStats.profile.spellBonus.arcaneDmg.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spellBonus.arcaneDmg.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    fireDmg = {
                        type = "toggle",
                        order = 4,
                        name = "Fire Damage",
                        desc = "Shows/Hides the fire damage value.",
                        width = 1.5,
                        disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                        get = function () return ExtendedCharacterStats.profile.spellBonus.fireDmg.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spellBonus.fireDmg.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    frostDmg = {
                        type = "toggle",
                        order = 5,
                        name = "Frost Damage",
                        desc = "Shows/Hides the frost damage value.",
                        width = 1.5,
                        disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                        get = function () return ExtendedCharacterStats.profile.spellBonus.frostDmg.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spellBonus.frostDmg.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    holyDmg = {
                        type = "toggle",
                        order = 6,
                        name = "Holy Damage",
                        desc = "Shows/Hides the holy damage value.",
                        width = 1.5,
                        disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                        get = function () return ExtendedCharacterStats.profile.spellBonus.holyDmg.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spellBonus.holyDmg.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    natureDmg = {
                        type = "toggle",
                        order = 7,
                        name = "Nature Damage",
                        desc = "Shows/Hides the nature damage value.",
                        width = 1.5,
                        disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                        get = function () return ExtendedCharacterStats.profile.spellBonus.natureDmg.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spellBonus.natureDmg.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    physicalDmg = {
                        type = "toggle",
                        order = 8,
                        name = "Physical Damage",
                        desc = "Shows/Hides the physical damage value.",
                        width = 1.5,
                        disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                        get = function () return ExtendedCharacterStats.profile.spellBonus.physicalDmg.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spellBonus.physicalDmg.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                    shadowDmg = {
                        type = "toggle",
                        order = 9,
                        name = "Shadow Damage",
                        desc = "Shows/Hides the shadow damage value.",
                        width = 1.5,
                        disabled = function() return (not ExtendedCharacterStats.profile.spell.display); end,
                        get = function () return ExtendedCharacterStats.profile.spellBonus.shadowDmg.display; end,
                        set = function (_, value)
                            ExtendedCharacterStats.profile.spellBonus.shadowDmg.display = value
                            Stats.RebuildStatInfos()
                        end,
                    },
                }
            }
        },
    }
end

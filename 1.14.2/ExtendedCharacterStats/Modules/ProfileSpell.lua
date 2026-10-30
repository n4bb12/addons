---@class Profile
local Profile = ECSLoader:ImportModule("Profile")
---@type Utils
local Utils = ECSLoader:ImportModule("Utils")

--- Spell schools, crit, and hit rows. The rest of the default profile stays in Profile.lua.
---@return table
function Profile.DefaultSpell()
    local colors = Utils.colors
    return {
            display = true,
            refName = "SpellHeader",
            text = "Spell",

            arcane = {
                display = true,
            },
            fire = {
                display = true,
            },
            frost = {
                display = true,
            },
            holy = {
                display = true,
            },
            nature = {
                display = true,
            },
            physical = {
                display = true,
            },
            shadow = {
                display = true,
            },

            ---@type SubCategory
            hit = {
                display = true,
                isSubGroup = true,
                refName = "SpellHitHeader",
                text = "Hit",

                bonus = {
                    display = true,
                    refName = "SpellHitBonus",
                    text = "Hit Bonus",
                    textColor = colors.HIT_SECONDARY,
                    statColor = colors.HIT_PRIMARY
                },
                sameLevel = {
                    display = true,
                    refName = "SpellHitSameLevel",
                    text = "Miss",
                    textColor = colors.HIT_SECONDARY,
                    statColor = colors.HIT_PRIMARY
                },
                bossLevel = {
                    display = true,
                    refName = "SpellHitBossLevel",
                    text = "Miss (Lvl + 3)",
                    textColor = colors.HIT_SECONDARY,
                    statColor = colors.HIT_PRIMARY
                },
                arcaneHitBonus = {
                    display = true,
                    refName = "ArcaneHitBonus",
                    text = "Arcane Hit Bonus",
                    textColor = colors.ARCANE_SECONDARY,
                    statColor = colors.ARCANE_PRIMARY
                },
                arcaneMissChance = {
                    display = true,
                    refName = "ArcaneMissChance",
                    text = "Arcane Miss",
                    textColor = colors.ARCANE_SECONDARY,
                    statColor = colors.ARCANE_PRIMARY
                },
                arcaneMissChanceBoss = {
                    display = true,
                    refName = "ArcaneMissChanceBoss",
                    text = "Arcane Miss (Lvl + 3)",
                    textColor = colors.ARCANE_SECONDARY,
                    statColor = colors.ARCANE_PRIMARY
                },
                fireHitBonus = {
                    display = true,
                    refName = "FireHitBonus",
                    text = "Fire Hit Bonus",
                    textColor = colors.FIRE_SECONDARY,
                    statColor = colors.FIRE_PRIMARY
                },
                fireMissChance = {
                    display = true,
                    refName = "FireMissChance",
                    text = "Fire Miss",
                    textColor = colors.FIRE_SECONDARY,
                    statColor = colors.FIRE_PRIMARY
                },
                fireMissChanceBoss = {
                    display = true,
                    refName = "FireMissChanceBoss",
                    text = "Fire Miss (Lvl + 3)",
                    textColor = colors.FIRE_SECONDARY,
                    statColor = colors.FIRE_PRIMARY
                },
                frostHitBonus = {
                    display = true,
                    refName = "FrostHitBonus",
                    text = "Frost Hit Bonus",
                    textColor = colors.FROST_SECONDARY,
                    statColor = colors.FROST_PRIMARY
                },
                frostMissChance = {
                    display = true,
                    refName = "FrostMissChance",
                    text = "Frost Miss",
                    textColor = colors.FROST_SECONDARY,
                    statColor = colors.FROST_PRIMARY
                },
                frostMissChanceBoss = {
                    display = true,
                    refName = "FrostMissChanceBoss",
                    text = "Frost Miss (Lvl + 3)",
                    textColor = colors.FROST_SECONDARY,
                    statColor = colors.FROST_PRIMARY
                },
                holyHitBonus = {
                    display = true,
                    refName = "HolyHitBonus",
                    text = "Holy Hit Bonus",
                    textColor = colors.HOLY_SECONDARY,
                    statColor = colors.HOLY_PRIMARY
                },
                holyMissChance = {
                    display = true,
                    refName = "HolyMissChance",
                    text = "Holy Miss",
                    textColor = colors.HOLY_SECONDARY,
                    statColor = colors.HOLY_PRIMARY
                },
                holyMissChanceBoss = {
                    display = true,
                    refName = "HolyMissChanceBoss",
                    text = "Holy Miss (Lvl + 3)",
                    textColor = colors.HOLY_SECONDARY,
                    statColor = colors.HOLY_PRIMARY
                },
                natureHitBonus = {
                    display = true,
                    refName = "NatureHitBonus",
                    text = "Nature Hit Bonus",
                    textColor = colors.NATURE_SECONDARY,
                    statColor = colors.NATURE_PRIMARY
                },
                natureMissChance = {
                    display = true,
                    refName = "NatureMissChance",
                    text = "Nature Miss",
                    textColor = colors.NATURE_SECONDARY,
                    statColor = colors.NATURE_PRIMARY
                },
                natureMissChanceBoss = {
                    display = true,
                    refName = "NatureMissChanceBoss",
                    text = "Nature Miss (Lvl + 3)",
                    textColor = colors.NATURE_SECONDARY,
                    statColor = colors.NATURE_PRIMARY
                },
                physicalHitBonus = {
                    display = true,
                    refName = "PhysicalHitBonus",
                    text = "Physical Hit Bonus",
                    textColor = colors.PHYSICAL_SECONDARY,
                    statColor = colors.PHYSICAL_PRIMARY
                },
                physicalMissChance = {
                    display = true,
                    refName = "PhysicalMissChance",
                    text = "Physical Miss",
                    textColor = colors.PHYSICAL_SECONDARY,
                    statColor = colors.PHYSICAL_PRIMARY
                },
                physicalMissChanceBoss = {
                    display = true,
                    refName = "PhysicalMissChanceBoss",
                    text = "Physical Miss (Lvl + 3)",
                    textColor = colors.PHYSICAL_SECONDARY,
                    statColor = colors.PHYSICAL_PRIMARY
                },
                shadowHitBonus = {
                    display = true,
                    refName = "ShadowHitBonus",
                    text = "Shadow Hit Bonus",
                    textColor = colors.SHADOW_SECONDARY,
                    statColor = colors.SHADOW_PRIMARY
                },
                shadowMissChance = {
                    display = true,
                    refName = "ShadowMissChance",
                    text = "Shadow Miss",
                    textColor = colors.SHADOW_SECONDARY,
                    statColor = colors.SHADOW_PRIMARY
                },
                shadowMissChanceBoss = {
                    display = true,
                    refName = "ShadowMissChanceBoss",
                    text = "Shadow Miss (Lvl + 3)",
                    textColor = colors.SHADOW_SECONDARY,
                    statColor = colors.SHADOW_PRIMARY
                },
            },
            hasteBonus = {
                display = true,
                refName = "SpellHasteBonus",
                text = "Haste Bonus",
                textColor = colors.HASTE_RATING_SECONDARY,
                statColor = colors.HASTE_RATING_PRIMARY
            },
            penetration = { display = true, refName = "SpellPenetration", text = "Spell Penetration" },

            crit = {
                display = true,
                arcane = {
                    display = true,
                    refName = "ArcaneCritChance",
                    text = "Arcane Crit",
                    textColor = colors.ARCANE_SECONDARY,
                    statColor = colors.ARCANE_PRIMARY
                },
                fire = {
                    display = true,
                    refName = "FireCritChance",
                    text = "Fire Crit",
                    textColor = colors.FIRE_SECONDARY,
                    statColor = colors.FIRE_PRIMARY
                },
                frost = {
                    display = true,
                    refName = "FrostCritChance",
                    text = "Frost Crit",
                    textColor = colors.FROST_SECONDARY,
                    statColor = colors.FROST_PRIMARY
                },
                holy = {
                    display = true,
                    refName = "HolyCritChance",
                    text = "Holy Crit",
                    textColor = colors.HOLY_SECONDARY,
                    statColor = colors.HOLY_PRIMARY
                },
                nature = {
                    display = true,
                    refName = "NatureCritChance",
                    text = "Nature Crit",
                    textColor = colors.NATURE_SECONDARY,
                    statColor = colors.NATURE_PRIMARY
                },
                physical = {
                    display = true,
                    refName = "PhysicalCritChance",
                    text = "Physical Crit",
                    textColor = colors.PHYSICAL_SECONDARY,
                    statColor = colors.PHYSICAL_PRIMARY
                },
                shadow = {
                    display = true,
                    refName = "ShadowCritChance",
                    text = "Shadow Crit",
                    textColor = colors.SHADOW_SECONDARY,
                    statColor = colors.SHADOW_PRIMARY
                },
            }
    }
end

--- Spell damage and healing rows.
---@return table
function Profile.DefaultSpellBonus()
    local colors = Utils.colors
    return {
            display = true,
            refName = "SpellBonusHeader",

            baseSpellDmg = {
                display = true,
                refName = "BaseSpellDmg",
                text = "Spell Damage",
                textColor = colors.GRAY,
                statColor = colors.WHITE
            },
            bonusHealing = {
                display = true,
                refName = "BonusHealing",
                text = "Healing Power",
                textColor = colors.HEALING_SECONDARY,
                statColor = colors.HEALING_PRIMARY
            },
            arcaneDmg = {
                display = true,
                refName = "ArcaneDmg",
                text = "Arcane Damage",
                textColor = colors.ARCANE_SECONDARY,
                statColor = colors.ARCANE_PRIMARY
            },
            fireDmg = {
                display = true,
                refName = "FireDmg",
                text = "Fire Damage",
                textColor = colors.FIRE_SECONDARY,
                statColor = colors.FIRE_PRIMARY
            },
            frostDmg = {
                display = true,
                refName = "FrostDmg",
                text = "Frost Damage",
                textColor = colors.FROST_SECONDARY,
                statColor = colors.FROST_PRIMARY
            },
            holyDmg = {
                display = true,
                refName = "HolyDmg",
                text = "Holy Damage",
                textColor = colors.HOLY_SECONDARY,
                statColor = colors.HOLY_PRIMARY
            },
            natureDmg = {
                display = true,
                refName = "NatureDmg",
                text = "Nature Damage",
                textColor = colors.NATURE_SECONDARY,
                statColor = colors.NATURE_PRIMARY
            },
            physicalDmg = {
                display = true,
                refName = "PhysicalDmg",
                text = "Physical Damage",
                textColor = colors.PHYSICAL_SECONDARY,
                statColor = colors.PHYSICAL_PRIMARY
            },
            shadowDmg = {
                display = true,
                refName = "ShadowDmg",
                text = "Shadow Damage",
                textColor = colors.SHADOW_SECONDARY,
                statColor = colors.SHADOW_PRIMARY
            },
    }
end

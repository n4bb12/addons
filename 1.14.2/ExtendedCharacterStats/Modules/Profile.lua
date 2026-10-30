---@class Profile
local Profile = ECSLoader:CreateModule("Profile")

---@type Utils
local Utils = ECSLoader:ImportModule("Utils")

---@return number
function Profile.GetProfileVersion()
    return 26
end

---@return ECSProfile
local function GetDefaultStatsProfile()
    local colors = Utils.colors

    return {
        general = {
            display = true,
            refName = "GeneralHeader",
            text = "General",

            movementSpeed = { display = true, refName = "MovementSpeed", text = "Movement Speed" },
        },

        melee = {
            display = true,
            refName = "MeleeHeader",
            text = "Melee",

            hit = {
                display = true,
                isSubGroup = true,
                refName = "MeleeHitHeader",
                text = "Hit",

                bonus = {
                    display = true,
                    refName = "MeleeHitBonus",
                    text = "Bonus",
                    textColor = colors.HIT_SECONDARY,
                    statColor = colors.HIT_PRIMARY
                },
                sameLevel = {
                    display = true,
                    refName = "MeleeHitSameLevel",
                    text = "Miss",
                    textColor = colors.HIT_SECONDARY,
                    statColor = colors.HIT_PRIMARY
                },
                bossLevel = {
                    display = true,
                    refName = "MeleeHitBossLevel",
                    text = "Miss (Lvl + 3)",
                    textColor = colors.HIT_SECONDARY,
                    statColor = colors.HIT_PRIMARY
                },
            },
            glance = {
                display = true,
                isSubGroup = true,
                refName = "GlanceChanceHeader",
                text = "Glancing Blow",
                sameLevel = {
                    display = true,
                    refName = "GlanceHitChanceSameLevel",
                    text = "Chance",
                    textColor = colors.GRAY,
                    statColor = colors.WHITE
                },
                bossLevel = {
                    display = true,
                    refName = "GlanceHitChanceBossLevel",
                    text = "Chance (Lvl + 3)",
                    textColor = colors.GRAY,
                    statColor = colors.WHITE
                },
                damageSameLevel = {
                    display = true,
                    refName = "GlanceDamageSameLevel",
                    text = "Damage",
                    textColor = colors.GRAY,
                    statColor = colors.WHITE
                },
                damageBossLevel = {
                    display = true,
                    refName = "GlanceDamageBossLevel",
                    text = "Damage (Lvl + 3)",
                    textColor = colors.GRAY,
                    statColor = colors.WHITE
                },
            },
            attackPower = {
                display = true,
                refName = "MeleeAttackPower",
                text = "Attack Power",
                textColor = colors.ATTACK_POWER_SECONDARY,
                statColor = colors.ATTACK_POWER_PRIMARY
            },
            crit = {
                display = true,
                refName = "MeleeCritChance",
                text = "Crit Chance",
                textColor = colors.CRIT_SECONDARY,
                statColor = colors.CRIT_PRIMARY
            },
            attackSpeed = {
                display = true,
                isSubGroup = true,
                refName = "MeleeAttackSpeedHeader",
                text = "Attack Speed",

                mainHand = {
                    display = true,
                    refName = "MeleeAttackSpeedMainHand",
                    text = "Main Hand",
                    textColor = colors.ATTACK_SPEED_SECONDARY,
                    statColor = colors.ATTACK_SPEED_PRIMARY
                },
                offHand = {
                    display = true,
                    refName = "MeleeAttackSpeedOffHand",
                    text = "Off Hand",
                    textColor = colors.ATTACK_SPEED_SECONDARY,
                    statColor = colors.ATTACK_SPEED_PRIMARY
                },
            },
        },

        ranged = {
            display = true,
            refName = "RangedHeader",
            text = "Ranged",

            ---@type SubCategory
            hit = {
                display = true,
                isSubGroup = true,
                refName = "RangedHitHeader",
                text = "Hit",

                bonus = {
                    display = true,
                    refName = "RangedHitBonus",
                    text = "Bonus",
                    textColor = colors.HIT_SECONDARY,
                    statColor = colors.HIT_PRIMARY
                },
                sameLevel = {
                    display = true,
                    refName = "RangedHitSameLevel",
                    text = "Miss",
                    textColor = colors.HIT_SECONDARY,
                    statColor = colors.HIT_PRIMARY
                },
                bossLevel = {
                    display = true,
                    refName = "RangedHitBossLevel",
                    text = "Miss (Lvl + 3)",
                    textColor = colors.HIT_SECONDARY,
                    statColor = colors.HIT_PRIMARY
                },
            },
            attackPower = {
                display = true,
                refName = "RangeAttackpower",
                text = "Attack Power",
                textColor = colors.ATTACK_POWER_SECONDARY,
                statColor = colors.ATTACK_POWER_PRIMARY
            },
            crit = {
                display = true,
                refName = "RangedCritChance",
                text = "Crit Chance",
                textColor = colors.CRIT_SECONDARY,
                statColor = colors.CRIT_PRIMARY
            },
            attackSpeed = {
                display = true,
                refName = "RangedAttackSpeed",
                text = "Attack Speed",
                textColor = colors.ATTACK_SPEED_SECONDARY,
                statColor = colors.ATTACK_SPEED_PRIMARY
            },
        },

        defense = {
            display = true,
            refName = "DefenseHeader",
            text = "Defense",

            armor = { display = true, refName = "Armor", text = "Armor" },
            meleeCritReduction = { display = true, refName = "MeleeCritReduction", text = "Melee Crit Reduction" },
            rangedCritReduction = { display = true, refName = "RangedCritReduction", text = "Ranged Crit Reduction" },
            spellCritReduction = { display = true, refName = "SpellCritReduction", text = "Spell Crit Reduction" },
            avoidance = { display = true, refName = "Avoidance", text = "Avoidance" },
            avoidanceBoss = { display = true, refName = "AvoidanceBoss", text = "Avoidance (Lvl +3)" },
            enemyMissChance = { display = true, refName = "EnemyMissChance", text = "Enemy Miss" },
            enemyMissChanceBoss = { display = true, refName = "EnemyMissChanceBoss", text = "Enemy Miss (Lvl +3)" },
            defense = { display = true, refName = "DefenseValue", text = "Defense" },
            blockChance = { display = true, refName = "BlockChance", text = "Block Chance" },
            blockValue = { display = true, refName = "BlockValue", text = "Block Value" },
            parry = { display = true, refName = "ParryChance", text = "Parry Chance" },
            dodge = { display = true, refName = "DodgeChance", text = "Dodge Chance" },
        },

        regen = {
            display = true,
            refName = "ManaHeader",
            text = "Mana",

            mp5Items = {
                display = true,
                refName = "MP5Items",
                text = "MP5 (Items)",
                textColor = colors.MP5_SECONDARY,
                statColor = colors.MP5_PRIMARY
            },
            mp5Spirit = {
                display = true,
                refName = "MP5Spirit",
                text = "MP5 (Spirit)",
                textColor = colors.MP5_SECONDARY,
                statColor = colors.MP5_PRIMARY
            },
            mp5Buffs = {
                display = true,
                refName = "MP5Buffs",
                text = "MP5 (Buffs)",
                textColor = colors.MP5_SECONDARY,
                statColor = colors.MP5_PRIMARY
            },
            mp5Casting = {
                display = true,
                refName = "MP5Casting",
                text = "MP5 (Casting)",
                textColor = colors.MP5_SECONDARY,
                statColor = colors.MP5_PRIMARY
            },
            mp5NotCasting = {
                display = true,
                refName = "MP5NotCasting",
                text = "MP5 (Not casting)",
                textColor = colors.MP5_SECONDARY,
                statColor = colors.MP5_PRIMARY
            },
        },

        spell = Profile.DefaultSpell(),
        spellBonus = Profile.DefaultSpellBonus(),
    }
end

local function GetDefaultGeneralSettings()
    return {
        statsWindowClosedOnOpen = false,
        addColorsToStatTexts = true,
        statColorSelection = "full",
        showQualityColors = true,
        qualityColorsIntensity = 0.75,
        headerFontSize = 11,
        statFontSize = 10,
        profileVersion = 0,
        window = {
            height = 422,
            width = 195,
            xOffset = -30,
            yOffset = 30
        }
    }
end

---@return ECSProfile
function Profile:GetDefaultProfile()
    return {
        general = GetDefaultGeneralSettings(),
        profile = GetDefaultStatsProfile(),
    }
end

function Profile:Reset()
    local defaultProfile = Profile:GetDefaultProfile()
    ExtendedCharacterStats.profile = defaultProfile.profile
    ExtendedCharacterStats.general = defaultProfile.general
end

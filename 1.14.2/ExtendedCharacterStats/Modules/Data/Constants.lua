---@class Data
local Data = ECSLoader:ImportModule("Data")

Data.PHYSICAL_SCHOOL = 1
Data.HOLY_SCHOOL = 2
Data.FIRE_SCHOOL = 3
Data.NATURE_SCHOOL = 4
Data.FROST_SCHOOL = 5
Data.SHADOW_SCHOOL = 6
Data.ARCANE_SCHOOL = 7

Data.WARRIOR = 1
Data.PALADIN = 2
Data.HUNTER = 3
Data.ROGUE = 4
Data.PRIEST = 5
Data.DEATHKNIGHT = 6
Data.SHAMAN = 7
Data.MAGE = 8
Data.WARLOCK = 9
Data.DRUID = 11

Data.Enchant = {
    Ids = {
        BIZNICK_SCOPE = 2523, -- 3% Hit from Biznicks 247x128 Accurascope
    },
    -- Temporary weapon enchants. Permanent enchants are read from their tooltip lines.
    MP5 = {
        [2624] = 4, -- Minor Mana Oil
        [2625] = 8, -- Lesser Mana Oil
        [2629] = 12, -- Brilliant Mana Oil
    },
}
-- A gem id in an item link is looked up here. 1.12 gear is not socketed, so the table is empty.
Data.Gem = {
    MP5 = {},
}
Data.setNames = {
    AUGURS_REGALIA = "Augur's Regalia",
    BLOODSOUL_EMBRACE = "Bloodsoul Embrace",
    FREETHINKERS_ARMOR = "Freethinker's Armor",
    GREEN_DRAGON_MAIL = "Green Dragon Mail",
    HARUSPEXS_GARB = "Haruspex's Garb",
    STORMRAGE_RAIMENT = "Stormrage Raiment",
    TEN_STORMS = "The Ten Storms",
    THE_EARTHSHATTERER = "The Earthshatterer",
    VESTMENTS_OF_TRANSCENDENCE = "Vestments of Transcendence",
}
Data.Talent = {
    -- keep-sorted start block=yes
    [Data.DRUID] = {
        -- keep-sorted start
        INTENSITY_REFLECTION = {17106,17107,17108},
        -- keep-sorted end
    },
    [Data.HUNTER] = {
        -- keep-sorted start
        SUREFOOTED = {19290,19294,24283},
        -- keep-sorted end
    },
    [Data.MAGE] = {
        -- keep-sorted start
        ARCANE_FOCUS = {11222,12839,12840,12841,12842},
        ARCANE_INSTABILITY = {15058,15059,15060},
        ARCANE_MEDITATION = {18462,18463,18464},
        ARCANE_SUBTLETY = {11210,12592},
        CRITICAL_MASS = {11115,11367,11368},
        ELEMENTAL_PRECISION = {29438,29439,29440},
        -- keep-sorted end
    },
    [Data.PALADIN] = {
        -- keep-sorted start
        CONVICTION = {20117,20118,20119,20120,20121},
        HOLY_POWER = {5923,5924,5925,5926,25829},
        PRECISION = {20189,20192,20193},
        SHIELD_SPECIALIZATION = {20148,20149,20150},
        -- keep-sorted end
    },
    [Data.PRIEST] = {
        -- keep-sorted start
        HOLY_SPECIALIZATION = {14889,15008,15009,15010,15011},
        MEDITATION = {14521,14776,14777},
        SHADOW_FOCUS = {15260,15327,15328,15329,15330},
        -- keep-sorted end
    },
    [Data.ROGUE] = {
        -- keep-sorted start
        PRECISION = {13705,13832,13843,13844,13845},
        SLEIGHT_OF_HAND = {30892,30893},
        -- keep-sorted end
    },
    [Data.SHAMAN] = {
        -- keep-sorted start
        NATURES_GUIDANCE = {16180,16196,16198},
        SHIELD_SPECIALIZATION = {16253,16298,16299,16300,16301},
        THUNDERING_STRIKES = {16255,16302,16303,16304,16305},
        TIDAL_MASTERY = {16194,16218,16219,16220,16221},
        -- keep-sorted end
    },
    [Data.WARLOCK] = {
        -- keep-sorted start
        DEVASTATION = {18130,18131,18132,18133,18134},
        SUPPRESSION = {18174,18175,18176},
        -- keep-sorted end
    },
    -- keep-sorted end
}

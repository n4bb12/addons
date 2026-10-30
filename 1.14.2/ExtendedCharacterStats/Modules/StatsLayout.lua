---@class Stats
local Stats = ECSLoader:ImportModule("Stats")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

--- Creates all categories with headers and their child values
Stats.CreateStatInfos = function()
    local profile = ExtendedCharacterStats.profile

    local category = profile.general
    Stats.CreateStatInfo(category, category.movementSpeed)

    category = profile.melee
    Stats.CreateStatInfo(
        category,
        category.attackPower,
        category.crit
    )
    if category.display then
        category = category.hit
        Stats.CreateStatInfo(
            category,
            category.bonus,
            category.sameLevel,
            category.bossLevel
        )

        category = profile.melee.glance
        Stats.CreateStatInfo(category, category.sameLevel, category.damageSameLevel, category.bossLevel, category.damageBossLevel)

        category = profile.melee.attackSpeed
        Stats.CreateStatInfo(
            category,
            category.mainHand,
            CanDualWield() and category.offHand or nil
        )
    end

    if not UnitHasRelicSlot("player") then
        category = profile.ranged
        Stats.CreateStatInfo(
            category,
            category.attackPower,
            category.crit,
            category.attackSpeed
        )

        if category.display then
            category = category.hit
            Stats.CreateStatInfo(
                category,
                category.bonus,
                category.sameLevel,
                category.bossLevel
            )
        end
    end

    category = profile.defense
    Stats.CreateStatInfo(
        category,
        category.armor,
        category.meleeCritReduction,
        category.rangedCritReduction,
        category.spellCritReduction,
        category.avoidance,
        category.avoidanceBoss,
        category.enemyMissChance,
        category.enemyMissChanceBoss,
        category.defense,
        DataUtils:CanBlock() and category.blockChance or nil,
        DataUtils:CanBlock() and category.blockValue or nil,
        DataUtils:CanParry() and category.parry or nil,
        category.dodge or nil
    )

    if UnitHasMana("player") then
        category = profile.regen
        Stats.CreateStatInfo(category, category.mp5Items, category.mp5Spirit, category.mp5Buffs, category.mp5Casting, category.mp5NotCasting)
    end

    category = profile.spell
    local spellBonus = profile.spellBonus
    local spell = profile.spell
    local spellCrit = spell.crit
    local spellHit = spell.hit
    Stats.CreateStatInfo(
        category,
        spell.hasteBonus,
        spell.penetration,
        spellBonus.baseSpellDmg,
        spellBonus.bonusHealing,
        spell.arcane.display and spellBonus.arcaneDmg or nil,
        spell.arcane.display and spellCrit.display and spellCrit.arcane or nil,
        spell.arcane.display and spellHit.bonus.display and spellHit.arcaneHitBonus or nil,
        spell.arcane.display and spellHit.sameLevel.display and spellHit.arcaneMissChance or nil,
        spell.arcane.display and spellHit.bossLevel.display and spellHit.arcaneMissChanceBoss or nil,
        spell.fire.display and spellBonus.fireDmg or nil,
        spell.fire.display and spellCrit.display and spellCrit.fire or nil,
        spell.fire.display and spellHit.bonus.display and spellHit.fireHitBonus or nil,
        spell.fire.display and spellHit.sameLevel.display and spellHit.fireMissChance or nil,
        spell.fire.display and spellHit.bossLevel.display and spellHit.fireMissChanceBoss or nil,
        spell.frost.display and spellBonus.frostDmg or nil,
        spell.frost.display and spellCrit.display and spellCrit.frost or nil,
        spell.frost.display and spellHit.bonus.display and spellHit.frostHitBonus or nil,
        spell.frost.display and spellHit.sameLevel.display and spellHit.frostMissChance or nil,
        spell.frost.display and spellHit.bossLevel.display and spellHit.frostMissChanceBoss or nil,
        spell.holy.display and spellBonus.holyDmg or nil,
        spell.holy.display and spellCrit.display and spellCrit.holy or nil,
        spell.holy.display and spellHit.bonus.display and spellHit.holyHitBonus or nil,
        spell.holy.display and spellHit.sameLevel.display and spellHit.holyMissChance or nil,
        spell.holy.display and spellHit.bossLevel.display and spellHit.holyMissChanceBoss or nil,
        spell.nature.display and spellBonus.natureDmg or nil,
        spell.nature.display and spellCrit.display and spellCrit.nature or nil,
        spell.nature.display and spellHit.bonus.display and spellHit.natureHitBonus or nil,
        spell.nature.display and spellHit.sameLevel.display and spellHit.natureMissChance or nil,
        spell.nature.display and spellHit.bossLevel.display and spellHit.natureMissChanceBoss or nil,
        spell.physical.display and spellBonus.physicalDmg or nil,
        spell.physical.display and spellCrit.display and spellCrit.physical or nil,
        spell.physical.display and spellHit.bonus.display and spellHit.physicalHitBonus or nil,
        spell.physical.display and spellHit.sameLevel.display and spellHit.physicalMissChance or nil,
        spell.physical.display and spellHit.bossLevel.display and spellHit.physicalMissChanceBoss or nil,
        spell.shadow.display and spellBonus.shadowDmg or nil,
        spell.shadow.display and spellCrit.display and spellCrit.shadow or nil,
        spell.shadow.display and spellHit.bonus.display and spellHit.shadowHitBonus or nil,
        spell.shadow.display and spellHit.sameLevel.display and spellHit.shadowMissChance or nil,
        spell.shadow.display and spellHit.bossLevel.display and spellHit.shadowMissChanceBoss or nil
    )
end

------------------------------------------------------------------
-- Modules
------------------------------------------------------------------

---@class Stats
local Stats = ECSLoader:CreateModule("Stats")
local _Stats = Stats.private
_Stats.displayedLines = {}

---@type Config
local Config = ECSLoader:ImportModule("Config")
---@type Utils
local Utils = ECSLoader:ImportModule("Utils")
---@type Data
local Data = ECSLoader:ImportModule("Data")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")

------------------------------------------------------------------
-- Defaults
------------------------------------------------------------------

-- Font for the header display
local headerFont = "GameFontNormal"

-- Font for the stat display
local statFont = "GameFontHighlightSmall"

-- Forward declaration
local _UpdateStats, _UpdateItem

local colors = Utils.colors
local framePool = {}
local lastYOffset = 20
------------------------------------------------------------------


--- Creates the main frame for the Stats window
function Stats.CreateWindow()
    local ecs = ExtendedCharacterStats

    local mainFrame = CreateFrame("Frame", "ECS_StatsFrame", PaperDollItemsFrame, "BasicFrameTemplateWithInset")
    mainFrame:SetSize(ecs.general.window.width, ecs.general.window.height) -- Width, Height
    mainFrame:SetPoint("LEFT", PaperDollItemsFrame, "RIGHT", ecs.general.window.xOffset, ecs.general.window.yOffset)
    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY")
    mainFrame.title:SetFontObject("GameFontHighlight")
    mainFrame.title:SetPoint("CENTER", mainFrame.TitleBg, "CENTER", 11,  0)
    mainFrame.title:SetText(string.format("ECS %s (SoloCraft)", Utils:GetAddonVersionString()))

    mainFrame.configButton = CreateFrame("Button", nil, mainFrame, "GameMenuButtonTemplate")
    mainFrame.configButton:SetText("Settings")
    mainFrame.configButton:SetSize(ecs.general.window.width - 10, 20)
    mainFrame.configButton:SetPoint("CENTER", mainFrame, "TOP", -1,  -35)
    mainFrame.configButton:SetScript("OnClick", function ()
        ECSConfigFrame:SetShown(not ECSConfigFrame:IsShown())
    end)

    mainFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
    mainFrame.ScrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", -35, -50)
    mainFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -35, 10)

    mainFrame.ScrollChild = CreateFrame("Frame", nil, mainFrame.ScrollFrame)
    mainFrame.ScrollChild:SetSize(ecs.general.window.width, ecs.general.window.height)
    mainFrame.ScrollFrame:SetScrollChild(mainFrame.ScrollChild)
    _Stats.frame = mainFrame

    local toggleButton = CreateFrame("Button", "ECS_ToggleButton", CharacterModelFrame, "GameMenuButtonTemplate")
    toggleButton:SetText("< ECS")
    toggleButton:SetSize(44, 18)
    -- Move to old position if Leatrix Plus durability button is active. See #20
    if (LeaPlusDB and LeaPlusDB["DurabilityStatus"] == "On") or PawnInitialize then
        if OutfitterButton then -- See #89
            toggleButton:SetPoint("TOPRIGHT", PaperDollItemsFrame, "TOPRIGHT", -55, -16)
        else
            toggleButton:SetPoint("TOPRIGHT", PaperDollItemsFrame, "TOPRIGHT", -57, -16)
        end
    else
        toggleButton:SetPoint("BOTTOMRIGHT", PaperDollItemsFrame, "BOTTOMRIGHT", -38, 87)
    end
    toggleButton:SetScript("OnClick", function ()
        Stats:ToggleWindow()
    end)

    mainFrame:SetScript("OnShow", function ()
        toggleButton:SetText("< ECS")
        if OutfitterFrame ~= nil and OutfitterButtonFrame ~= nil then
            OutfitterFrame:SetPoint("TOPLEFT", OutfitterButtonFrame  , "TOPRIGHT", -34 + ExtendedCharacterStats.general.window.width, -38)
        end
        Stats.UpdateInformation()
    end)
    mainFrame:SetScript("OnHide", function ()
        toggleButton:SetText("ECS >")
        if OutfitterFrame ~= nil and OutfitterButtonFrame ~= nil then
            OutfitterFrame:SetPoint("TOPLEFT", OutfitterButtonFrame  , "TOPRIGHT", -34, -38)
        end
    end)

    PaperDollItemsFrame:HookScript("OnShow", function()
        if ExtendedCharacterStats.general.statsWindowClosedOnOpen then
            Stats:HideWindow()
        end
    end)

    if _G.ElvUI then
        local E = _G.ElvUI[1]
        local S = E:GetModule("Skins")
        if S and E.private.skins and E.private.skins.blizzard.enable and E.private.skins.blizzard.character then
            S:HandleFrame(mainFrame)
            if mainFrame.CloseButton then
                mainFrame.CloseButton:SetPoint("TOPRIGHT", 2, 2)
            end
            mainFrame.title:ClearAllPoints()
            mainFrame.title:SetPoint("TOP", mainFrame, "TOP", 0, -8)
            mainFrame.title:SetFont(E.media.normFont, 13)

            S:HandleButton(mainFrame.configButton)
            mainFrame.configButton:SetPoint("CENTER", mainFrame, "TOP", -1, -32)

            S:HandleButton(toggleButton)

            local scrollBar = mainFrame.ScrollFrame.ScrollBar
            if scrollBar then
                S:HandleScrollBar(scrollBar)
            end

            mainFrame.ScrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", -28, -50)
            mainFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -28, 10)
        end
    end

    Stats.CreateStatInfos()
    Config.CreateWindow()
end

function Stats:UpdateWindowSize()
    _Stats.frame:SetSize(ExtendedCharacterStats.general.window.width, ExtendedCharacterStats.general.window.height)
    _Stats.frame.configButton:SetSize(ExtendedCharacterStats.general.window.width- 10, 20)
end

--- Toogles the stats window
function Stats:ToggleWindow()
    local toggleButton = _G["ECS_ToggleButton"]
    if (not toggleButton) then
        error("ECS Toggle Button could not be found")
        return
    end

    _Stats.frame:SetShown(not _Stats.frame:IsShown())
end

function Stats:HideWindow()
    local toggleButton = _G["ECS_ToggleButton"]
    if (not toggleButton) then
        error("ECS Toggle Button could not be found")
        return
    end
    _Stats.frame:SetShown(false)
end

function Stats:ShowWindow()
    _Stats.frame:SetShown(true)
end

function Stats:GetFrame()
    return _Stats.frame
end

---@return table<string, StatsHeader|StatsText>
function Stats:GetDisplayedLines()
    return _Stats.displayedLines
end

--- Helper function to iterate all field of a given category and create them if they should be displayed
---@param category Category|SubCategory
function Stats.CreateStatInfo(category, ...)
    if category.display then
        Stats.CreateHeader(category.refName, category.text, category.isSubGroup)
        local stats = {...}
        -- Loop through all stats
        for _, stat in pairs(stats) do
            if type(stat) == "table" and stat.display then
                Stats.CreateText(stat.refName, Stats.FormatStatsText(stat), category.isSubGroup)
            end
        end
    end
end

---@param stat StatsEntry
function Stats.FormatStatsText(stat)
    local statText = stat.text .. ": "
    local statValue = Data.GetStatInfo(stat.refName)

    if (not ExtendedCharacterStats.general.addColorsToStatTexts) then
        return Utils.Colorize(statText, colors.GRAY) .. Utils.Colorize(statValue, colors.WHITE)
    end

    local textColor = stat.textColor or colors.DEFENSE_SECONDARY
    local statColor = stat.statColor or colors.DEFENSE_PRIMARY

    return Utils.Colorize(statText, textColor) .. Utils.Colorize(statValue, statColor)
end


--- Creates a new header in the stats UI
---@param name string
---@param displayText string
---@param isSubHeader boolean
function Stats.CreateHeader(name, displayText, isSubHeader)
    local xOffSet = 49
    if isSubHeader then
        xOffSet = 56
    end
    lastYOffset = lastYOffset - 20
    ---@class StatsHeader
    local header = table.remove(framePool)
    if not header then
        header = _Stats.frame.ScrollChild:CreateFontString(name, "OVERLAY", headerFont)
    else
        header:SetFontObject(headerFont)
    end
    header:SetPoint("TOPLEFT", xOffSet,  lastYOffset)
    header:SetText(displayText)
    header:SetFont(STANDARD_TEXT_FONT, ExtendedCharacterStats.general.headerFontSize)
    header:Show()
    _Stats.displayedLines[name] = header
end

--- Creates a new value in the stats UI
---@param name string
---@param displayText string
---@param isSubText boolean
function Stats.CreateText(name, displayText, isSubText)
    local xOffSet = 56
    if isSubText then
        xOffSet = 62
    end

    lastYOffset = lastYOffset - 15
    ---@class StatsText
    local stat = table.remove(framePool)
    if not stat then
        stat = _Stats.frame.ScrollChild:CreateFontString(name, "OVERLAY", statFont)
    else
        stat:SetFontObject(statFont)
    end
    stat:SetPoint("TOPLEFT", xOffSet,  lastYOffset)
    stat:SetText(displayText)
    stat:SetFont(STANDARD_TEXT_FONT,  ExtendedCharacterStats.general.statFontSize)
    stat:Show()
    _Stats.displayedLines[name] = stat
end

--- Recycles an existing frame to be reused for the next stat/header
---@param frame StatsHeader|StatsText
function Stats:RecycleFrame(frame)
    frame:Hide()
    table.insert(framePool, frame)
end

--- Resets the Y-Offset and rebuilds the displayed frames
function Stats.RebuildStatInfos()
    local stats = _Stats.displayedLines
    lastYOffset = 20

    for _, entry in pairs(stats) do
        Stats:RecycleFrame(entry)
    end

    _Stats.displayedLines = {}
    Stats.CreateStatInfos()
end

--- Read the loaded profile and update all enabled elements
function Stats.UpdateInformation()

    -- Loop through all categories
    for _, category in pairs(ExtendedCharacterStats.profile) do
        if category and category.display then
            -- Loop through all stats
            _UpdateStats(category)
        end
    end
end

--- Updates all existing stats of a given category
---@param category Category|SubCategory
_UpdateStats = function(category)
    for _, stat in pairs(category) do
        if type(stat) == "table" then
            if stat.isSubGroup then
                for _, subStat in pairs(stat) do
                    if type(subStat) == "table" and subStat.display then
                        _UpdateItem(subStat.refName, Stats.FormatStatsText(subStat))
                    end
                end
            elseif stat.display and stat.refName and stat.text then
                _UpdateItem(stat.refName, Stats.FormatStatsText(stat))
            elseif stat.display then
                _UpdateStats(stat)
            end
        end
    end
end

--- Updates a single existing stat value
---@param refName string
---@param text string
_UpdateItem = function(refName, text)
    local stats = _Stats.displayedLines

    local stat = stats[refName]
    if stat then
        stat:SetText(text)
    end
end

-- Colored frames around the character sheet slots. GetInventoryItemID does not
-- exist here, so the link is the item.

Balf = Balf or {}
Balf.Ecs = Balf.Ecs or {}

local SLOT_NAMES = {
  "CharacterHeadSlot",
  "CharacterNeckSlot",
  "CharacterShoulderSlot",
  "CharacterBackSlot",
  "CharacterChestSlot",
  "CharacterWristSlot",
  "CharacterHandsSlot",
  "CharacterWaistSlot",
  "CharacterLegsSlot",
  "CharacterFeetSlot",
  "CharacterFinger0Slot",
  "CharacterFinger1Slot",
  "CharacterTrinket0Slot",
  "CharacterTrinket1Slot",
  "CharacterMainHandSlot",
  "CharacterSecondaryHandSlot",
  "CharacterRangedSlot",
}

local QUALITY = {
  [0] = { 0.62, 0.62, 0.62 },
  [1] = { 1, 1, 1 },
  [2] = { 0.12, 1, 0 },
  [3] = { 0, 0.44, 0.87 },
  [4] = { 0.64, 0.21, 0.93 },
  [5] = { 1, 0.5, 0 },
}

local function qualityColor(quality)
  if GetItemQualityColor then
    return GetItemQualityColor(quality)
  end
  local color = QUALITY[quality]
  if not color then
    return 1, 1, 1
  end
  return color[1], color[2], color[3]
end

local function slotFrame(name)
  if getglobal then
    return getglobal(name)
  end
end

function Balf.Ecs.updateGearColors()
  local general = Balf.Ecs.general()
  local index = 1
  while index <= table.getn(SLOT_NAMES) do
    local gearFrame = slotFrame(SLOT_NAMES[index])
    if gearFrame then
      if not gearFrame.ecsQuality then
        gearFrame.ecsQuality = gearFrame:CreateTexture(nil, "OVERLAY")
        gearFrame.ecsQuality:SetPoint("TOPLEFT", gearFrame, "TOPLEFT", -2, 2)
        gearFrame.ecsQuality:SetPoint("BOTTOMRIGHT", gearFrame, "BOTTOMRIGHT", 2, -2)
        gearFrame.ecsQuality:SetTexture("Interface\\AddOns\\ExtendedCharacterStats\\Icons\\WhiteIconFrame.blp")
      end
      local link = GetInventoryItemLink and GetInventoryItemLink("player", gearFrame:GetID())
      local quality
      if link and GetItemInfo then
        local _, _, itemQuality = GetItemInfo(link)
        quality = itemQuality
      end
      if general.showQualityColors and quality then
        local r, g, b = qualityColor(quality)
        gearFrame.ecsQuality:SetVertexColor(r, g, b, general.qualityColorsIntensity)
        gearFrame.ecsQuality:Show()
      else
        gearFrame.ecsQuality:Hide()
      end
    end
    index = index + 1
  end
end

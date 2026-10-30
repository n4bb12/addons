---@class Data
local Data = ECSLoader:ImportModule("Data")
---@type DataUtils
local DataUtils = ECSLoader:ImportModule("DataUtils")


---@return string
function Data:GetMovementSpeed()
    local _, runSpeed, _, swimSpeed = GetUnitSpeed("player")

    local currentSpeed

    if IsSwimming() then
        currentSpeed = swimSpeed
    else
        currentSpeed = runSpeed
    end

    currentSpeed = currentSpeed / 7 * 100
    return DataUtils:Round(currentSpeed, 0) .. "%"
end
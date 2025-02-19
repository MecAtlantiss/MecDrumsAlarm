local M = _G["MecDrumsAlarm"]
local API = M.API
local Player = M.Player
local Raiders = M.Raiders
local Rotation = M.Rotation

local function MakePlayerInfoString()
    --"drumType~cooldown~eligibilityStatus"
    return M.Config.drumType .. "~" .. Player:GetDrumCooldown() .. "~" .. Player:GetEligibilityStatus()
end

local function MakeRotationInfoString()
    --"drumType*secondsUntilNextTurn*Mec~Chillerz~Medry~Eb~Troes"
    local queue = Rotation:CalculateDrumQueue()
    if #queue == 0 then return "" end

    local secondsUntilNextTurn = math.max(30 - (GetTime() - M.Rotation.timeOfMostRecentDrumming), 0)
    local msgStr = M.Config.drumType .. "*" .. tostring(secondsUntilNextTurn) .. "*"
    for k, unitName in ipairs(queue) do
        if k > 1 then msgStr = msgStr .. "~" end
        msgStr = msgStr .. unitName
    end
    return msgStr
end

local timeElapsed = -3 --very important this be a negative value to delay how soon the outgoing messages begin. Client needs time to rocognize the player is in a raid group after logging in.
local function HandleUpdate(_, elapsed)
    timeElapsed = timeElapsed + elapsed
    if timeElapsed < 1 then return else timeElapsed = 0 end
    if not API:IsInRaid() then return end
    if Raiders.dataIsEmpty then Raiders:RecordDefaultValues() end
    Raiders:FindMissingRaiders() --needed for when new raiders join the group and the roster update event fails to fire off

    API:SendAddonMessage("MDA_DATA", MakePlayerInfoString(), "RAID")

    if not Player.IsNewToParty then
        API:SendAddonMessage("MDA_ROTATION", MakeRotationInfoString(), "PARTY")
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", HandleUpdate)

local M = _G["MecDrumsAlarm"]
local API = M.API
local Player = M.Player

Player.ResidentPartyNumber = 0
Player.CurrentPartyNumber = 0
Player.TimeOfLastPartyChange = 0
Player.IsNewToParty = false

function Player:IsDead()
    return API:UnitIsDead("player")
end

function Player:GetDrumCooldown()
    return API:GetItemCooldown(M.Config.drumType)
end

function Player:HasDrums()
    return (API:GetItemCount(M.Config.drumType) > 0)
end

function Player:GetEligibilityStatus()
    --returns "Eligible" or "Dead" or "No Drums" or "New to party"
    if Player:IsDead() then return "Dead" end
    if not Player:HasDrums() then return "No Drums" end
    if Player.IsNewToParty then return "New to party" end
    return "Eligible"
end

local function HandleRosterUpdate()
    if not API:IsInRaid() then return end

    --time to determine if the player has changed party
    local updatedPartyNumber = API:GetPlayerPartyNumber()
    if Player.CurrentPartyNumber == updatedPartyNumber then return end --player was not a part of the roster change

    Player.CurrentPartyNumber = updatedPartyNumber
    Player.TimeOfLastPartyChange = GetTime()
    if updatedPartyNumber == Player.ResidentPartyNumber then --player was moved back into their resident group
        Player.IsNewToParty = false
    elseif updatedPartyNumber ~= Player.ResidentPartyNumber then --player was moved out of their resident group (possibly temporarily)
        Player.IsNewToParty = true
    end
end

local timeElapsed = 0
local function HandleUpdate(_, elapsed)
    timeElapsed = timeElapsed + elapsed
    if timeElapsed < 1 then return else timeElapsed = 0 end
    if not API:IsInRaid() then return end

    Player.CurrentPartyNumber = API:GetPlayerPartyNumber()
    if Player.ResidentPartyNumber == 0 then Player.ResidentPartyNumber = API:GetPlayerPartyNumber() end
    if Player.IsNewToParty and (GetTime() - Player.TimeOfLastPartyChange > 10) then
        --player is considered a resident of their new party
        Player.IsNewToParty = false
        Player.ResidentPartyNumber = API:GetPlayerPartyNumber()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent(API.EVENTS.PARTY_MEMBERS_CHANGED)
frame:SetScript("OnEvent", HandleRosterUpdate)
frame:SetScript("OnUpdate", HandleUpdate)

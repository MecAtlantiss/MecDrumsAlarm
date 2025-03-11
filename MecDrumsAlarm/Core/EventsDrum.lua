local M = _G["MecDrumsAlarm"]
local API = M.API

local function HandleCombatEvent(_, event, ...)
    local subevent = API:GetCombatLogEventSubevent(...)
    if subevent ~= "SPELL_CAST_SUCCESS" then return end
    local unitName, drumName = API:GetSpellCastSuccessInfo(...)
    if drumName ~= M.Config.drumType then return end
    if not API:IsUnitInParty(unitName) then return end
    if not API:IsInRaid() then return end
    M.Rotation.timeOfMostRecentDrumming = GetTime()
    M.Raiders.data[unitName].cooldown = 120
    M.Raiders.data[unitName].eligibilityStatus = "Drummed"
    M.DetectPulls.pullActive = true
    M.GUI.MasterFrame:Render()
    M.Rotation.isInFlagToDrumGracePeriod = true
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", HandleCombatEvent)

local M = _G["MecDrumsAlarm"]
local API = M.API
local Rotation = M.Rotation
local MasterFrame = M.GUI.MasterFrame
local DetailedLayout = M.GUI.DetailedLayout
local Alerts = M.GUI.Alerts

MasterFrame.frame = API:CreateBackdropFrame("MDA_MasterFrame", UIParent)
local frame = MasterFrame.frame

local function decideVisibility()
    if (API:IsInRaid() and M.Config.drumType ~= "None" and #M.Rotation.syncedQueue >= 1) or not M.Config.displayLocked then
        DetailedLayout.frame:Show()
        Alerts.frame:Show()
    else
        DetailedLayout.frame:Hide()
        Alerts.frame:Hide()
    end
end

local function decideLayoutMovability()
    if M.Config.displayLocked then
        DetailedLayout.frame:EnableMouse(false)
        DetailedLayout.frame:SetBackdropColor(0, 0, 0, 0)
        DetailedLayout.frame.hint:Hide()
    elseif DetailedLayout.frame:IsVisible() then
        DetailedLayout.frame:SetMovable(true)
        DetailedLayout.frame:EnableMouse(true)
        DetailedLayout.frame:SetBackdropColor(0, 0, 0, 0.3)
        DetailedLayout.frame.hint:Show()
    end
end

local function decideAlertMovability()
    if M.Config.displayLocked then
        Alerts.frame:EnableMouse(false)
        Alerts.frame:SetBackdropColor(0, 0, 0, 0)
        Alerts.frame.hint:Hide()
    elseif Alerts.frame:IsVisible() then
        Alerts.frame:EnableMouse(true)
        Alerts.frame:SetMovable(true)
        Alerts.frame:SetBackdropColor(0, 0, 0, 0.3)
        Alerts.frame.hint:Show()
    end
end

function MasterFrame:Render()
    decideVisibility()
    decideLayoutMovability()
    decideAlertMovability()
    Rotation:GetTimeUntilNextDrum()
    Rotation:CheckIfPlayerDrummingSoon()
    Rotation:RecordIfPlayerInGracePeriod()
    Rotation:RecordIfSomeoneDrummedRecently()
    DetailedLayout:WriteDrummers()

    if M.DetectPulls.pullActive and M.Rotation.isFlaggedToDrumSoon and not Rotation.isInFlagToDrumGracePeriod and M.Rotation.timeUntilNextDrum == 0 and M.Player:GetDrumCooldown() == 0 and not M.Rotation.didSomeoneJustDrum then
        Alerts:PlayAlertSound()
    end
    Alerts:WriteAlertMessage()

    if M.DetectPulls.pullActive and GetTime() > M.DetectPulls.timeOfPullStart then
        M.DetectPulls:CheckIfPullIsOver()
    end
end

local timeElapsed = 0
local function UpdateRender(_, elapsed)
    timeElapsed = timeElapsed + elapsed
    if timeElapsed < 0.25 then return else timeElapsed = 0 end
    MasterFrame:Render()
end

frame:SetScript("OnUpdate", UpdateRender)

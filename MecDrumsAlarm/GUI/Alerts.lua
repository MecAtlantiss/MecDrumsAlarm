local M = _G["MecDrumsAlarm"]
local API = M.API
local Rotation = M.Rotation
local Alerts = M.GUI.Alerts

--==========================================
--Frame definitions
--==========================================
Alerts.frame = API:CreateBackdropFrame("MDA_Messages", M.GUI.MasterFrame.frame)
local frame = Alerts.frame
frame:Hide()
local height = 40
local width = 500

--Size and positioning
frame:SetFrameStrata("MEDIUM")
frame:SetHeight(height)
frame:SetWidth(width)
frame:SetClampedToScreen(true)

--Behavior
frame:SetMovable(false)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

--Background and border
frame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true,
    tileSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
frame:SetBackdropColor(0, 0, 0, 0.3)

--Main text
frame.text = frame:CreateFontString(nil, "ARTWORK")
frame.text:SetFont(M.GUI.FontPath, M.GUI.FontSizes.alertMessage)
frame.text:SetPoint("CENTER", frame)
frame.text:SetTextColor(1, 1, 1, 1)
frame.text:SetShadowColor(0, 0, 0, 1)
frame.text:SetShadowOffset(1, -1)
frame.text:SetText("")

--Hint Text
frame.hint = frame:CreateFontString(nil, "ARTWORK")
frame.hint:SetFont(M.GUI.FontPath, M.GUI.FontSizes.hint)
frame.hint:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, 10)
frame.hint:SetTextColor(1, 1, 1, 1)
frame.hint:SetShadowColor(0, 0, 0, 1)
frame.hint:SetShadowOffset(1, -1)
frame.hint:SetText("Type /mda to lock this frame.")

--==========================================
--Functions
--==========================================
function Alerts:PlayAlertSound()
    if not M.Config.soundEffects then return end
    if M.GUI.Alerts.hasPlayedSoundAlert then return end
    PlaySoundFile(M.GUI.Alerts.SoundAlertPath, "MASTER")
    M.GUI.Alerts.hasPlayedSoundAlert = true
end

function Alerts:WriteAlertMessage()
    Alerts.frame.text:SetText("")
    if not M.Config.onscreenMessages then return end
    if not M.Config.displayLocked then
        Alerts.frame.text:SetText("Mec Drums Alarm Alerts will go here")
    elseif M.DetectPulls.pullActive and M.Rotation.isFlaggedToDrumSoon and not Rotation.isInFlagToDrumGracePeriod and not Rotation.didSomeoneJustDrum then
        if (GetTime() < M.DetectPulls.timeOfPullStart + 5) and (Rotation.timeUntilNextDrum < (M.DetectPulls.timeOfPullStart - GetTime())) then
            --this is the scenario where there's a DBM pull timer going
            Alerts.frame.text:SetText("Pull incoming and you're first to drum")
        elseif Rotation.timeUntilNextDrum == 0 and M.Player:GetDrumCooldown() == 0 then
            Alerts.frame.text:SetText("DRUM NOW!")
        elseif Rotation.timeUntilNextDrum < 5 then
            Alerts.frame.text:SetText("Get ready to drum...")
        end
    end
end

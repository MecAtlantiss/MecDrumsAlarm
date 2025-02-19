local M = _G["MecDrumsAlarm"]

SLASH_MDA1 = "/mda"
SLASH_MDA2 = "/mecdrumsalarm"

function SlashCmdList.MDA(msg)
    if msg == "" then
        if M.GUI.ConfigUI.frame:IsVisible() then M.GUI.ConfigUI.frame:Hide() else M.GUI.ConfigUI.frame:Show() end
    elseif msg == "" then
        
    end
end

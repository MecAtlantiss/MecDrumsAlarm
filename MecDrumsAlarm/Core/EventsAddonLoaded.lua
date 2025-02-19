local M = _G["MecDrumsAlarm"]
local API = M.API
local Raiders = M.Raiders

local function HandleEvents(_, _, addonName)
	if addonName ~= "MecDrumsAlarm" then return end
	M.Config = MDA_CONFIG
	M.GUI.ConfigUI:Make()

	for configKey, configValue in pairs(MDA_CONFIG_DEFAULTS) do
		if M.Config[configKey] == nil then
			M.Config[configKey] = configValue
		end
	end

	local detailedLayoutFrameConfig = M.Config.framePositions["MDA_DetailedLayout"]
	local messagesFrameConfig = M.Config.framePositions["MDA_Messages"]

	MDA_DetailedLayout:SetMovable(true)
	MDA_DetailedLayout:SetPoint(detailedLayoutFrameConfig.point, UIParent, detailedLayoutFrameConfig.relativePoint, detailedLayoutFrameConfig.x, detailedLayoutFrameConfig.y)
	MDA_DetailedLayout:SetMovable(false)

	MDA_Messages:SetMovable(true)
	MDA_Messages:SetPoint(messagesFrameConfig.point, UIParent, messagesFrameConfig.relativePoint, messagesFrameConfig.x, messagesFrameConfig.y)
	MDA_Messages:SetMovable(false)

	if API:IsInRaid() then
		--IMPORTANT: The 2.5.2 client doesn't know you're in a raid until a few moments after the player enters the world, so it won't think you're in a raid at this point.
		Raiders:RecordDefaultValues()
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", HandleEvents)

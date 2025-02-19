local M = _G["MecDrumsAlarm"]

local function HandleEvents()
	--/script local t, _, relativePoint, offsetX, offsetY = MDA_Messages:GetPoint(); print(offsetY);
	local point, _, relativePoint, offsetX, offsetY = MDA_DetailedLayout:GetPoint()
	M.Config.framePositions["MDA_DetailedLayout"].point = point
	M.Config.framePositions["MDA_DetailedLayout"].relativePoint = relativePoint
	M.Config.framePositions["MDA_DetailedLayout"].x = offsetX
	M.Config.framePositions["MDA_DetailedLayout"].y = offsetY

	local point, _, relativePoint, offsetX, offsetY = MDA_Messages:GetPoint()
	M.Config.framePositions["MDA_Messages"].point = point
	M.Config.framePositions["MDA_Messages"].relativePoint = relativePoint
	M.Config.framePositions["MDA_Messages"].x = offsetX
	M.Config.framePositions["MDA_Messages"].y = offsetY
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", HandleEvents)

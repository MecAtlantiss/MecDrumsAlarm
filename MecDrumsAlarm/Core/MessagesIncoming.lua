local M = _G["MecDrumsAlarm"]
local API = M.API
local Raiders = M.Raiders
local Rotation = M.Rotation

local function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

local function ManageIncomingRaiderData(msg, sender)
    --msg: "drumType~cooldown~eligibilityStatus"
    local drumType, cooldown, eligibilityStatus = strsplit("~", msg)
    if M.Raiders.data[sender] == nil then Raiders:RecordClasses() end --sometimes a new raider won't have a key yet. feels like a bug.
    M.Raiders.data[sender].drumType = drumType
    M.Raiders.data[sender].cooldown = tonumber(cooldown)
    M.Raiders.data[sender].eligibilityStatus = eligibilityStatus
    M.Raiders.data[sender].timeOfLastMessage = GetTime()
end

local function ManageIncomingRotationData(msg, sender)
    --msg: "secondsUntilNextTurn*Mec~Chillerz~Medry~Eb~Troes"
    if msg == "" then return end

    local drumType, secondsUntilNextTurn, queueStr = strsplit("*", msg)
    if drumType ~= M.Config.drumType then return end
    local queue = split(queueStr, "~")
    Rotation:UpdateRecentSuggestionsAndSyncs(sender, tonumber(secondsUntilNextTurn), queue, queueStr)
end

local function HandleIncomingMessage(_, event, prefix, msg, channel, senderLong)
    if prefix ~= "MDA_DATA" and prefix ~= "MDA_ROTATION" then return end
    if not API:IsInRaid() then return end
    M.Raiders:FindMissingRaiders() --needed for when new raiders join the group and the roster update event fails to fire off

    local sender = strsplit("-", senderLong) --TBCC messages have server name
    if prefix == "MDA_DATA" then
        ManageIncomingRaiderData(msg, sender)
    end

    if prefix == "MDA_ROTATION" then
        ManageIncomingRotationData(msg, sender)
    end

    if prefix == "MDA_VERSION" then
        --TODO: SendAddonMessage through whisper channel to sender.
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", HandleIncomingMessage)

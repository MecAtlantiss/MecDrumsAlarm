local M = _G["MecDrumsAlarm"]
local API = M.API
local Raiders = M.Raiders
local data = M.Raiders.data

Raiders.dataIsEmpty = true --the 2.5.2 client is buggy on loading into the world, which is why this is here

function Raiders:RecordClasses()
    for i = 1, API:GetNumGroupMembers() do
        local name, _, _, _, _, class = GetRaidRosterInfo(i)

        if name then
            if data[name] == nil then data[name] = {} end
            data[name].class = class
        end
    end
end

function Raiders:RecordDefaultValues()
    for i = 1, API:GetNumGroupMembers() do
        local name, _, _, _, _, class = GetRaidRosterInfo(i)

        if name then
            if data[name] == nil then data[name] = {} end
            data[name].drumType = "Unknown"
            data[name].eligibilityStatus = "Unknown"
            data[name].cooldown = 999
            data[name].class = class
            data[name].timeOfLastMessage = 0
        end
    end

    Raiders.dataIsEmpty = false
end

function Raiders:FindMissingRaiders()
    for i = 1, API:GetNumGroupMembers() do
        local name, _, _, _, _, class = GetRaidRosterInfo(i)

        if name then
            if data[name] == nil then
                data[name] = {}
            end
            Raiders:RecordClasses()
        end
    end

    Raiders.dataIsEmpty = false
end

function Raiders:CheckAndRecordDisconnectedRaiders()
    for i = 1, API:GetNumGroupMembers() do
        local name = GetRaidRosterInfo(i)

        if name and data[name] ~= nil and data[name].eligibilityStatus ~= nil then
            if GetTime() - data[name].timeOfLastMessage > 5 then
                data[name].eligibilityStatus = "No response"
            end
        end
    end
end

local function HandleRosterUpdate()
    if not API:IsInRaid() then return end
    Raiders:RecordClasses()
end

local timeElapsed = 0
local function HandleUpdate(_, elapsed)
    timeElapsed = timeElapsed + elapsed
    if timeElapsed < 1 then return else timeElapsed = 0 end
    if not API:IsInRaid() then return end
    Raiders:CheckAndRecordDisconnectedRaiders()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent(API.EVENTS.RAID_MEMBERS_CHANGED)
frame:SetScript("OnEvent", HandleRosterUpdate)
frame:SetScript("OnUpdate", HandleUpdate)

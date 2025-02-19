local M = _G["MecDrumsAlarm"]
local API = M.API
local Raiders = M.Raiders
local Rotation = M.Rotation

local rdata = Raiders.data
local recentSuggestions = M.Rotation.recentSuggestions

CLASS_ROTATION_PRIORITIES = {
    ["DRUID"] = 1,
    ["SHAMAN"] = 2,
    ["PRIEST"] = 3,
    ["PALADIN"] = 4,
    ["MAGE"] = 5,
    ["ROGUE"] = 6,
    ["WARRIOR"] = 7,
    ["HUNTER"] = 8,
    ["WARLOCK"] = 9,
    ["Unknown"] = 10
}

local function SortByClassAndName(partyMembers)
    table.sort(partyMembers, function(a, b)
        if rdata[a] == nil or rdata[b] == nil then Raiders:FindMissingRaiders() end
        local class_priority_a = CLASS_ROTATION_PRIORITIES[rdata[a].class]
        local class_priority_b = CLASS_ROTATION_PRIORITIES[rdata[b].class]
        if class_priority_a == class_priority_b then
            return a < b
        else
            return class_priority_a > class_priority_b
        end
    end)
    return partyMembers
end

function Rotation:CalculateDrumQueue()
    --this will calculate and return the queue of drummers according to the state of data currently in the player's client.
    --queue is calculated to be eligible people from lowest to highest cooldown and then ineligibles after them. in the event of a tie, it's sorted by class priority and then alphabetically
    local queue = {}

    local placed = false
    for _, unitName in ipairs(SortByClassAndName(API:GetPartyMembers())) do
        placed = false
        if rdata[unitName].drumType == M.Config.drumType then
            if #queue == 0 or rdata[unitName].eligibilityStatus ~= "Eligible" then
                table.insert(queue, unitName)
                placed = true
            else
                --loop through the current state of the queue until we find the appropriate spot for unitName
                for j, queuedAlly in ipairs(queue) do
                    if (rdata[queuedAlly].eligibilityStatus ~= "Eligible") or (rdata[unitName].cooldown <= rdata[queuedAlly].cooldown) then
                        table.insert(queue, j, unitName)
                        placed = true
                        break
                    end
                end
            end
            --if they haven't been placed yet, then it means everyone is eligible and this person has the longest cooldown so place them last.
            if not placed then table.insert(queue, unitName) end
        end
    end

    return queue
end

local function InsertIntoRecentSuggestions(sender, secondsUntilNextTurn, queue, queueStr)
    if recentSuggestions[sender] == nil then recentSuggestions[sender] = {} end
    recentSuggestions[sender].secondsUntilNextTurn = secondsUntilNextTurn
    recentSuggestions[sender].queue = queue
    recentSuggestions[sender].queueStr = queueStr
    recentSuggestions[sender].timeReceived = GetTime()
end

local function DeleteOldRecentSuggestions(maxAgeInSeconds)
    for sender, values in pairs(recentSuggestions) do
        if GetTime() - values.timeReceived > maxAgeInSeconds then
            recentSuggestions[sender].secondsUntilNextTurn = nil
            recentSuggestions[sender].queue = nil
            recentSuggestions[sender].queueStr = nil
            recentSuggestions[sender].timeReceived = nil
            recentSuggestions[sender] = nil -- Remove the entry from the table
        end
    end
end

local function FindMostPopularQueue()
    --step 1: tally up the queueStr's
    local queuePopularity = {}
    local highestCount = 1
    for _, v in pairs(recentSuggestions) do
        if queuePopularity[v.queueStr] == nil then
            queuePopularity[v.queueStr] = { count = 1, queue = v.queue }
        else
            queuePopularity[v.queueStr].count = queuePopularity[v.queueStr].count + 1
            if queuePopularity[v.queueStr].count > highestCount then
                highestCount = queuePopularity[v.queueStr].count
            end
        end
    end

    --step 2: find the queue(s) with the highest tally
    local queuesWithHighestCount = {}
    for k, v in pairs(queuePopularity) do
        if v.count == highestCount then
            table.insert(queuesWithHighestCount, v.queue)
        end
    end
    queuePopularity = nil

    --step 3: return the last queue with the highest tally
    return queuesWithHighestCount[#queuesWithHighestCount]
end

local function FindMostPopularSecondsUntilNextTurn()
    --step 1: tally up the secondsUntilNextTurn
    local t = {}
    for _, v in pairs(recentSuggestions) do
        table.insert(t, v.secondsUntilNextTurn)
    end
    table.sort(t)

    local p = {}
    local currVal = t[1]
    local currCnt = 0
    local highestCount = 0
    for i = 1, #t do
        if math.abs(t[i] - currVal) < 2 then
            currCnt = currCnt + 1
            if currCnt > highestCount then highestCount = currCnt end
        else
            p[currVal] = currCnt
            currCnt = 1
            currVal = t[i]
        end
        if i == #t then p[currVal] = currCnt end
    end

    --step 2: find the queue(s) with the highest tally
    local secWithHighestCount = {}
    for sec, count in pairs(p) do
        if count == highestCount then
            table.insert(secWithHighestCount, sec)
        end
    end
    p = nil

    --step 3: return the last secondsUntilTurn with the highest tally
    return secWithHighestCount[#secWithHighestCount]
end

function Rotation:UpdateRecentSuggestionsAndSyncs(sender, secondsUntilNextTurn, queue, queueStr)
    InsertIntoRecentSuggestions(sender, secondsUntilNextTurn, queue, queueStr)
    DeleteOldRecentSuggestions(1.5)
    Rotation.syncedQueue = FindMostPopularQueue()
    Rotation.syncedSecondsUntilNextTurn = FindMostPopularSecondsUntilNextTurn()
end

function Rotation:GetTimeUntilNextDrum()
    --The current "turn" always lasts 30 seconds or less, which corresponds with the length of the drum buff.
    --The turn will be 30 seconds if someone else drums early.
    --The "time until next drum" is defined to be the maximum of the syncedSecondsUntilNextTurn and the lowest drum cooldown among "Eligible" players in syncedQueue.
    if #M.Rotation.syncedQueue < 1 then return end
    if rdata[Rotation.syncedQueue[1]].eligibilityStatus ~= "Eligible" then
        M.Rotation.timeUntilNextDrum = M.Rotation.syncedSecondsUntilNextTurn
    elseif #Rotation.syncedQueue >= 1 then
        local lowestCD = 120
        for i, player in ipairs(Rotation.syncedQueue) do
            if rdata[player].eligibilityStatus == "Eligible" and rdata[player].cooldown < lowestCD then
                lowestCD = rdata[player].cooldown
            end
        end
        M.Rotation.timeUntilNextDrum = math.max(Rotation.syncedSecondsUntilNextTurn, lowestCD)
    end
end

function Rotation:CheckIfPlayerDrummingSoon()
    if #M.Rotation.syncedQueue < 1 then return end
    local nextDrummerName = Rotation.syncedQueue[1]
    if rdata[nextDrummerName].eligibilityStatus == "Eligible" and nextDrummerName == M.Player.Name and M.Rotation.timeUntilNextDrum < 5 then
        if not M.Rotation.isFlaggedToDrumSoon then
            M.Rotation.isFlaggedToDrumSoon = true
            M.Rotation.timeWhenFlaggedToDrumSoon = GetTime()
            M.GUI.Alerts.hasPlayedSoundAlert = false
        end
    else
        M.Rotation.isFlaggedToDrumSoon = false
    end
end

function Rotation:RecordIfPlayerInGracePeriod()
    M.Rotation.isInFlagToDrumGracePeriod = (GetTime() - M.Rotation.timeWhenFlaggedToDrumSoon <= 2)
end

function Rotation:RecordIfSomeoneDrummedRecently()
    if GetTime() - M.Rotation.timeOfMostRecentDrumming < 2 then
        M.Rotation.didSomeoneJustDrum = true
    else
        M.Rotation.didSomeoneJustDrum = false
    end
end

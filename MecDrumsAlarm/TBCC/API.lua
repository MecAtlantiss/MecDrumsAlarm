local M = _G["MecDrumsAlarm"]
local API = M.API

API.EVENTS = {
    PARTY_MEMBERS_CHANGED = "GROUP_ROSTER_UPDATE",
    RAID_MEMBERS_CHANGED = "GROUP_ROSTER_UPDATE"
}

function API:SendAddonMessage(prefix, msg, channel)
    C_ChatInfo.SendAddonMessage(prefix, msg, channel)
end

function API:IsInRaid()
    --returns true or false
    return IsInRaid()
end

function API:GetNumGroupMembers()
    --returns an integer
    return GetNumGroupMembers()
end

function API:UnitIsDead(unit)
    --returns true or false
    return UnitIsDead(unit)
end

function API:UnitAffectingCombat(unitName)
    --returns true or false
    return UnitAffectingCombat(unitName)
end

function API:GetItemCooldown(itemName)
    --returns a float
    local _, itemLink = GetItemInfo(itemName)
    if itemLink == nil then return 0 end
    local itemID = tonumber(strmatch(itemLink, "Hitem:(%d+)"))
    local startTime, duration = GetItemCooldown(itemID)
    if duration <= 1.6 then return 0 end --gcd counts as an item being on cooldown...
    local cooldown = duration - (GetTime() - startTime)
    return cooldown
end

function API:GetItemCount(itemName)
    --returns an integer
    local _, itemLink = GetItemInfo(itemName)
    if itemLink == nil then return 0 end
    local itemID = tonumber(strmatch(itemLink, "Hitem:(%d+)"))
    return GetItemCount(itemID)
end

function API:GetPlayerPartyNumber()
    --returns an integer
    local _, _, partyNumber = GetRaidRosterInfo(UnitInRaid("player"))
    return partyNumber
end

function API:GetPartyMembers()
    --returns a table of party member names
    local partyMembers = {}
    table.insert(partyMembers, M.Player.Name) --player is excluded from GetNumPartyMembers, so we force the player in
    for i = 1, GetNumSubgroupMembers() do
        local unit = "party" .. i
        local name = UnitName(unit)
        if name then
            table.insert(partyMembers, name)
        end
    end
    return partyMembers
end

function API:IsUnitInParty(unitName)
    -- Check if the unit is in your party by iterating over all party members
    if GetNumGroupMembers() == 0 then return false end --player isn't in a party
    if unitName == M.Player.Name then return true end
    for i = 1, GetNumSubgroupMembers() do
        local name = UnitName("party"..i)
        if name == unitName then
            return true
        end
    end
    return false
end

function API:GetCombatLogEventSubevent()
    local _, subevent = CombatLogGetCurrentEventInfo()
    return subevent
end

function API:GetSpellCastSuccessInfo(...)
    local _, _, _, _, unitName, _, _, _, destName, _, _, _, itemName = CombatLogGetCurrentEventInfo()
    return unitName, itemName, destName
end

function API:CreateBackdropFrame(name, parentFrame)
    return CreateFrame("Frame", name, parentFrame, "BackdropTemplate")
end

local M = _G["MecDrumsAlarm"]
local API = M.API

API.EVENTS = {
    PARTY_MEMBERS_CHANGED = "PARTY_MEMBERS_CHANGED",
    RAID_MEMBERS_CHANGED = "RAID_ROSTER_UPDATE"
}

function API:SendAddonMessage(prefix, msg, channel)
    SendAddonMessage(prefix, msg, channel)
end

function API:IsInRaid()
    --returns true or false
    if UnitInRaid("player") == nil then return false else return true end
end

function API:GetNumGroupMembers()
    if API:IsInRaid() then
        return GetNumRaidMembers()
    else
        return GetNumPartyMembers() + 1 --in TBC, GetNumPartyMembers() excludes the player
    end
end

function API:UnitIsDead(unit)
    --returns true or false
    if UnitIsDead(unit) == 1 then return true else return false end
end

function API:UnitAffectingCombat(unitName)
    --returns true or false
    if UnitAffectingCombat(unitName) == 1 then return true else return false end
end

function API:GetItemCooldown(itemName)
    --returns a float
    local itemLink = select(2, GetItemInfo(itemName))
    if itemLink == nil then return 0 end
    local startTime, duration = GetItemCooldown(itemLink)
    if duration <= 1.6 then return 0 end --gcd counts as an item being on cooldown...
    local cooldown = duration - (GetTime() - startTime)
    return cooldown
end

function API:GetItemCount(itemName)
    --returns an integer
    local itemLink = select(2, GetItemInfo(itemName))
    if itemLink == nil then return 0 end
    return GetItemCount(itemLink)
end

function API:GetPlayerPartyNumber()
    --returns an integer
    local _, _, partyNumber = GetRaidRosterInfo(UnitInRaid("player") + 1)
    return partyNumber
end

function API:GetPartyMembers()
    --returns a table of party member names
    local partyMembers = {}
    table.insert(partyMembers, M.Player.Name) --player is excluded from GetNumPartyMembers, so we force the player in
    for i = 1, GetNumPartyMembers() do
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
    if unitName == M.Player.Name then return true end
    for i = 1, GetNumPartyMembers() do
        local name = UnitName("party"..i)
        if name == unitName then
            return true
        end
    end
    return false
end

function API:GetCombatLogEventSubevent(...)
    local _, subevent = ...
    return subevent
end

function API:GetSpellCastSuccessInfo(...)
    local _, _, _, unitName, _, _, destName, _, _, itemName = ...
    return unitName, itemName, destName
end

function API:CreateBackdropFrame(name, parentFrame)
    return CreateFrame("Frame", name, parentFrame)
end

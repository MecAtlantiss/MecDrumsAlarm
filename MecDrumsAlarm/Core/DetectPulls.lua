local M = _G["MecDrumsAlarm"]
local API = M.API
local DetectPulls = M.DetectPulls

local BOSSES = {
    ["Doom Lord Kazzak"] = 1,
    ["Doomwalker"] = 1,
    ["Attumen the Huntsman"] = 1,
    ["Midnight"] = 1,
    ["Mores"] = 1,
    ["Maiden of Virtue"] = 1,
    ["Dorothee"] = 1,
    ["The Crone"] = 1,
    ["The Big Bad Wolf"] = 1,
    ["Romulo"] = 1,
    ["Julianne"] = 1,
    ["The Curator"] = 1,
    ["Terestian Illhoof"] = 1,
    ["Shade of Aran"] = 1,
    ["Netherspite"] = 1,
    ["Prince Malchezaar"] = 1,
    ["Nightbane"] = 1,
    ["Kiggler the Crazed"] = 1,
    ["Blindeye the Seer"] = 1,
    ["Olm the Summoner"] = 1,
    ["Krosh Firehand"] = 1,
    ["High King Maulgar"] = 1,
    ["Gruul the Dragonkiller"] = 1,
    ["Magtheridon"] = 1,
    ["Hydross the Unstable"] = 1,
    ["The Lurker Below"] = 1,
    ["Leotheras the Blind"] = 1,
    ["Fathom-Lord Karathress"] = 1,
    ["Morogrim Tidewalker"] = 1,
    ["Lady Vashj"] = 1,
    ["Al'ar"] = 1,
    ["Void Reaver"] = 1,
    ["High Astromancer Solarian"] = 1,
    ["Kael'thas Sunstrider"] = 1,
    ["Thaladred the Darkener"] = 1,
    ["Master Engineer Telonicus"] = 1,
    ["Grand Astromancer Capernian"] = 1,
    ["Lord Sanguinar"] = 1,
    ["Akil'zon"] = 1,
    ["Nalorakk"] = 1,
    ["Jan'alai"] = 1,
    ["Halazzi"] = 1,
    ["Hex Lord Malacrass"] = 1,
    ["Zul'jin"] = 1,
    ["Rage Winterchill"] = 1,
    ["Anetheron"] = 1,
    ["Kaz'rogal"] = 1,
    ["Azgalor"] = 1,
    ["Archimonde"] = 1,
    ["High Warlord Naj'entus"] = 1,
    ["Supremus"] = 1,
    ["Ashtongue Channeler"] = 1,
    ["Shade of Akama"] = 1,
    ["Teron Gorefiend"] = 1,
    ["Gurtogg Bloodboil"] = 1,
    ["Essence of Suffering"] = 1,
    ["Essence of Desire"] = 1,
    ["Essence of Anger"] = 1,
    ["Mother Shahraz"] = 1,
    ["Gathios the Shatterer"] = 1,
    ["High Nethermancer Zerevor"] = 1,
    ["Lady Malande"] = 1,
    ["Veras Darkshadow"] = 1,
    ["Illidan Stormrage"] = 1,
    ["Kalecgos"] = 1,
    ["Sathrovarr the Corruptor"] = 1,
    ["Brutallus"] = 1,
    ["Felmyst"] = 1,
    ["Grand Warlock Alythess"] = 1,
    ["Lady Sacrolash"] = 1,
    ["M'uru"] = 1,
    ["Entropius"] = 1,
    ["Kil'jaeden"] = 1,
}

local PULL_SPELLS = {
    ["Arcane Shot"] = 1,
    ["Auto Shot"] = 1,
    ["Distracting Shot"] = 1,
    ["Shield Slam"] = 1,
    ["Devastate"] = 1,
    ["Taunt"] = 1,
    ["Growl"] = 1,
    ["Mangle (Bear)"] = 1,
    ["Arcane Blast"] = 1,
    ["Curse of Elements"] = 1,
    ["Curse of Weakness"] = 1,
    ["Curse of Recklessness"] = 1,
    ["Shadow Word: Pain"] = 1,
    ["Faerie Fire"] = 1,
    ["Insect Swarm"] = 1,
    ["Scorpid Sting"] = 1,
    ["Vampiric Embrace"] = 1,
}

function DetectPulls:CheckIfPullIsOver()
    if not API:IsInRaid() then
        M.DetectPulls.pullActive = false
        return
    end

    if M.DetectPulls.pullActive then
        if GetTime() < M.DetectPulls.timeOfPullStart + 15 then return end --there's been a DBM pull timer recently, so we don't want to turn off the pull even if people are out of combat

        for _, unitName in ipairs(API:GetPartyMembers()) do
            if API:UnitAffectingCombat(unitName) then
                M.DetectPulls.isPartyInCombat = true
                return
            end
        end
        --no party member is in combat, so...
        if M.DetectPulls.isPartyInCombat then
            M.DetectPulls.timeWhenPartyLeftCombat = GetTime()
            M.DetectPulls.isPartyInCombat = false
        elseif (GetTime() - M.DetectPulls.timeWhenPartyLeftCombat) > 10 then
            M.DetectPulls.pullActive = false
        end
    end
end

local function HandleIncomingMessage(_, _, prefix, msg)
    if prefix == "D4BC" then
        --2.5.2 scenario
        if not API:IsInRaid() then return end
        local dbmprefix, timer = strsplit("\t", msg)
        if dbmprefix ~= "PT" then return end
        M.DetectPulls.timeOfPullStart = GetTime() + tonumber(timer)
        M.DetectPulls.pullActive = true
    elseif prefix == "PT" then
        --2.4.3 scenario
        if not API:IsInRaid() then return end
        local timer = strsplit("\t", msg)
        M.DetectPulls.timeOfPullStart = GetTime() + tonumber(timer)
        M.DetectPulls.pullActive = true
    end
end
local msgs_frame = CreateFrame("Frame")
msgs_frame:RegisterEvent("CHAT_MSG_ADDON")
msgs_frame:SetScript("OnEvent", HandleIncomingMessage)


local function HandleCLEU(_, event, ...)
    local subevent = API:GetCombatLogEventSubevent(...)
    if subevent ~= "SPELL_CAST_SUCCESS" then return end
    local _, spellName, destName = API:GetSpellCastSuccessInfo(...)
    if PULL_SPELLS[spellName] == nil then return end
    if BOSSES[destName] == nil then return end
    M.DetectPulls.pullActive = true
end
local CLEU_frame = CreateFrame("Frame")
CLEU_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
CLEU_frame:SetScript("OnEvent", HandleCLEU)

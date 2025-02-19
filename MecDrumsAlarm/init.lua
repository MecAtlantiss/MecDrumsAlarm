local M = {}
_G["MecDrumsAlarm"] = M

M.version = "1.0"

M.API = {}
M.Player = {}
M.Player.Name = UnitName("player")
M.Raiders = {}
M.Raiders.data = {}
M.Rotation = {}
M.Rotation.timeOfMostRecentDrumming = 0
M.Rotation.recentSuggestions = {}
M.Rotation.syncedSecondsUntilNextTurn = 0
M.Rotation.syncedQueue = {}
M.Rotation.timeUntilNextDrum = 0
M.Rotation.isFlaggedToDrumSoon = false
M.Rotation.timeWhenFlaggedToDrumSoon = 0
M.Rotation.isInFlagToDrumGracePeriod = false
M.Rotation.didSomeoneJustDrum = false
M.DetectPulls = {}
M.DetectPulls.timeOfPullStart = 0
M.DetectPulls.pullActive = false
M.DetectPulls.isPartyInCombat = false
M.DetectPulls.timeWhenPartyLeftCombat = 0

M.GUI = {}
M.GUI.MasterFrame = {}
M.GUI.DetailedLayout = {}
M.GUI.Alerts = {}
M.GUI.Alerts.hasPlayedSoundAlert = false
M.GUI.Alerts.SoundAlertPath = "Interface\\AddOns\\MecDrumsAlarm\\Media\\sound_alert.ogg"
M.GUI.ConfigUI = {}
M.GUI.FontPath = "Interface\\AddOns\\MecDrumsAlarm\\Media\\nunito.ttf"
M.GUI.FontSizes = {
    configTitle = 16,
    configOption = 14,
    rotationRow = 10,
    hint = 10,
    alertMessage = 25,
}

--these are only for config items that will appear in ConfigUI. for example, framePositions won't be in this.
--M.GUI.orderedConfigNames = { "displayLocked", "drumType", "drumRange", "onscreenMessages", "missMessages", "glowingFrames", "soundEffects" }
M.GUI.orderedConfigNames = { "displayLocked", "drumType", "onscreenMessages", "soundEffects" }

M.GUI.configUIData = {
    displayLocked = {
        label = "Frame Position",
        options = {
            { label = "Locked",   value = true },
            { label = "Unlocked", value = false }
        }
    },
    drumType = {
        label = "Drum",
        options = {
            { label = "Battle",      value = "Drums of Battle" },
            { label = "Restoration", value = "Drums of Restoration" },
            { label = "War",         value = "Drums of War" },
            { label = "None",        value = "None" },
        }
    },
    drumRange = {
        label = "Drum range",
        options = {
            { label = "8yd",  value = 8 },
            { label = "40yd", value = 40 },
        }
    },
    onscreenMessages = {
        label = "On-screen messages",
        options = {
            { label = "On",  value = true },
            { label = "Off", value = false },
        }
    },
    missMessages = {
        label = "Report whiffs in chat",
        options = {
            { label = "On",  value = true },
            { label = "Off", value = false },
        }
    },
    glowingFrames = {
        label = "Glow allies in range",
        options = {
            { label = "On",  value = true },
            { label = "Off", value = false },
        }
    },
    soundEffects = {
        label = "Sound alerts",
        options = {
            { label = "On",  value = true },
            { label = "Off", value = false },
        }
    },
}

--This is the initial state of this addon's SavedVariable.
--These values will be overwritten by the player's persistent state when the ADDON_LOADED event fires.
MDA_CONFIG_DEFAULTS = {
    displayLocked = false,
    drumType = "Drums of Battle",
    --drumRange = 40,
    onscreenMessages = true,
    --missMessages = true,
    --glowingFrames = false,
    soundEffects = true,
    framePositions = {
        ["MDA_DetailedLayout"] = {point = "LEFT", relativePoint = "LEFT", x = 206, y = -67},
        ["MDA_Messages"] = {point = "CENTER", relativePoint = "CENTER", x = 0, y = 134}
    }
}
MDA_CONFIG = MDA_CONFIG_DEFAULTS
M.Config = MDA_CONFIG

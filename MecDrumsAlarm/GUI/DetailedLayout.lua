local M = _G["MecDrumsAlarm"]
local API = M.API
local Rotation = M.Rotation
local Raiders = M.Raiders
local DetailedLayout = M.GUI.DetailedLayout

--==========================================
--Frame definitions
--==========================================
DetailedLayout.frame = API:CreateBackdropFrame("MDA_DetailedLayout", UIParent)
local frame = DetailedLayout.frame
frame:Hide()
local rowHeight = 11
local rowPadding = 2
local horizontalRuleHeight = 2
local rowCount = 6 --5 player rows and 1 row dedicated to the "turn" info
local height = rowCount * (rowHeight + rowPadding) + horizontalRuleHeight * 2
local width = 180
local colWidths = { 0.6 * width, 0.4 * width }

--Size and positioning
frame:SetFrameStrata("MEDIUM")
frame:SetHeight(height)
frame:SetWidth(width)
frame:SetClampedToScreen(true)

--Behavior
frame:SetMovable(false)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

--Background and border
frame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true,
    tileSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
frame:SetBackdropColor(0, 0, 0, 0.3)

--Hint Text
frame.hint = frame:CreateFontString(nil, "ARTWORK")
frame.hint:SetFont(M.GUI.FontPath, M.GUI.FontSizes.hint)
frame.hint:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, 10)
frame.hint:SetTextColor(1,1,1,1)
frame.hint:SetShadowColor(0, 0, 0, 1)
frame.hint:SetShadowOffset(1, -1)
frame.hint:SetText("Type /mda to lock this frame.")

local function CreateCell(x, y, width, justify)
    local cellFrame = frame:CreateFontString(nil, "ARTWORK")
    cellFrame:SetFont(M.GUI.FontPath, M.GUI.FontSizes.rotationRow)
    cellFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
    cellFrame:SetWidth(width)
    cellFrame:SetHeight(rowHeight)
    cellFrame:SetJustifyH(justify)
    cellFrame:SetTextColor(1, 1, 1, 1)
    cellFrame:SetShadowColor(0, 0, 0, 1)
    cellFrame:SetShadowOffset(1, -1)
    cellFrame:SetPoint("TOP", 0, -2)
    cellFrame:SetText("")

    return cellFrame
end

local function CreateRow(currRow, colWidths)
    local row = {}
    local y = -height + ((currRow) * (rowHeight + rowPadding))
    if currRow > 1 then y = y + horizontalRuleHeight * 2 end

    row.col1frame = CreateCell(0, y, colWidths[1] - 5, "RIGHT")
    row.col2frame = CreateCell(colWidths[1], y, colWidths[2], "LEFT")
    return row
end

local function CreateHorizontalRule(x, y, width)
    local horizontalRule = frame:CreateTexture()
    horizontalRule = frame:CreateTexture()
    horizontalRule:SetTexture("Interface\\BUTTONS\\WHITE8x8")
    horizontalRule:SetHeight(horizontalRuleHeight)
    horizontalRule:SetWidth(width)
    horizontalRule:SetPoint("BOTTOMLEFT", frame, x, y)
end

local detailedLayoutRows = {}
for currRow = 1, rowCount do
    table.insert(detailedLayoutRows, CreateRow(currRow, colWidths))
end

CreateHorizontalRule(colWidths[1] - 75, 0, 75 + 35)
CreateHorizontalRule(colWidths[1] - 75, rowHeight + rowPadding + horizontalRuleHeight, 75 + 35)

--==========================================
--Functions
--==========================================
function DetailedLayout:ColorRow(row, situation)
    if situation == "ineligible" then
        row.col1frame:SetTextColor(0.75, 0.75, 0.75, 1)
        row.col2frame:SetTextColor(0.75, 0.75, 0.75, 1)
    elseif situation == "player" then
        row.col1frame:SetTextColor(1, 0.65, 0, 1)
        row.col2frame:SetTextColor(1, 0.65, 0, 1)
    end
end

function DetailedLayout:WriteDrummers()
    if #M.Rotation.syncedQueue < 1 then return end

    for _, row in ipairs(detailedLayoutRows) do
        row.col1frame:SetText("")
        row.col2frame:SetText("")
        row.col1frame:SetTextColor(1, 1, 1, 1)
        row.col2frame:SetTextColor(1, 1, 1, 1)
    end

    local currQueueId = 1
    if M.Rotation.timeUntilNextDrum == 0 and M.Raiders.data[Rotation.syncedQueue[1]].eligibilityStatus == "Eligible" then
        detailedLayoutRows[1].col1frame:SetText(Rotation.syncedQueue[1])
        detailedLayoutRows[1].col2frame:SetText("DRUM!")
        if Rotation.syncedQueue[1] == M.Player.Name then DetailedLayout:ColorRow(detailedLayoutRows[1], "player") end
        currQueueId = 2
    else
        detailedLayoutRows[1].col1frame:SetText("Next drum in")
        detailedLayoutRows[1].col2frame:SetText(math.ceil(M.Rotation.timeUntilNextDrum) .. "s")
    end

    local j = 2
    for i, unitName in ipairs(Rotation.syncedQueue) do
        if i >= currQueueId then
            local row = detailedLayoutRows[j]
            row.col1frame:SetText(unitName)
            if M.Raiders.data[unitName].eligibilityStatus == "Eligible" then
                if Raiders.data[unitName].cooldown ~= 0 then
                    row.col2frame:SetText(math.ceil(Raiders.data[unitName].cooldown) .. "s")
                else
                    row.col2frame:SetText("READY")
                end
            else
                row.col2frame:SetText(Raiders.data[unitName].eligibilityStatus)
                DetailedLayout:ColorRow(row, "ineligible")
            end
            if unitName == M.Player.Name then DetailedLayout:ColorRow(row, "player") end
            j = j + 1
        end
    end
end

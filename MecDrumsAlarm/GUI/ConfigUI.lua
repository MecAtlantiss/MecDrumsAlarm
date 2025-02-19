local M = _G["MecDrumsAlarm"]
local API = M.API
local ConfigUI = M.GUI.ConfigUI

function ConfigUI:Make()
    M.GUI.ConfigUI.frame = API:CreateBackdropFrame("MDA_ConfigUI", UIParent)
    local frame = M.GUI.ConfigUI.frame

    local rowHeight = 20
    local rowPadding = 8
    local height = 60 + #M.GUI.orderedConfigNames * (rowHeight + rowPadding)
    local colWidths = { 165, 75, 86, 65, 50 }
    local width = 10
    for _, colWidth in ipairs(colWidths) do
        width = width + colWidth
    end

    --Size and positioning
    frame:SetFrameStrata("HIGH")
    frame:SetHeight(height)
    frame:SetWidth(width)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetClampedToScreen(true)

    --Behavior
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    --Background and border
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetBackdropBorderColor(1, 1, 1)

    --Title Text
    frame.title = frame:CreateFontString(nil, "ARTWORK")
    frame.title:SetFont(M.GUI.FontPath, M.GUI.FontSizes.configTitle)
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -7)
    frame.title:SetJustifyH("LEFT")
    frame.title:SetTextColor(1, 1, 1, 1)
    frame.title:SetShadowColor(0, 0, 0, 1)
    frame.title:SetShadowOffset(1, -1)
    frame.title:SetPoint("TOP", 0, -2)
    frame.title:SetText("Mec Drums Alarm Configuration")

    --Close Button
    local closeButton = CreateFrame("Button", nil, frame)
    closeButton:SetHeight(14)
    closeButton:SetWidth(14)
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -8)
    closeButton.icon = closeButton:CreateTexture()
    closeButton.icon:SetTexture("Interface\\AddOns\\MecDrumsAlarm\\Media\\close.tga")
    closeButton.icon:SetVertexColor(1, 1, 1, 1)
    closeButton.icon:SetAllPoints()

    closeButton:SetScript("OnClick", function(self) self:GetParent():Hide() end)
    closeButton:SetScript("OnEnter", function()
        closeButton.icon:SetVertexColor(1, 0.4, 0.4)
    end)
    closeButton:SetScript("OnLeave", function()
        closeButton.icon:SetVertexColor(1, 1, 1)
    end)

    --==========================================
    --Options
    --==========================================
    local function CreateOptionLabel(text, x, y, width)
        local f = frame:CreateFontString(nil, "ARTWORK")
        f:SetFont(M.GUI.FontPath, M.GUI.FontSizes.configOption)
        f:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
        f:SetWidth(width)
        f:SetHeight(rowHeight)
        f:SetJustifyH("RIGHT")
        f:SetTextColor(1, 1, 1, 1)
        f:SetShadowColor(0, 0, 0, 1)
        f:SetShadowOffset(1, -1)
        f:SetPoint("TOP", 0, -2)
        f:SetText(text .. ":")
    end

    local function buttonPressHandler(button, configName, option, brotherButtons)
        M.Config[configName] = option.value

        for k, v in pairs(brotherButtons) do
            if button == v then
                button.underline:Show()
            else
                v.underline:Hide()
            end
        end

        M.GUI.MasterFrame:Render()
    end

    local function CreateConfigButton(configName, option, x, y, width)
        local button = CreateFrame("Button", nil, frame)
        button:SetHeight(rowHeight)
        button:SetWidth(width)
        button:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)

        button.text = button:CreateFontString(nil, "ARTWORK")
        button.text:SetFont(M.GUI.FontPath, M.GUI.FontSizes.configOption)
        button.text:SetHeight(rowHeight)
        button.text:SetWidth(width)
        button.text:SetText(option.label)
        button.text:SetTextColor(1, 1, 1, 1)
        button.text:SetPoint("TOP", button)

        button.text:Hide() --this is necessary to get button.text:GetStringWidth() to work on initially logging in...
        button.text:Show()

        -- Create the underline
        button.underline = button:CreateTexture()
        button.underline:SetTexture("Interface\\BUTTONS\\WHITE8x8")
        button.underline:SetHeight(2)
        button.underline:SetWidth(button.text:GetStringWidth())
        button.underline:SetPoint("TOP", button.text, "BOTTOM", 0, 2)

        if M.Config[configName] == option.value then
            button.underline:Show()
        else
            button.underline:Hide()
        end

        return button
    end

    local function CreateOptionRow(currRow, configName, values, colWidths)
        local y = -15 - (currRow * (rowHeight + rowPadding))
        CreateOptionLabel(values.label, 0, y, colWidths[1])

        local x = colWidths[1]
        local brotherButtonsList = {}
        for currCol, option in ipairs(values.options) do
            local button = CreateConfigButton(configName, option, x, y, colWidths[1 + currCol])
            x = x + colWidths[1 + currCol]
            table.insert(brotherButtonsList, button)
            button:SetScript("OnClick", function(self) buttonPressHandler(self, configName, option, brotherButtonsList) end)
        end
    end

    --Make the options table which is composed of option rows
    for currRow, configName in ipairs(M.GUI.orderedConfigNames) do
        CreateOptionRow(currRow, configName, M.GUI.configUIData[configName], colWidths)
    end

    frame:Hide()
end

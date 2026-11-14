---@type string, WaylaidCrateHelperNamespace
local ADDON_NAME, ns = ...
local L = ns.L

ns.SettingsHelper = ns.SettingsHelper or {}
local SettingsHelper = ns.SettingsHelper

---Gets the current saved tooltip settings.
---@return WaylaidCrateSettings settings The saved display settings.
function SettingsHelper.GetTooltipSettings()
    return assert(WaylaidCreteHelperDB, "Tooltip settings are not initialized")
end

local options = {
    { key = "showOwned", name = L["Show owned materials"], description = L["Show how many required materials you have in your bags and bank."], default = true },
    { key = "showMissing", name = L["Show missing materials"], description = L["Show how many required materials you still need."], default = true },
    { key = "showMissingMoney", name = L["Show missing materials cost"], description = L["Show the estimated cost of the materials you still need."], default = true },
    { key = "showOwnedWhenNothingOwned", name = L["Show owned amount when none are owned"], description = L["Show an owned amount of zero when you have none of a required material."], default = false },
    { key = "showMissingWhenNothingOwned", name = L["Show missing amount when none are owned"], description = L["Show the missing amount when you have none of a required material."], default = false },
}

local moneyFormatOptions = {
    { value = "icons", label = L["Coin icons"] .. " " .. GetMoneyString(10203) },
    { value = "text", label = L["Colored text"] .. " " .. ns.EconomyHelper.FormatMoney(10203, "text") },
}

---Registers saved settings after the addon has loaded.
---@param frame Frame The event frame.
---@param event string The event name.
---@param addonName string The loaded addon name.
---@return nil
local function OnAddonLoaded(frame, event, addonName)
    if (addonName ~= ADDON_NAME) then
        return nil
    end
    frame:UnregisterEvent(event)

    if (WaylaidCreteHelperDB == nil) then
        WaylaidCreteHelperDB = {}
    end

    local panel = CreateFrame("Frame")
    panel:Hide()
    local scroll = CreateFrame("ScrollFrame", "WaylaidCrateHelperSettingsScroll", panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, -4)
    scroll:SetPoint("BOTTOMRIGHT", -26, 4)

    local body = CreateFrame("Frame", nil, scroll)
    body:SetSize(math.max(scroll:GetWidth(), 400), 306)

    ---Keeps the settings content aligned with the scroll area.
    ---@param _ Frame The scroll frame.
    ---@param width number The scroll area width.
    ---@return nil
    local function OnSizeChanged(_, width)
        body:SetWidth(math.max(width, 1))
        return nil
    end
    scroll:SetScript("OnSizeChanged", OnSizeChanged)

    local header = CreateFrame("Frame", nil, body)
    header:SetPoint("TOPLEFT", 16, -16)
    header:SetSize(400, 54)

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetText(L["Waylaid Crate Helper"])

    local version = header:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    version:SetPoint("TOPLEFT", 0, -24)
    version:SetText(assert(C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version"), "Addon version is unavailable"))

    local heading = body:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    heading:SetPoint("TOPLEFT", body, "TOPLEFT", 16, -80)
    heading:SetText(L["General"])

    ---Resolves the heading position after the settings content becomes visible.
    ---@return nil
    local function PositionHeading()
        if (body:IsVisible()) then
            heading:ClearAllPoints()
            heading:SetPoint("TOPLEFT", body, "TOPLEFT", 16, -80)
        end
        return nil
    end

    ---Schedules heading layout after the settings content is shown.
    ---@return nil
    local function OnBodyShow()
        C_Timer.After(0, PositionHeading)
        return nil
    end
    body:HookScript("OnShow", OnBodyShow)

    local rule = body:CreateTexture(nil, "ARTWORK")
    local r, g, b = NORMAL_FONT_COLOR:GetRGB()
    rule:SetColorTexture(r, g, b, 0.25)
    rule:SetHeight(1)
    rule:SetPoint("TOPLEFT", 16, -96)
    rule:SetPoint("TOPRIGHT", -16, -96)

    local checkboxes = {}
    local preview
    for index, option in ipairs(options) do
        if (WaylaidCreteHelperDB[option.key] == nil) then
            WaylaidCreteHelperDB[option.key] = option.default
        end

        local check = CreateFrame("CheckButton", nil, body, "UICheckButtonTemplate")
        check:SetSize(26, 26)
        check:SetPoint("TOPLEFT", 14, -102 - (index - 1) * 30)

        local label = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        label:SetPoint("LEFT", check, "RIGHT", 4, 1)
        label:SetText(option.name)
        check:SetHitRectInsets(0, -label:GetStringWidth() - 8, 0, 0)

        ---Saves the selected setting.
        ---@param button CheckButton The clicked checkbox.
        ---@return nil
        local function OnClick(button)
            WaylaidCreteHelperDB[option.key] = not not button:GetChecked()
            preview.Refresh()
            return nil
        end

        ---Shows the setting description.
        ---@param button CheckButton The hovered checkbox.
        ---@return nil
        local function OnEnter(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:AddLine(option.name)
            local whiteR, whiteG, whiteB = HIGHLIGHT_FONT_COLOR:GetRGB()
            GameTooltip:AddLine(option.description, whiteR, whiteG, whiteB, true)
            GameTooltip:Show()
            return nil
        end

        ---Hides the setting description.
        ---@return nil
        local function OnLeave()
            GameTooltip:Hide()
            return nil
        end

        check:SetScript("OnClick", OnClick)
        check:SetScript("OnEnter", OnEnter)
        check:SetScript("OnLeave", OnLeave)
        checkboxes[index] = check
    end

    if (WaylaidCreteHelperDB.moneyFormat ~= "icons" and WaylaidCreteHelperDB.moneyFormat ~= "text") then
        WaylaidCreteHelperDB.moneyFormat = "icons"
    end

    local moneyFormatLabel = body:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    moneyFormatLabel:SetPoint("TOPLEFT", body, "TOPLEFT", 16, -255)
    moneyFormatLabel:SetText(L["Currency format"])

    local moneyFormatDropdown = CreateFrame("DropdownButton", nil, body, "WowStyle1DropdownTemplate")
    moneyFormatDropdown:SetWidth(270)
    moneyFormatDropdown:SetPoint("LEFT", moneyFormatLabel, "RIGHT", 12, 0)

    ---Sets the selected currency format in the dropdown.
    ---@return nil
    local function UpdateMoneyFormatDropdown()
        for _, option in ipairs(moneyFormatOptions) do
            if (option.value == WaylaidCreteHelperDB.moneyFormat) then
                moneyFormatDropdown:OverrideText(option.label)
                return nil
            end
        end
        return nil
    end

    ---Checks whether a currency format is selected.
    ---@param value "icons"|"text" The candidate format.
    ---@return boolean selected Whether the format is selected.
    local function IsMoneyFormatSelected(value)
        return WaylaidCreteHelperDB.moneyFormat == value
    end

    ---Saves the selected currency format and refreshes the preview.
    ---@param value "icons"|"text" The selected format.
    ---@return nil
    local function SetMoneyFormat(value)
        WaylaidCreteHelperDB.moneyFormat = value
        UpdateMoneyFormatDropdown()
        preview.Refresh()
        return nil
    end

    ---Builds the currency-format dropdown menu.
    ---@param _ DropdownButton The dropdown button.
    ---@param rootDescription RootMenuDescriptionProxy The menu description.
    ---@return nil
    local function BuildMoneyFormatMenu(_, rootDescription)
        for _, option in ipairs(moneyFormatOptions) do
            rootDescription:CreateRadio(option.label, IsMoneyFormatSelected, SetMoneyFormat, option.value)
        end
        return nil
    end

    moneyFormatDropdown:SetupMenu(BuildMoneyFormatMenu)
    UpdateMoneyFormatDropdown()

    ns.Settings = WaylaidCreteHelperDB
    preview = ns.SettingsPreview.Create(body)
    scroll:SetScrollChild(body)

    ---Refreshes the checkboxes from saved settings.
    ---@return nil
    function panel:OnRefresh()
        for index, option in ipairs(options) do
            checkboxes[index]:SetChecked(WaylaidCreteHelperDB[option.key])
        end
        UpdateMoneyFormatDropdown()
        preview.Refresh()
        return nil
    end

    ---Restores the default settings.
    ---@return nil
    function panel:OnDefault()
        for _, option in ipairs(options) do
            WaylaidCreteHelperDB[option.key] = option.default
        end
        WaylaidCreteHelperDB.moneyFormat = "icons"
        self:OnRefresh()
        return nil
    end

    panel:SetScript("OnShow", panel.OnRefresh)
    local category = Settings.RegisterCanvasLayoutCategory(panel, L["Waylaid Crate Helper"])
    Settings.RegisterAddOnCategory(category)
    return nil
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnAddonLoaded)

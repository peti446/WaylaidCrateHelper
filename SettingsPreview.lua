---@type string, WaylaidCrateHelperNamespace
local _, ns = ...
local L = ns.L
local TooltipHelper = ns.TooltipHelper

ns.SettingsPreview = ns.SettingsPreview or {}
local SettingsPreview = ns.SettingsPreview

local crateID = 248682
local previewTop = 290
local examples = {
    { itemID = 2447, price = 10, bags = 3, bank = 2 },
    { itemID = 765, price = 12, bags = 0, bank = 0 },
    { itemID = 2449, price = 30, bags = 10, bank = 0 },
    { itemID = 785, price = 40, bags = 6, bank = 5 },
    { itemID = 2450, price = 50, bags = 0, bank = 4 },
}

---Creates a tooltip preview using example prices and inventory.
---@param body Frame The scrollable settings content.
---@return WaylaidSettingsPreview preview The preview controller.
function SettingsPreview.Create(body)
    local heading = body:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    heading:SetPoint("TOPLEFT", 16, -267)
    heading:SetText(L["Example tooltip (sample prices and inventory)"])

    local tooltip = CreateFrame("GameTooltip", "WaylaidCrateHelperPreviewTooltip", body, "GameTooltipTemplate")
    tooltip:SetClampedToScreen(false)

    local requested = {}
    ---Gets a localized item name and requests it if it is not cached.
    ---@param itemID number The item ID.
    ---@return string? name The cached item name.
    local function GetExampleName(itemID)
        local name = C_Item.GetItemInfo(itemID)
        if (not name and not requested[itemID]) then
            requested[itemID] = true
            C_Item.RequestLoadItemDataByID(itemID)
        end
        return name
    end

    ---Renders the preview using the current settings.
    ---@return nil
    local function Refresh()
        if (not body:IsVisible()) then
            return nil
        end

        tooltip:SetOwner(body, "ANCHOR_NONE")
        tooltip:ClearAllPoints()
        tooltip:SetPoint("TOPLEFT", body, "TOPLEFT", 16, -previewTop)
        tooltip:SetFrameStrata(body:GetFrameStrata())
        tooltip:SetFrameLevel(body:GetFrameLevel() + 1)
        tooltip:SetMinimumWidth(math.max(body:GetWidth() - 32, 1))
        local settings = ns.SettingsHelper.GetTooltipSettings()
        local requirements = assert(ns.CrateHelper.GetRequirements(crateID), "Preview crate requirements are unavailable")
        local materials = {}
        for _, example in ipairs(examples) do
            local quantity = assert(requirements[example.itemID], "Preview material is missing from the crate")
            materials[#materials + 1] = {
                itemID = example.itemID,
                quantity = quantity,
                name = GetExampleName(example.itemID),
                price = example.price,
                totalPrice = example.price * quantity,
                bags = example.bags,
                bank = example.bank,
            }
        end
        table.sort(materials,
            ---Sorts example materials by total bundle cost.
            ---@param left table The first material.
            ---@param right table The second material.
            ---@return boolean ordered Whether the first material comes first.
            function(left, right)
                if (left.totalPrice ~= right.totalPrice) then
                    return left.totalPrice < right.totalPrice
                end
                return left.itemID < right.itemID
            end
        )

        tooltip:ClearLines()
        tooltip:AddLine(GetExampleName(crateID) or L["Waylaid Crate: Apprentice Herbs"], HIGHLIGHT_FONT_COLOR:GetRGB())
        tooltip:AddLine(L["Use: Fill the crate with any bundle from the following list:"], NORMAL_FONT_COLOR:GetRGB())
        for _, material in ipairs(materials) do
            TooltipHelper.AddSeparator(tooltip)
            TooltipHelper.AddMaterial(tooltip, material, material.bags, material.bank, settings)
        end
        TooltipHelper.AddSeparator(tooltip)
        tooltip:Show()
        body:SetHeight(previewTop + math.max(tooltip:GetHeight(), 1) + 16)
        return nil
    end

    body:HookScript("OnShow", Refresh)

    local bodyWidth = body:GetWidth()
    ---Refreshes the preview when the settings content changes width.
    ---@param _ Frame The settings content.
    ---@param width number The content width.
    ---@return nil
    local function OnSizeChanged(_, width)
        if (width ~= bodyWidth) then
            bodyWidth = width
            Refresh()
        end
        return nil
    end
    body:HookScript("OnSizeChanged", OnSizeChanged)

    local events = CreateFrame("Frame", nil, body)
    events:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    ---Refreshes names as their item data becomes available.
    ---@param _ Frame The event frame.
    ---@param event string The event name.
    ---@param itemID number The loaded item ID.
    ---@param success boolean Whether item data was loaded.
    ---@return nil
    local function OnItemInfoReceived(_, event, itemID, success)
        if (event == "ITEM_DATA_LOAD_RESULT" and success and requested[itemID] and body:IsVisible()) then
            Refresh()
        end
        return nil
    end
    events:SetScript("OnEvent", OnItemInfoReceived)

    return { Refresh = Refresh }
end

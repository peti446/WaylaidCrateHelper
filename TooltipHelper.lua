---@type string, WaylaidCrateHelperNamespace
local _, ns = ...

ns.TooltipHelper = ns.TooltipHelper or {}
local TooltipHelper = ns.TooltipHelper
local L = ns.L
local numberColor = CreateColor(1, 128 / 255, 0)
local separatorStates = {}

---Adds a material and its optional inventory details to a tooltip.
---@param tooltip GameTooltip The item tooltip.
---@param material WaylaidTooltipMaterial The material and its price.
---@param bagCount number The amount in bags.
---@param bankCount number The amount in the bank.
---@param settings WaylaidCrateSettings The display settings.
---@return nil
function TooltipHelper.AddMaterial(tooltip, material, bagCount, bankCount, settings)
    local name = material.name or string.format(L["Unknown item %d"], material.itemID)
    local totalPrice = L["Unavailable"]
    if (material.totalPrice) then
        totalPrice = ns.EconomyHelper.FormatMoney(material.totalPrice)
    end
    local materialR, materialG, materialB = GREEN_FONT_COLOR:GetRGB()
    local r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB()
    tooltip:AddDoubleLine(
        string.format(L["- %d %s"], material.quantity, name),
        totalPrice, materialR, materialG, materialB, r, g, b
    )

    local owned = bagCount + bankCount
    if (settings.showOwned and (owned > 0 or settings.showOwnedWhenNothingOwned)) then
        tooltip:AddLine(string.format(
            L["    Owned: %s (bags: %s, bank: %s)"],
            numberColor:WrapTextInColorCode(tostring(owned)),
            numberColor:WrapTextInColorCode(tostring(bagCount)),
            numberColor:WrapTextInColorCode(tostring(bankCount))
        ), r, g, b)
    end

    local missing = math.max(material.quantity - owned, 0)
    if (settings.showMissing and missing > 0 and (owned > 0 or settings.showMissingWhenNothingOwned)) then
        local text = string.format(L["    Missing: %s"], numberColor:WrapTextInColorCode(tostring(missing)))
        if (settings.showMissingMoney) then
            local missingPrice = L["Unavailable"]
            if (material.price) then
                missingPrice = ns.EconomyHelper.FormatMoney(material.price * missing)
            end
            tooltip:AddDoubleLine(text, missingPrice, r, g, b, r, g, b)
        else
            tooltip:AddLine(text, r, g, b)
        end
    end
    return nil
end

---Hides separators when a tooltip is cleared or hidden.
---@param tooltip GameTooltip The item tooltip.
---@return nil
function TooltipHelper.ClearSeparators(tooltip)
    local state = separatorStates[tooltip]
    if (state) then
        for _, texture in ipairs(state.textures) do
            texture:Hide()
        end
        state.used = 0
    end
    return nil
end

---Updates separator widths when a tooltip changes size.
---@param tooltip GameTooltip The item tooltip.
---@param width number The tooltip width.
---@return nil
function TooltipHelper.ResizeSeparators(tooltip, width)
    local state = separatorStates[tooltip]
    if (state) then
        for index = 1, state.used do
            state.textures[index]:SetWidth(math.max(width - 20, 1))
        end
    end
    return nil
end

---Adds a reusable full-width separator.
---@param tooltip GameTooltip The item tooltip.
---@return nil
function TooltipHelper.AddSeparator(tooltip)
    local state = separatorStates[tooltip]
    if (not state) then
        state = { textures = {}, used = 0 }
        separatorStates[tooltip] = state
        tooltip:HookScript("OnTooltipCleared", TooltipHelper.ClearSeparators)
        tooltip:HookScript("OnHide", TooltipHelper.ClearSeparators)
        tooltip:HookScript("OnSizeChanged", TooltipHelper.ResizeSeparators)
    end

    tooltip:AddLine(" ")
    local line = tooltip:GetLeftLine(tooltip:NumLines())
    assert(line, "Tooltip separator line is unavailable")

    state.used = state.used + 1
    local texture = state.textures[state.used]
    if (not texture) then
        texture = tooltip:CreateTexture(nil, "ARTWORK")
        texture:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
        texture:SetHeight(8)
        texture:SetAlpha(0.7)
        state.textures[state.used] = texture
    end
    texture:ClearAllPoints()
    texture:SetPoint("LEFT", line, "LEFT", 0, 0)
    texture:SetWidth(math.max(tooltip:GetWidth() - 20, 1))
    texture:Show()
    return nil
end

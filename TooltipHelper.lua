---@type string, WaylaidCrateHelperNamespace
local _, ns = ...

ns.TooltipHelper = ns.TooltipHelper or {}
local TooltipHelper = ns.TooltipHelper
local separatorStates = {}

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

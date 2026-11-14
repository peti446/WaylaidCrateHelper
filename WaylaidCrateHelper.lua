---@type string, WaylaidCrateHelperNamespace
local _, ns = ...

---@class WaylaidCrateHelper : WaylaidCrateHelperNamespace
local WaylaidCrateHelper = ns
local L = ns.L
local TooltipHelper = ns.TooltipHelper
local numberColor = CreateColor(1, 128 / 255, 0)

--@debug@
---Adds a debug message at the end of the tooltip.
---@param tooltip GameTooltip The item tooltip.
---@param message string The diagnostic message.
---@return nil
function WaylaidCrateHelper.ReportTooltipDebug(tooltip, message)
    tooltip:AddLine(string.format(L["[Debug] %s"], message), HIGHLIGHT_FONT_COLOR:GetRGB())
    return nil
end
--@end-debug@

---Rebuilds a crate tooltip with material rows sorted by total price.
---@param tooltip GameTooltip The item tooltip.
---@param requirements table<number, number> The crate's material requirements.
---@return nil
function WaylaidCrateHelper.RebuildRequirements(tooltip, requirements)
    if (not tooltip.GetLeftLine or not tooltip.GetRightLine) then
        --@debug@
        WaylaidCrateHelper.ReportTooltipDebug(tooltip, L["Tooltip line access is unavailable."])
        tooltip:Show()
        --@end-debug@
        return nil
    end

    local quantities = {}
    local requiredCount = 0
    for _, quantity in pairs(requirements) do
        quantities[quantity] = (quantities[quantity] or 0) + 1
        requiredCount = requiredCount + 1
    end
    if (requiredCount == 0) then
        --@debug@
        WaylaidCrateHelper.ReportTooltipDebug(tooltip, L["The crate has no material requirements."])
        tooltip:Show()
        --@end-debug@
        return nil
    end

    local rows = {}
    local requirementRow
    local ambiguousRow = false
    local blockedByRightText = false
    for index = 1, tooltip:NumLines() do
        local left = tooltip:GetLeftLine(index)
        local right = tooltip:GetRightLine(index)
        if (not left) then
            --@debug@
            WaylaidCrateHelper.ReportTooltipDebug(tooltip, string.format(L["Tooltip line %d has no left text region."], index))
            tooltip:Show()
            --@end-debug@
            return nil
        end

        local text = left:GetText() or ""
        local r, g, b = left:GetTextColor()
        local rightText = right and right:GetText()
        local rightR, rightG, rightB
        if (rightText and rightText ~= "") then
            rightR, rightG, rightB = right:GetTextColor()
        end
        local row = {
            text = text, r = r, g = g, b = b,
            rightText = rightText, rightR = rightR, rightG = rightG, rightB = rightB,
        }
        rows[index] = row

        local parts = {}
        local rowQuantities = {}
        local lineCount = 0
        for line in (text .. "\n"):gmatch("(.-)\n") do
            local plainText = line:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
            local quantity = tonumber(plainText:match("^%s*%-%s*(%d+)"))
            parts[#parts + 1] = { text = line, requirement = quantity ~= nil }
            if (quantity) then
                lineCount = lineCount + 1
                rowQuantities[quantity] = (rowQuantities[quantity] or 0) + 1
            end
        end
        row.parts = parts
        local matches = lineCount == requiredCount
        for quantity, count in pairs(quantities) do
            if (rowQuantities[quantity] ~= count) then
                matches = false
                break
            end
        end
        if (matches) then
            if (rightText and rightText ~= "") then
                blockedByRightText = true
            elseif (requirementRow) then
                ambiguousRow = true
            else
                requirementRow = index
            end
        end
    end

    if (not requirementRow or ambiguousRow or blockedByRightText) then
        --@debug@
        if (ambiguousRow) then
            WaylaidCrateHelper.ReportTooltipDebug(tooltip, L["Multiple possible requirements rows were found."])
        elseif (blockedByRightText) then
            WaylaidCrateHelper.ReportTooltipDebug(tooltip, L["The requirements row already has right-side text."])
        else
            WaylaidCrateHelper.ReportTooltipDebug(tooltip, L["No requirements row with the expected quantities was found."])
        end
        tooltip:Show()
        --@end-debug@
        return nil
    end

    if (not tooltip.HasScript or not tooltip.HookScript
        or not tooltip.CreateTexture or not tooltip.GetWidth
        or not tooltip:HasScript("OnTooltipCleared") or not tooltip:HasScript("OnHide")
        or not tooltip:HasScript("OnSizeChanged")) then
        --@debug@
        WaylaidCrateHelper.ReportTooltipDebug(tooltip, L["Tooltip separator support is unavailable."])
        tooltip:Show()
        --@end-debug@
        return nil
    end

    local materialList = {}
    for itemID, quantity in pairs(requirements) do
        local price = ns.EconomyHelper.GetItemPrice(itemID)
        materialList[#materialList + 1] = {
            itemID = itemID,
            quantity = quantity,
            name = C_Item.GetItemInfo(itemID),
            price = price,
            totalPrice = price and price * quantity,
        }
    end
    table.sort(materialList,
        ---Sorts available bundle prices first, with item IDs breaking ties.
        ---@param left table The first material.
        ---@param right table The second material.
        ---@return boolean ordered Whether the first material comes first.
        function(left, right)
            if (left.totalPrice and right.totalPrice and left.totalPrice ~= right.totalPrice) then
                return left.totalPrice < right.totalPrice
            elseif (left.totalPrice and not right.totalPrice) then
                return true
            elseif (right.totalPrice and not left.totalPrice) then
                return false
            end
            return left.itemID < right.itemID
        end
    )

    tooltip:ClearLines()
    TooltipHelper.ClearSeparators(tooltip)
    local materialR, materialG, materialB = GREEN_FONT_COLOR:GetRGB()
    for index, row in ipairs(rows) do
        if (index == requirementRow) then
            local addedMaterials = false
            for _, part in ipairs(row.parts) do
                if (part.requirement and not addedMaterials) then
                    for _, material in ipairs(materialList) do
                        TooltipHelper.AddSeparator(tooltip)
                        local name = material.name or string.format(L["Unknown item %d"], material.itemID)
                        local totalPrice = L["Unavailable"]
                        if (material.totalPrice) then
                            totalPrice = ns.EconomyHelper.FormatMoney(material.totalPrice)
                        end
                        local r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB()
                        tooltip:AddDoubleLine(
                            string.format(L["- %d %s"], material.quantity, name),
                            totalPrice, materialR, materialG, materialB, r, g, b
                        )

                        local bagCount = ns.InventoryHelper.GetBagItemCount(material.itemID)
                        local bankCount = ns.InventoryHelper.GetBankItemCount(material.itemID)
                        local owned = bagCount + bankCount
                        if (owned > 0) then
                            tooltip:AddLine(string.format(
                                L["    Owned: %s (bags: %s, bank: %s)"],
                                numberColor:WrapTextInColorCode(tostring(owned)),
                                numberColor:WrapTextInColorCode(tostring(bagCount)),
                                numberColor:WrapTextInColorCode(tostring(bankCount))
                            ), r, g, b)
                            local missing = math.max(material.quantity - owned, 0)
                            if (missing > 0) then
                                local missingPrice = L["Unavailable"]
                                if (material.price) then
                                    missingPrice = ns.EconomyHelper.FormatMoney(material.price * missing)
                                end
                                tooltip:AddDoubleLine(
                                    string.format(L["    Missing: %s"], numberColor:WrapTextInColorCode(tostring(missing))),
                                    missingPrice, r, g, b, r, g, b
                                )
                            end
                        end
                    end
                    TooltipHelper.AddSeparator(tooltip)
                    addedMaterials = true
                elseif (not part.requirement) then
                    tooltip:AddLine(part.text, row.r, row.g, row.b, true)
                end
            end
        elseif (row.rightText and row.rightText ~= "") then
            tooltip:AddDoubleLine(row.text, row.rightText, row.r, row.g, row.b, row.rightR, row.rightG, row.rightB)
        else
            tooltip:AddLine(row.text, row.r, row.g, row.b, true)
        end
    end

    --@debug@
    for _, material in ipairs(materialList) do
        if (not material.name) then
            WaylaidCrateHelper.ReportTooltipDebug(
                tooltip, string.format(L["Item %d name is not available in the cache."], material.itemID)
            )
        end
    end
    --@end-debug@
    tooltip:Show()
    return nil
end

---Adds crate material prices and inventory details to an item tooltip.
---@param tooltip GameTooltip The item tooltip.
---@param tooltipData table|number|nil The tooltip data or item ID, when available.
---@return nil
function WaylaidCrateHelper.OnTooltipSetItem(tooltip, tooltipData)
    if (InCombatLockdown()) then
        return nil
    end

    local _, itemLink = tooltip:GetItem()
    local itemID = itemLink and tonumber(itemLink:match("item:(%d+)"))
    if (not itemID and type(tooltipData) == "table") then
        itemID = tooltipData.id
    elseif (not itemID and type(tooltipData) == "number") then
        itemID = tooltipData
    end
    if (not itemID) then
        return nil
    end

    local requirements = ns.CrateHelper.GetRequirements(itemID)
    if (not requirements) then
        return nil
    end
    WaylaidCrateHelper.RebuildRequirements(tooltip, requirements)
    return nil
end

local tooltipDataProcessor = TooltipDataProcessor
if (tooltipDataProcessor and tooltipDataProcessor.AddTooltipPostCall) then
    tooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, WaylaidCrateHelper.OnTooltipSetItem)
else
    if (GameTooltip:HasScript("OnTooltipSetItem")) then
        GameTooltip:HookScript("OnTooltipSetItem", WaylaidCrateHelper.OnTooltipSetItem)
    else
        hooksecurefunc(GameTooltip, "SetItemByID", WaylaidCrateHelper.OnTooltipSetItem)
    end

    local itemRefTooltip = ItemRefTooltip
    if (itemRefTooltip and itemRefTooltip:HasScript("OnTooltipSetItem")) then
        itemRefTooltip:HookScript("OnTooltipSetItem", WaylaidCrateHelper.OnTooltipSetItem)
    end
end

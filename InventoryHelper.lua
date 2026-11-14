---@type string, WaylaidCrateHelperNamespace
local _, ns = ...

ns.InventoryHelper = ns.InventoryHelper or {}
local InventoryHelper = ns.InventoryHelper

---Counts an item in the player's bags.
---@param itemID number The item ID.
---@return number count The number of items in bags.
function InventoryHelper.GetBagItemCount(itemID)
    local count = 0
    for bag = Enum.BagIndex.Backpack, Enum.BagIndex.ReagentBag do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if (item and item.itemID == itemID) then
                count = count + item.stackCount
            end
        end
    end

    return count
end

---Counts an item in the personal bank and reagent bank.
---@param itemID number The item ID.
---@return number count The number of items in the bank.
function InventoryHelper.GetBankItemCount(itemID)
    local withBank = C_Item.GetItemCount(itemID, true, false, true, false)
    local withoutBank = C_Item.GetItemCount(itemID, false, false, false, false)
    return withBank - withoutBank
end

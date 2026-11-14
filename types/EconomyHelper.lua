---@meta

---@class WaylaidPriceSourceAvailability
---@field tsmInstalled boolean
---@field auctionatorInstalled boolean
---@field auctionatorPriceDatabaseAvailable boolean

---@class WaylaidEconomyHelper
---@field GetPriceSourceAvailability fun(): WaylaidPriceSourceAvailability
---@field GetItemPrice fun(item: number|string): number?
---@field FormatMoney fun(copper: number): string

---@class WaylaidCrateRequirementsHelper
---@field GetRequirements fun(crateItemID: number): table<number, number>?

---@class WaylaidInventoryHelper
---@field GetBagItemCount fun(itemID: number): number
---@field GetBankItemCount fun(itemID: number): number

---@class WaylaidTooltipHelper
---@field ClearSeparators fun(tooltip: GameTooltip): nil
---@field ResizeSeparators fun(tooltip: GameTooltip, width: number): nil
---@field AddSeparator fun(tooltip: GameTooltip): nil

---@class WaylaidCrateHelperNamespace
---@field L table<string, string>
---@field EconomyHelper WaylaidEconomyHelper
---@field CrateHelper WaylaidCrateRequirementsHelper
---@field InventoryHelper WaylaidInventoryHelper
---@field TooltipHelper WaylaidTooltipHelper
---@field CrateInfoDB table<number, table<number, number>>

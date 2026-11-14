---@type string, WaylaidCrateHelperNamespace
local _, ns = ...

ns.CrateHelper = ns.CrateHelper or {}
local CrateHelper = ns.CrateHelper

---Gets the available material requirements for a crate.
---@param crateItemID number The crate item ID.
---@return table<number, number>? requirements Material item IDs and required quantities.
function CrateHelper.GetRequirements(crateItemID)
    return ns.CrateInfoDB[crateItemID]
end

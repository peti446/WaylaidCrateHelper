local _, ns = ...
---@type table<string, string|true>
local translations = {}

---Gets a translation or returns the key for missing and default entries.
---@param _ table The localization table.
---@param key string The localization key.
---@return string text The translated or default text.
local function GetTranslation(_, key)
    local value = translations[key]
    if (value == nil or value == true) then
        return key
    end

    return value
end

---Stores a translation outside the proxy table so all reads use the lookup function.
---@param _ table The localization table.
---@param key string The localization key.
---@param value string|true|nil The translation or default marker.
---@return nil
local function SetTranslation(_, key, value)
    translations[key] = value
    return nil
end

ns.L = setmetatable({}, { __index = GetTranslation, __newindex = SetTranslation })

--@localization(locale="enUS", format="lua_additive_table", table-name="ns.L", same-key-is-true=true, handle-unlocalized="comment", escape-non-ascii=true, handle-subnamespaces="concat")@
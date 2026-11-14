---@type string, WaylaidCrateHelperNamespace
local ADDON_NAME, ns = ...
local L = ns.L

ns.EconomyHelper = ns.EconomyHelper or {}
local EconomyHelper = ns.EconomyHelper
local goldTextColor = CreateColor(1, 0.82, 0)
local silverTextColor = CreateColor(0.78, 0.78, 0.81)
local copperTextColor = CreateColor(0.93, 0.65, 0.37)

---Formats a copper amount using icons or colored denomination text.
---@param copper number The amount in copper.
---@param format? "icons"|"text" The display format; defaults to coin icons.
---@return string formatted The formatted currency amount.
function EconomyHelper.FormatMoney(copper, format)
    copper = math.floor(copper + 0.5)
    if (format ~= "text") then
        return GetMoneyString(copper)
    end

    local gold = math.floor(copper / 10000)
    local silver = math.floor(copper / 100) % 100
    local remainingCopper = copper % 100
    local parts = {}
    if (gold > 0) then
        parts[#parts + 1] = FormatLargeNumber(gold) .. goldTextColor:WrapTextInColorCode(L["g"])
    end
    if (silver > 0) then
        parts[#parts + 1] = tostring(silver) .. silverTextColor:WrapTextInColorCode(L["s"])
    end
    if (remainingCopper > 0 or #parts == 0) then
        parts[#parts + 1] = tostring(remainingCopper) .. copperTextColor:WrapTextInColorCode(L["c"])
    end
    return table.concat(parts, " ")
end

---Converts a value to a positive, finite price.
---@param value number|string|nil The value returned by a price source.
---@return number? price The price in copper, or nil if it is invalid.
local function GetPositivePrice(value)
    local price = tonumber(value)
    if (price and price > 0 and price < math.huge) then
        return price
    end

    return nil
end

---Resolves an item ID, link or item string, and cached item name.
---@param item number|string An item ID, numeric string, item string, or item link.
---@return number? itemID The item ID, or nil if the input is invalid.
---@return string? itemLink The item link or a fallback item string.
---@return string? itemName The cached item name, if available.
local function GetItemDetails(item)
    local itemID
    if (type(item) == "number") then
        itemID = item
    elseif (type(item) == "string") then
        itemID = tonumber(item:match("|Hitem:(%d+)")) or tonumber(item:match("item:(%d+)"))
        itemID = itemID or tonumber(item)
    end

    if (not itemID or itemID <= 0) then
        return nil
    end

    local name, link
    local getItemInfo = C_Item and C_Item.GetItemInfo
    if (getItemInfo) then
        name, link = getItemInfo(item)
    end

    local fallbackLink = "item:" .. itemID
    if (type(item) == "string" and item:match("^item:")) then
        fallbackLink = item
    end

    return itemID, link or fallbackLink, name
end

---Searches the available Auctionator saved database for a positive price.
---@param itemID number The item ID.
---@param itemLink string The item link or item string.
---@param itemName string? The cached item name, if available.
---@return number? price The price in copper, or nil if none is found.
local function GetAuctionatorDatabasePrice(itemID, itemLink, itemName)
    local database = _G.AUCTIONATOR_PRICE_DATABASE
    if (type(database) ~= "table") then
        return nil
    end

    local realmDatabase = GetRealmName and database[GetRealmName()]
    local buckets = {}
    if (type(realmDatabase) == "table") then
        buckets[#buckets + 1] = realmDatabase
    end
    if (type(database.Default) == "table") then
        buckets[#buckets + 1] = database.Default
    end
    buckets[#buckets + 1] = database

    local itemKeys = { itemLink, itemID, tostring(itemID), "i:" .. itemID }
    if (itemName) then
        table.insert(itemKeys, 1, itemName)
    end
    local priceFields = { "minBuyout", "minSeen", "marketValue", "market", "price" }

    for _, bucket in ipairs(buckets) do
        for _, key in ipairs(itemKeys) do
            local record = bucket[key]
            if (type(record) == "table") then
                for _, field in ipairs(priceFields) do
                    local price = GetPositivePrice(record[field])
                    if (price) then
                        return price
                    end
                end
            else
                local price = GetPositivePrice(record)
                if (price) then
                    return price
                end
            end
        end
    end
end

---Queries TSM's dbmarket source for an item.
---@param itemID number The item ID.
---@param itemLink string The item link or item string to convert for TSM.
---@return number? price The price in copper, or nil if unavailable or invalid.
local function GetTSMPrice(itemID, itemLink)
    ---@type WaylaidTSMAPI!
    local tsmAPI = _G.TSM_API
    if (type(tsmAPI.GetCustomPriceValue) ~= "function") then
        return nil
    end

    local itemString = "i:" .. itemID
    if (type(tsmAPI.ToItemString) == "function") then
        itemString = tsmAPI.ToItemString(itemLink) or itemString
    end

    return GetPositivePrice(tsmAPI.GetCustomPriceValue("dbmarket", itemString))
end

---Queries Auctionator's price APIs, then the legacy buyout fallback.
---@param itemID number The item ID.
---@param itemLink string The item link or item string.
---@return number? price The price in copper, or nil if unavailable or invalid.
local function GetAuctionatorPrice(itemID, itemLink)
    local auctionator = _G.Auctionator
    local auctionatorAPI = auctionator and auctionator.API and auctionator.API.v1

    if (auctionatorAPI and type(auctionatorAPI.GetAuctionPriceByItemID) == "function") then
        local price = GetPositivePrice(auctionatorAPI.GetAuctionPriceByItemID(ADDON_NAME, itemID))
        if (price) then
            return price
        end
    end

    if (auctionatorAPI and type(auctionatorAPI.GetAuctionPriceByItemLink) == "function") then
        local price = GetPositivePrice(auctionatorAPI.GetAuctionPriceByItemLink(ADDON_NAME, itemLink))
        if (price) then
            return price
        end
    end

    local getAuctionBuyout = _G.GetAuctionBuyout
        or _G.Atr_GetAuctionBuyout
        or _G.ATR_GetAuctionBuyout
    if (type(getAuctionBuyout) == "function") then
        return GetPositivePrice(getAuctionBuyout(itemID))
    end

    return nil
end

---Checks which economy addon APIs and saved database are available.
---@return WaylaidPriceSourceAvailability availability The availability of each source.
function EconomyHelper.GetPriceSourceAvailability()
    local auctionator = _G.Auctionator

    return {
        tsmInstalled = type(_G.TSM_API) == "table",
        auctionatorInstalled = type(auctionator) == "table"
            or type(_G.Atr_GetAuctionBuyout) == "function"
            or type(_G.ATR_GetAuctionBuyout) == "function",
        auctionatorPriceDatabaseAvailable = type(_G.AUCTIONATOR_PRICE_DATABASE) == "table",
    }
end

---Gets the first positive price from TSM, Auctionator, or its saved database, in that order.
---@param item number|string An item ID, numeric string, item string, or item link.
---@return number? price The price in copper, or nil if no source provides one.
function EconomyHelper.GetItemPrice(item)
    local itemID, itemLink, itemName = GetItemDetails(item)
    if (not itemID or not itemLink) then
        return nil
    end

    local availability = EconomyHelper.GetPriceSourceAvailability()
    if (availability.tsmInstalled) then
        local price = GetTSMPrice(itemID, itemLink)
        if (price) then
            return price
        end
    end

    if (availability.auctionatorInstalled) then
        local price = GetAuctionatorPrice(itemID, itemLink)
        if (price) then
            return price
        end
    end

    if (availability.auctionatorPriceDatabaseAvailable) then
        return GetAuctionatorDatabasePrice(itemID, itemLink, itemName)
    end

    return nil
end

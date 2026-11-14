---@meta

---@class WaylaidAuctionatorAPIv1
---@field GetAuctionPriceByItemID? fun(callerID: string, itemID: number): number?
---@field GetAuctionPriceByItemLink? fun(callerID: string, itemLink: string): number?

---@class WaylaidAuctionatorAPI
---@field v1? WaylaidAuctionatorAPIv1

---@class WaylaidAuctionator
---@field API? WaylaidAuctionatorAPI

---@class WaylaidAuctionatorPriceRecord
---@field m? number Last scanned minimum price
---@field l? table<string, number>
---@field h? table<string, number>
---@field a? table<string, number>
---@field minBuyout? number
---@field minSeen? number
---@field marketValue? number
---@field market? number
---@field price? number

---@alias WaylaidAuctionatorRealmDatabase table<string|number, WaylaidAuctionatorPriceRecord|number|string>
---@alias WaylaidAuctionatorPriceDatabase table<string|number, WaylaidAuctionatorRealmDatabase|number|string>
---@alias WaylaidAuctionBuyout fun(item: number|string): number?

---@type WaylaidAuctionator?
Auctionator = nil

---@type WaylaidAuctionatorPriceDatabase?
AUCTIONATOR_PRICE_DATABASE = nil

---@type WaylaidAuctionBuyout?
GetAuctionBuyout = nil

---@type WaylaidAuctionBuyout?
Atr_GetAuctionBuyout = nil

---@type WaylaidAuctionBuyout?
ATR_GetAuctionBuyout = nil

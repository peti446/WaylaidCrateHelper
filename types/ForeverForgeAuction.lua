---@meta

---@class ForeverForgeAuctionMarketEntry
---@field low? number Lowest buyout price in copper
---@field rate? number Going rate in copper
---@field qty? number Listed quantity
---@field t? number Unix timestamp when seen

---@class ForeverForgeAuctionMarketBook
---@field items? table<string, ForeverForgeAuctionMarketEntry>

---@class ForeverForgeAuctionMarket
---@field Get? fun(self: ForeverForgeAuctionMarket, key: string): ForeverForgeAuctionMarketEntry?

---@class ForeverForgeAuctionAddon
---@field Market? ForeverForgeAuctionMarket

---@class ForeverForgeAuctionSavedDB
---@field market? table<string, ForeverForgeAuctionMarketBook>

---@type ForeverForgeAuctionAddon?
ForeverForgeAuction = nil

---@type ForeverForgeAuctionSavedDB?
ForeverForgeAuctionDB = nil

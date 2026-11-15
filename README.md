# Waylaid Crate Helper

Waylaid Crate Helper helps you compare the materials needed to fill a waylaid crate. It adds estimated bundle prices and inventory details to the crate's tooltip, making it easier to decide which materials to buy.

### [Project site](https://www.curseforge.com/wow/addons/waylaidcratehelper/)

### Features

- Shows the estimated total price of each material bundle, sorted from cheapest to most expensive.
- Shows how many required materials you have in your bags and personal bank, including the reagent bank.
- Shows the missing quantity and its estimated cost.
- Lets you configure the inventory details displayed in the tooltip.
- Includes an example tooltip in the settings with sample prices and inventory.

### Usage

Hover over a supported waylaid crate to compare its material bundles. Each material's price is for the full quantity required by the crate. If enabled, the indented lines show what you own and what you still need.

Prices come from [ForeverForge Auction](https://www.curseforge.com/wow/addons/foreverforge-auction) (lowest buyout) when available, falling back to [TradeSkillMaster](https://www.curseforge.com/wow/addons/tradeskillmaster) or [Auctionator](https://www.curseforge.com/wow/addons/auctionator). If no price is available, the tooltip displays "Unavailable".

The addon counts the character's bags, personal bank, and reagent bank, but not the account bank. It does not modify tooltips during combat.

### Settings

Open **Options > AddOns > Waylaid Crate Helper** to configure:

- **Show owned materials**: Display the amount in your bags and bank.
- **Show missing materials**: Display the quantity still needed.
- **Show missing materials cost**: Include the estimated cost of the missing quantity.
- **Currency format**: Show prices with coin icons or colored, localized denomination text.
- **Show owned amount when none are owned**: Display the owned line even when its amount is zero.
- **Show missing amount when none are owned**: Display the missing line when you own none of the material.

The missing line is not shown when you already have enough materials. The settings preview uses example data, not your actual inventory or auction prices.

### Issues & Suggestions

Visit [GitHub Issues](https://github.com/peti446/WaylaidCrateHelper/issues) to report problems or share suggestions.

### Support

[![Support me on Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/geloch)

local _, ns = ...

-- Each crate can be filled with any one of its listed bundles.
-- Usage: ns.CrateInfoDB[crateItemID][materialItemID] = requiredAmount
-- Sources:
-- https://www.wowhead.com/forever/search?q=Waylaid+Crate
-- https://foreverdiff.com/waylaid-crates/
-- https://db.icy-veins.com/wow-forever/items/consumable/other/?f_name=Waylaid+Crate
ns.CrateInfoDB = {
    -- Apprentice
    [248682] = { -- Herbs
        [2447] = 20, -- Peacebloom
        [765] = 20, -- Silverleaf
        [2449] = 10, -- Earthroot
        [785] = 10, -- Mageroyal
        [2450] = 10, -- Briarthorn
    },
    [248683] = { -- Ore
        [2770] = 20, -- Copper Ore
        [2771] = 20, -- Tin Ore
    },
    [248684] = { -- Textiles
        [2589] = 40, -- Linen Cloth
        [2318] = 20, -- Light Leather
    },
    [248685] = { -- Curiosities
        [10940] = 20, -- Strange Dust
        [10939] = 4, -- Greater Magic Essence
        [10978] = 6, -- Small Glimmering Shard
        [11084] = 2, -- Large Glimmering Shard
    },
    [248702] = { -- Fabrics
        [4231] = 2, -- Cured Light Hide
        [2996] = 20, -- Bolt of Linen Cloth
    },
    [248703] = { -- Ingots
        [2840] = 20, -- Copper Bar
        [3576] = 20, -- Tin Bar
        [2841] = 10, -- Bronze Bar
    },
    [248704] = { -- Parts
        [4359] = 16, -- Handful of Copper Bolts
        [4361] = 16, -- Copper Tube
        [4363] = 4, -- Copper Modulator
    },

    -- Journeyman
    [248686] = { -- Herbs
        [3820] = 10, -- Stranglekelp
        [2453] = 10, -- Bruiseweed
        [3355] = 10, -- Wild Steelbloom
        [3369] = 10, -- Grave Moss
        [3356] = 10, -- Kingsblood
    },
    [248687] = { -- Ore
        [2775] = 10, -- Silver Ore
        [2772] = 20, -- Iron Ore
    },
    [248688] = { -- Textiles
        [2592] = 20, -- Wool Cloth
        [4306] = 40, -- Silk Cloth
        [2319] = 20, -- Medium Leather
    },
    [248689] = { -- Curiosities
        [11083] = 20, -- Soul Dust
        [11082] = 4, -- Greater Astral Essence
        [11138] = 6, -- Small Glowing Shard
        [11139] = 2, -- Large Glowing Shard
    },
    [248705] = { -- Fabrics
        [2997] = 6, -- Bolt of Woolen Cloth
        [4305] = 10, -- Bolt of Silk Cloth
        [4233] = 2, -- Cured Medium Hide
    },
    [248706] = { -- Ingots
        [2842] = 10, -- Silver Bar
        [3575] = 20, -- Iron Bar
    },
    [248707] = { -- Parts
        [4371] = 8, -- Bronze Tube
        [4375] = 7, -- Whirring Bronze Gizmo
        [4382] = 4, -- Bronze Framework
        [10558] = 45, -- Gold Power Core
    },

    -- Expert
    [248690] = { -- Earthly Herbs
        [3357] = 20, -- Liferoot
        [3818] = 10, -- Fadeleaf
        [3821] = 10, -- Goldthorn
        [3358] = 10, -- Khadgar's Whisker
    },
    [248691] = { -- Flowering Herbs
        [3819] = 10, -- Wintersbite
        [4625] = 10, -- Firebloom
        [8831] = 20, -- Purple Lotus
        [8836] = 10, -- Arthas' Tears
    },
    [248692] = { -- Ore
        [2776] = 10, -- Gold Ore
        [3858] = 20, -- Mithril Ore
    },
    [248693] = { -- Textiles
        [4338] = 40, -- Mageweave Cloth
        [4234] = 20, -- Heavy Leather
    },
    [248694] = { -- Curiosities
        [11137] = 20, -- Vision Dust
        [11135] = 4, -- Greater Mystic Essence
        [11177] = 6, -- Small Radiant Shard
        [11178] = 2, -- Large Radiant Shard
    },
    [248708] = { -- Fabrics
        [4339] = 8, -- Bolt of Mageweave
        [4236] = 2, -- Cured Heavy Hide
    },
    [248709] = { -- Ingots
        [3860] = 20, -- Mithril Bar
        [3859] = 15, -- Steel Bar
        [3577] = 10, -- Gold Bar
    },
    [248710] = { -- Parts
        [4387] = 8, -- Iron Strut
        [10559] = 5, -- Mithril Tube
        [10560] = 12, -- Unstable Trigger
        [10561] = 5, -- Mithril Casing
    },

    -- Artisan
    [248695] = { -- Earthly Herbs
        [13464] = 10, -- Golden Sansam
        [8838] = 20, -- Sungrass
        [8839] = 10, -- Blindweed
        [8845] = 10, -- Ghost Mushroom
        [8846] = 10, -- Gromsblood
    },
    [248696] = { -- Flowering Herbs
        [13463] = 20, -- Dreamfoil
        [13465] = 20, -- Mountain Silversage
        [13466] = 20, -- Plaguebloom
        [13467] = 20, -- Icecap
    },
    [248697] = { -- Ore
        [7911] = 10, -- Truesilver Ore
        [10620] = 20, -- Thorium Ore
        [11370] = 20, -- Dark Iron Ore
    },
    [248698] = { -- Textiles
        [14047] = 40, -- Runecloth
        [4304] = 20, -- Thick Leather
        [8170] = 20, -- Rugged Leather
    },
    [248699] = { -- Curiosities
        [11176] = 20, -- Dream Dust
        [11175] = 4, -- Greater Nether Essence
        [14343] = 6, -- Small Brilliant Shard
        [14344] = 2, -- Large Brilliant Shard
    },
    [248711] = { -- Fabrics
        [14048] = 8, -- Bolt of Runecloth
        [8172] = 2, -- Cured Thick Hide
    },
    [248712] = { -- Ingots
        [11371] = 2, -- Dark Iron Bar
        [6037] = 10, -- Truesilver Bar
        [12359] = 20, -- Thorium Bar
    },
    [248713] = { -- Parts
        [15994] = 5, -- Thorium Widget
        [18631] = 5, -- Truesilver Transformer
        [16000] = 2, -- Thorium Tube
    },
}

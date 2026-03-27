return {
    Debug = false,

    Framework = "Qbox", -- Qbox | QB | ESX | Mythic | Custom
    Target = "ox_target", -- ox_target | sleepless_interact | mythic-targeting | custom
    Progress = "ox_lib_bar", -- ox_lib_bar | ox_lib_circle | mythic
    ProgressAnims = {
        registerSmash = {
            dict = "missheist_jewel",
            clip = "smash_case",
            flag = 49
        },
        searchBox = {
            dict = "amb@prop_human_bum_bin@idle_b",
            clip = "idle_d",
            flag = 49
        }
    },
    Notifications = "ox_lib", -- gta | ox_lib | qb | esx | mythic | okok | sd-notify | wasabi_notify | custom
    Dispatch = "ps-dispatch", -- cd_dispatch | qs-dispatch | ps-dispatch | rcore_dispatch | mythic-mdt | custom
    DispatchJobs = { "police", "sheriff" },

    RequiredWeapon = `WEAPON_BAT`,
    PedWitnessRadius = 18.0,
    PoliceChanceIfWitness = 50,
    RequiredPolice = 0,

    RegisterSmashTime = 7000,
    ShoeboxSearchTime = 5000,

    RegisterCooldown = 45 * 60, -- seconds
    ShopRobberyCooldown = 60 * 60, -- once per shop per hour
    PlayerAccessWindow = 20 * 60, -- seconds after smashing register

    RegisterCash = {
        min = 350,
        max = 950,
        account = "cash" -- cash | bank | money
    },

    ShoeLootItem = "shoebox",
    ShoeLoot = {
        { chance = 10, type = "rare", amount = 1, value = { min = 1800, max = 3200 }, metadata = { label = "Nike Air Yeezy 2 Red October", description = "Rare collectible sneakers." } },
        { chance = 20, type = "mid", amount = 1, value = { min = 700, max = 1400 }, metadata = { label = "Jordan 4 Retro", description = "Popular sneaker pair in good condition." } },
        { chance = 40, type = "low", amount = 1, value = { min = 250, max = 650 }, metadata = { label = "Basic Skate Shoes", description = "Common shoes with low resale value." } },
        { chance = 30, type = "empty", amount = 0, value = { min = 0, max = 0 }, metadata = { label = "Empty Shoe Box", description = "Nothing useful inside." } }
    },

    Stores = {
        {
            id = "binco_1",
            label = "Binco Vespucci",
            register = vec3(427.09, -807.45, 29.49),
            shoeboxes = {
                vec3(420.86, -800.15, 29.49),
                vec3(423.64, -803.23, 29.49),
                vec3(426.20, -804.16, 29.49),
            }
        }
    }
}

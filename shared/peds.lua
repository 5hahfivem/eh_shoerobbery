---@diagnostic disable: missing-fields, undefined-doc-name
local Config = require("shared.config")

--- @class PedConfig
--- @field resource string
--- @field id? any
--- @field ped? number
--- @field model string
--- @field coords vector4 | vector4[]
--- @field scenario? string
--- @field animation? {dict: string, anim: string, flag?: number}
--- @field prop? {propModel: string | number, bone: string | number, rot?: vector3, pos?: vector3, entity?: number}
--- @field renderDistance number
--- @field targetOptions OxTargetOption[]
--- @field interactOptions? LocalEntityData
--- @field onSpawn? function
--- @field onDespawn? function

---@type PedConfig[]
local Peds = {
    {
        id = "shoe_buyback",
        model = Config.SellShop.ped.model,
        coords = Config.SellShop.ped.coords,
        renderDistance = Config.SellShop.ped.renderDistance,
        scenario = Config.SellShop.ped.scenario,
        targetOptions = {
            {
                icon = "fas fa-money-bill-alt",
                label = "Sell Shoe Boxes",
                serverEvent = "eh_shoerobbery:server:openSellShop"
            },
        },
        interactOptions = {
            {
                label = "Sell Shoe Boxes",
                icon = "money-bill",
                onSelect = function()
                    TriggerServerEvent("eh_shoerobbery:server:openSellShop")
                end,
            },
        },
    },
}

return Peds

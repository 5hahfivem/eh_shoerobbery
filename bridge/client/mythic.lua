local Config = require("shared.config")

if Config.Framework ~= "Mythic" then return end

local function retrieveComponents()
    Targeting = exports["mythic-base"]:FetchComponent("Targeting")
    Progress = exports["mythic-base"]:FetchComponent("Progress")
    Notification = exports["mythic-base"]:FetchComponent("Notification")
    Inventory = exports["mythic-base"]:FetchComponent("Inventory")
end

AddEventHandler("eh_shoerobbery:Shared:DependencyUpdate", retrieveComponents)

AddEventHandler("Core:Shared:Ready", function()
    exports["mythic-base"]:RequestDependencies("eh_shoerobbery", {
        "Targeting",
        "Progress",
        "Notification",
        "Inventory"
    }, function(errors)
        if #errors > 0 then return end
        retrieveComponents()
    end)
end)

---@param ped? integer
---@return boolean
function IsDead(ped)
    return LocalPlayer.state.isDead or false
end

---@param item string
---@param amount? number
---@return boolean
function HasItem(item, amount)
    amount = amount or 1
    if not Inventory then return false end
    return Inventory.Check.Player:HasItem(item, amount)
end

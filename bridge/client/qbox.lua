local Config = require("shared.config")

if Config.Framework ~= "Qbox" then return end

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
    if GetResourceState("ox_inventory") ~= "started" then
        return false
    end

    return exports.ox_inventory:Search("count", item) >= amount
end

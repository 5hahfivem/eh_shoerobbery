local Config = require("shared.config")

if Config.Framework ~= "QB" then return end

---@param ped? integer
---@return boolean
function IsDead(ped)
    if not QBCore then return false end
    local pdata = QBCore.Functions.GetPlayerData()
    return pdata.metadata and (pdata.metadata.isdead or pdata.metadata.inlaststand) or false
end

---@param item string
---@param amount? number
---@return boolean
function HasItem(item, amount)
    amount = amount or 1

    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:Search("count", item) >= amount
    elseif QBCore then
        return QBCore.Functions.HasItem(item, amount)
    end

    return false
end

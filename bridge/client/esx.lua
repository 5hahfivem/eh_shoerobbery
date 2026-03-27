local Config = require("shared.config")

if Config.Framework ~= "ESX" then return end

local isDead = false

AddEventHandler("esx:onPlayerDeath", function()
    isDead = true
end)

RegisterNetEvent("esx:onPlayerSpawn", function()
    isDead = false
end)

---@param ped? integer
---@return boolean
function IsDead(ped)
    return isDead
end

---@param item string
---@param amount? number
---@return boolean
function HasItem(item, amount)
    amount = amount or 1

    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:Search("count", item) >= amount
    elseif ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer and xPlayer.inventory then
            for _, invItem in pairs(xPlayer.inventory) do
                if invItem.name == item and invItem.count >= amount then
                    return true
                end
            end
        end
    end

    return false
end

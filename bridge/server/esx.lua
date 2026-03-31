local Config = require("shared.config")

if Config.Framework ~= "ESX" then return end

function GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function AddMoney(source, amount, account, reason)
    local player = GetPlayer(source)
    if not player then return false end
    if account == "cash" then account = "money" end
    player.addAccountMoney(account or "money", math.floor(amount), reason or "shoe_robbery")
    return true
end

function GiveItem(source, item, amount, metadata)
    amount = amount or 1
    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:AddItem(source, item, amount, metadata or {})
    end

    local player = GetPlayer(source)
    if not player then return false end
    player.addInventoryItem(item, amount)
    return true
end

function GetItemCount(source, item)
    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:GetItemCount(source, item) or 0
    end

    local player = GetPlayer(source)
    if not player or not player.getInventoryItem then return 0 end
    local invItem = player.getInventoryItem(item)
    return (invItem and invItem.count) or 0
end

function RemoveItem(source, item, amount)
    amount = amount or 1
    if amount <= 0 then return false end

    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:RemoveItem(source, item, amount)
    end

    local player = GetPlayer(source)
    if not player or not player.removeInventoryItem then return false end
    player.removeInventoryItem(item, amount)
    return true
end

function GetPoliceCount()
    local players = ESX.GetPlayers()
    local count = 0
    for _, playerId in pairs(players) do
        local player = ESX.GetPlayerFromId(playerId)
        for i = 1, #Config.DispatchJobs do
            if player and player.job and player.job.name == Config.DispatchJobs[i] then
                count += 1
                break
            end
        end
    end
    return count
end

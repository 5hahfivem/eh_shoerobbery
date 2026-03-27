local Config = require("shared.config")

if Config.Framework ~= "QB" then return end

function GetPlayer(source)
    return QBCore and QBCore.Functions.GetPlayer(source)
end

function AddMoney(source, amount, account, reason)
    local player = GetPlayer(source)
    if not player then return false end
    if account == "money" then account = "cash" end
    player.Functions.AddMoney(account or "cash", math.floor(amount), reason or "shoe_robbery")
    return true
end

function GiveItem(source, item, amount, metadata)
    amount = amount or 1
    if GetResourceState("ox_inventory") == "started" then
        local success = exports.ox_inventory:AddItem(source, item, amount, metadata or {})
        return success and true or false
    end

    if GetResourceState("qb-inventory") == "started" then
        return exports["qb-inventory"]:AddItem(source, item, amount, false, metadata or {})
    end

    return false
end

function GetPoliceCount()
    if not QBCore then return 0 end
    local players = QBCore.Functions.GetPlayers()
    local count = 0
    for _, playerId in pairs(players) do
        local player = QBCore.Functions.GetPlayer(playerId)
        for i = 1, #Config.DispatchJobs do
            if player and player.PlayerData.job and player.PlayerData.job.name == Config.DispatchJobs[i] and player.PlayerData.job.onduty then
                count += 1
                break
            end
        end
    end
    return count
end

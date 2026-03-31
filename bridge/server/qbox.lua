local Config = require("shared.config")

if Config.Framework ~= "Qbox" then return end

function GetPlayer(source)
    return exports.qbx_core:GetPlayer(source)
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
    if GetResourceState("ox_inventory") ~= "started" then return false end
    local success = exports.ox_inventory:AddItem(source, item, amount, metadata or {})
    return success and true or false
end

function GetItemCount(source, item)
    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:GetItemCount(source, item) or 0
    end

    local player = GetPlayer(source)
    if not player or not player.Functions or not player.Functions.GetItemByName then return 0 end
    local invItem = player.Functions.GetItemByName(item)
    return (invItem and invItem.amount) or 0
end

function RemoveItem(source, item, amount)
    amount = amount or 1
    if amount <= 0 then return false end

    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:RemoveItem(source, item, amount)
    end

    local player = GetPlayer(source)
    if not player or not player.Functions or not player.Functions.RemoveItem then return false end
    return player.Functions.RemoveItem(item, amount)
end

function GetPoliceCount()
    local count = exports.qbx_core:GetDutyCountType("leo")
    return count or 0
end

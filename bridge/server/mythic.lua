local Config = require("shared.config")

if Config.Framework ~= "Mythic" then return end

local Fetch, Inventory, Wallet, Banking, Jobs

local function retrieveComponents()
    Fetch = exports["mythic-base"]:FetchComponent("Fetch")
    Inventory = exports["mythic-base"]:FetchComponent("Inventory")
    Wallet = exports["mythic-base"]:FetchComponent("Wallet")
    Banking = exports["mythic-base"]:FetchComponent("Banking")
    Jobs = exports["mythic-base"]:FetchComponent("Jobs")
end

AddEventHandler("eh_shoerobbery:Shared:DependencyUpdate", retrieveComponents)

AddEventHandler("Core:Shared:Ready", function()
    exports["mythic-base"]:RequestDependencies("eh_shoerobbery", {
        "Fetch",
        "Inventory",
        "Wallet",
        "Banking",
        "Jobs",
    }, function(errors)
        if #errors > 0 then return end
        retrieveComponents()
    end)
end)

local function getCharacterFromSource(source)
    if not Fetch then return nil end
    local player = Fetch:Source(source)
    if not player then return nil end
    return player:GetData("Character")
end

local function getCharacterSid(source)
    local char = getCharacterFromSource(source)
    if not char then return nil end
    return char:GetData("SID")
end

function AddMoney(source, amount, account, reason)
    amount = math.floor(amount or 0)
    if amount <= 0 then return false end

    account = account or "cash"
    if account == "money" then
        account = "cash"
    end

    if account == "cash" then
        return Wallet:Modify(source, amount) or false
    end

    if Banking then
        local char = getCharacterFromSource(source)
        local accountId = char and char:GetData("BankAccount")
        if accountId then
            if Banking.Balance.Add then
                return Banking.Balance:Add(accountId, amount, {
                    type = "paycheck",
                    title = reason or "shoe_robbery",
                    description = reason or "shoe_robbery",
                    data = {},
                })
            elseif Banking.Balance.Deposit then
                return Banking.Balance:Deposit(accountId, amount, reason or "shoe_robbery")
            end
        end
    end

    return Wallet:Modify(source, amount) or false
end

function GiveItem(source, item, amount, metadata)
    local sid = getCharacterSid(source)
    if not sid or not Inventory then return false end
    return Inventory:AddItem(sid, item, amount or 1, metadata or {}, 1)
end

function GetItemCount(source, item)
    local sid = getCharacterSid(source)
    if not sid or not Inventory then return 0 end
    return Inventory.Items:GetCount(sid, 1, item) or 0
end

function RemoveItem(source, item, amount)
    local sid = getCharacterSid(source)
    if not sid or not Inventory then return false end
    return Inventory.Items:Remove(sid, 1, item, amount or 1, false) or false
end

function GetPoliceCount()
    return Jobs.Duty:GetCount("police") or 0
end

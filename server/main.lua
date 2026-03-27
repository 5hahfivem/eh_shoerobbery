local Config = require("shared.config")

local storeState = {}
local playerAccess = {}

GlobalState["eh_shoerobbery:active"] = true
GlobalState["eh_shoerobbery:cooldown"] = false

local function getNow()
    return os.time()
end

---@param source number
---@return vector3|nil
local function getPlayerCoords(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return nil end
    return GetEntityCoords(ped)
end

---@param source number
---@param target vector3
---@param maxDistance number
---@return boolean
local function isPlayerNear(source, target, maxDistance)
    local playerCoords = getPlayerCoords(source)
    if not playerCoords then return false end
    return #(playerCoords - target) <= maxDistance
end

---@param storeIndex any
---@return number|nil, table|nil
local function getStore(storeIndex)
    if type(storeIndex) ~= "number" then return nil, nil end
    if storeIndex < 1 then return nil, nil end
    local store = Config.Stores[storeIndex]
    if not store then return nil, nil end
    return storeIndex, store
end

---@param store any
---@param boxIndex any
---@return number|nil
local function getBoxIndex(store, boxIndex)
    if type(boxIndex) ~= "number" then return nil end
    if boxIndex < 1 then return nil end
    if not store.shoeboxes[boxIndex] then return nil end
    return boxIndex
end

local function ensureStoreState(storeIndex)
    if not storeState[storeIndex] then
        local boxes = {}
        local count = #Config.Stores[storeIndex].shoeboxes
        for i = 1, count do
            boxes[i] = false
        end

        storeState[storeIndex] = {
            registerResetAt = 0,
            shopNextRobAt = 0,
            boxes = boxes
        }
    end

    return storeState[storeIndex]
end

local function updateStoreGlobalState(storeIndex)
    local state = ensureStoreState(storeIndex)
    GlobalState[("eh_shoerobbery:store:%s"):format(storeIndex)] = {
        registerResetAt = state.registerResetAt,
        shopNextRobAt = state.shopNextRobAt
    }
end

local function hasPlayerAccess(source, storeIndex)
    local playerStores = playerAccess[source]
    if not playerStores then return false end

    local expires = playerStores[storeIndex]
    if not expires then return false end

    if getNow() > expires then
        playerStores[storeIndex] = nil
        return false
    end

    return true
end

local function notify(source, key, nType, ...)
    TriggerClientEvent("eh_shoerobbery:client:notify", source, T(key, ...), nType)
end

local function resetStoreIfNeeded(storeIndex)
    local state = ensureStoreState(storeIndex)
    if state.registerResetAt > 0 and getNow() >= state.registerResetAt then
        state.registerResetAt = 0
        for i = 1, #state.boxes do
            state.boxes[i] = false
        end
        updateStoreGlobalState(storeIndex)
    end
end

local function rollLoot()
    local max = 0
    for i = 1, #Config.ShoeLoot do
        max += Config.ShoeLoot[i].chance
    end

    local roll = math.random(1, max)
    local current = 0
    for i = 1, #Config.ShoeLoot do
        current += Config.ShoeLoot[i].chance
        if roll <= current then
            return Config.ShoeLoot[i]
        end
    end

    return Config.ShoeLoot[#Config.ShoeLoot]
end

lib.callback.register("eh_shoerobbery:server:canRobRegister", function(source, storeIndex)
    local parsedStoreIndex = getStore(storeIndex)
    if not parsedStoreIndex then return false end

    resetStoreIfNeeded(parsedStoreIndex)
    local state = ensureStoreState(parsedStoreIndex)

    if state.registerResetAt > getNow() then
        notify(source, "error.register_on_cooldown", "error")
        return false
    end

    if state.shopNextRobAt > getNow() then
        local minutesLeft = math.max(1, math.ceil((state.shopNextRobAt - getNow()) / 60))
        notify(source, "error.shop_on_cooldown", "error", minutesLeft)
        return false
    end

    if GetPoliceCount() < Config.RequiredPolice then
        notify(source, "error.not_enough_police", "error", Config.RequiredPolice)
        return false
    end

    return true
end)

RegisterNetEvent("eh_shoerobbery:server:registerSmashed", function(storeIndex)
    local src = source
    local parsedStoreIndex, store = getStore(storeIndex)
    if not parsedStoreIndex then return end
    local registerCoords = store and store.register
    if not registerCoords then return end
    if not isPlayerNear(src, registerCoords, 4.0) then return end

    resetStoreIfNeeded(parsedStoreIndex)
    local state = ensureStoreState(parsedStoreIndex)

    if state.registerResetAt > getNow() then
        notify(src, "error.register_on_cooldown", "error")
        return
    end

    if state.shopNextRobAt > getNow() then
        local minutesLeft = math.max(1, math.ceil((state.shopNextRobAt - getNow()) / 60))
        notify(src, "error.shop_on_cooldown", "error", minutesLeft)
        return
    end

    if GetPoliceCount() < Config.RequiredPolice then
        notify(src, "error.not_enough_police", "error", Config.RequiredPolice)
        return
    end

    state.registerResetAt = getNow() + Config.RegisterCooldown
    state.shopNextRobAt = getNow() + Config.ShopRobberyCooldown
    for i = 1, #state.boxes do
        state.boxes[i] = false
    end
    updateStoreGlobalState(parsedStoreIndex)

    playerAccess[src] = playerAccess[src] or {}
    playerAccess[src][parsedStoreIndex] = getNow() + Config.PlayerAccessWindow

    local cash = math.random(Config.RegisterCash.min, Config.RegisterCash.max)
    AddMoney(src, cash, Config.RegisterCash.account, "register_smash")
    notify(src, "success.register_cash", "success", cash)
end)

lib.callback.register("eh_shoerobbery:server:canSearchBox", function(source, storeIndex, boxIndex)
    local parsedStoreIndex, store = getStore(storeIndex)
    if not parsedStoreIndex then return false end
    local parsedBoxIndex = getBoxIndex(store, boxIndex)
    if not parsedBoxIndex then return false end

    resetStoreIfNeeded(parsedStoreIndex)
    local state = ensureStoreState(parsedStoreIndex)

    if state.registerResetAt <= getNow() then
        notify(source, "error.smash_register_first", "error")
        return false
    end

    if state.boxes[parsedBoxIndex] then
        notify(source, "error.box_already_searched", "error")
        return false
    end

    if not hasPlayerAccess(source, parsedStoreIndex) then
        notify(source, "error.no_access", "error")
        return false
    end

    return true
end)

RegisterNetEvent("eh_shoerobbery:server:searchBox", function(storeIndex, boxIndex)
    local src = source
    local parsedStoreIndex, store = getStore(storeIndex)
    if not parsedStoreIndex then return end
    local shoeboxes = store and store.shoeboxes
    if not shoeboxes then return end
    local parsedBoxIndex = getBoxIndex(store, boxIndex)
    if not parsedBoxIndex then return end
    local boxCoords = shoeboxes[parsedBoxIndex]
    if not boxCoords then return end
    if not isPlayerNear(src, boxCoords, 3.0) then return end

    resetStoreIfNeeded(parsedStoreIndex)
    local state = ensureStoreState(parsedStoreIndex)

    if state.registerResetAt <= getNow() or state.boxes[parsedBoxIndex] or not hasPlayerAccess(src, parsedStoreIndex) then
        notify(src, "error.invalid_search", "error")
        return
    end

    state.boxes[parsedBoxIndex] = true
    local loot = rollLoot()

    if loot.amount <= 0 then
        notify(src, "inform.empty_box", "inform")
        return
    end

    local value = math.random(loot.value.min, loot.value.max)
    local metadata = {
        label = loot.metadata.label,
        description = loot.metadata.description,
        tier = loot.type,
        value = value
    }

    local given = GiveItem(src, Config.ShoeLootItem, loot.amount, metadata)
    if not given then
        notify(src, "error.item_failed", "error")
        return
    end

    notify(src, "success.box_loot", "success", metadata.label, value)
end)

AddEventHandler("playerDropped", function()
    playerAccess[source] = nil
end)

local eh
eh = AddEventHandler("onResourceStart", function(resource)
    if resource ~= GetCurrentResourceName() then return end

    lib.versionCheck("5hahfivem/eh_shoerobbery")

    for storeIndex = 1, #Config.Stores do
        updateStoreGlobalState(storeIndex)
    end
    RemoveEventHandler(eh)
end)

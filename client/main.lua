local Config = require("shared.config")

local busy = false
local zones = {}
local activeInteractions = {}
local hasBat = false
local insideRegisterZone = {}

if not IsDead then
    function IsDead(ped)
        return false
    end
end

local function hasPedWitnessNearby(coords)
    local peds = GetGamePool("CPed")
    for i = 1, #peds do
        local ped = peds[i]
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
            if #(GetEntityCoords(ped) - coords) <= Config.PedWitnessRadius then
                return true
            end
        end
    end
    return false
end

local function canTriggerDispatch(coords)
    if not hasPedWitnessNearby(coords) then
        return false
    end

    return math.random(1, 100) <= Config.PoliceChanceIfWitness
end

local function getNow()
    local now = GetCloudTimeAsInt()
    if now and now > 0 then
        return now
    end
    return 0
end

local function getProgressAnim(key)
    if not Config.ProgressAnims then return nil end
    return Config.ProgressAnims[key]
end

local function smashRegister(storeIndex)
    if busy or IsDead(cache.ped) then return end

    local canRob = lib.callback.await("eh_shoerobbery:server:canRobRegister", false, storeIndex)
    if not canRob then return end
    if not hasBat then
        Notify(T("error.need_bat"), "error")
        return
    end

    busy = true

    ProgressBar({
        duration = Config.RegisterSmashTime,
        label = T("progress.smashing_register"),
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = getProgressAnim("registerSmash")
    }, function()
        local store = Config.Stores[storeIndex]
        if canTriggerDispatch(store.register) then
            RobberyAlert(store.register)
        end

        TriggerServerEvent("eh_shoerobbery:server:registerSmashed", storeIndex)
        busy = false
    end, function()
        busy = false
        Notify(T("error.cancelled"), "error")
    end)
end

local function searchShoeBox(storeIndex, boxIndex)
    if busy or IsDead(cache.ped) then return end

    local canSearch = lib.callback.await("eh_shoerobbery:server:canSearchBox", false, storeIndex, boxIndex)
    if not canSearch then return end

    busy = true

    ProgressBar({
        duration = Config.ShoeboxSearchTime,
        label = T("progress.searching_box"),
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = getProgressAnim("searchBox")
    }, function()
        TriggerServerEvent("eh_shoerobbery:server:searchBox", storeIndex, boxIndex)
        busy = false
    end, function()
        busy = false
        Notify(T("error.cancelled"), "error")
    end)
end

local function getRegisterZoneKey(storeIndex)
    return ("register_%s"):format(storeIndex)
end

local function getBoxZoneKey(storeIndex, boxIndex)
    return ("box_%s_%s"):format(storeIndex, boxIndex)
end


local function addRegisterInteraction(storeIndex)
    local key = getRegisterZoneKey(storeIndex)
    if activeInteractions[key] then return end
    if not hasBat then return end

    local store = Config.Stores[storeIndex]
    local till = GetClosestObjectOfType(store.register.x, store.register.y, store.register.z, 5.0, `prop_till_01`, false, false, false)
    local interactionCoords = store.register
    if till and till ~= 0 and DoesEntityExist(till) then
        interactionCoords = GetOffsetFromEntityInWorldCoords(till, 0.0, 0.0, -0.12)
    end

    activeInteractions[key] = AddInteractionZone({
        name = key,
        coords = interactionCoords,
        radius = 1.8,
        icon = "fa-solid fa-hammer",
        label = T("help.smash_register"),
        canInteract = function()
            local storeState = GlobalState[("eh_shoerobbery:store:%s"):format(storeIndex)]
            local now = getNow()
            local active = GlobalState["eh_shoerobbery:active"]
            local cooldown = GlobalState["eh_shoerobbery:cooldown"]
            local shopLocked = storeState and storeState.shopNextRobAt and storeState.shopNextRobAt > now

            return active and not cooldown and not shopLocked and hasBat and not busy and not IsDead(cache.ped)
        end,
        onSelect = function()
            smashRegister(storeIndex)
        end
    })
end

local function addBoxInteraction(storeIndex, boxIndex)
    local key = getBoxZoneKey(storeIndex, boxIndex)
    if activeInteractions[key] then return end

    local store = Config.Stores[storeIndex]
    activeInteractions[key] = AddInteractionZone({
        name = key,
        coords = store.shoeboxes[boxIndex],
        radius = 1.4,
        icon = "fa-solid fa-box-open",
        label = T("help.search_box"),
        canInteract = function()
            return GlobalState["eh_shoerobbery:active"] and not GlobalState["eh_shoerobbery:cooldown"] and not busy and not IsDead(cache.ped)
        end,
        onSelect = function()
            searchShoeBox(storeIndex, boxIndex)
        end
    })
end

local function removeInteraction(key)
    if not activeInteractions[key] then return end
    RemoveInteractionZone(activeInteractions[key])
    activeInteractions[key] = nil
end

local function createStoreZones(storeIndex, store)
    local registerKey = getRegisterZoneKey(storeIndex)
    zones[registerKey] = lib.zones.sphere({
        coords = store.register,
        radius = 3.0,
        debug = false,
        onEnter = function()
            insideRegisterZone[storeIndex] = true
            addRegisterInteraction(storeIndex)
        end,
        onExit = function()
            insideRegisterZone[storeIndex] = nil
            removeInteraction(registerKey)
        end
    })

    for boxIndex, boxCoords in ipairs(store.shoeboxes) do
        local boxKey = getBoxZoneKey(storeIndex, boxIndex)
        zones[boxKey] = lib.zones.sphere({
            coords = boxCoords,
            radius = 2.0,
            debug = false,
            onEnter = function()
                addBoxInteraction(storeIndex, boxIndex)
            end,
            onExit = function()
                removeInteraction(boxKey)
            end
        })
    end
end

CreateThread(function()
    for storeIndex, store in ipairs(Config.Stores) do
        createStoreZones(storeIndex, store)
    end
end)

lib.onCache("weapon", function(weapon)
    hasBat = weapon == Config.RequiredWeapon

    for storeIndex = 1, #Config.Stores do
        if insideRegisterZone[storeIndex] then
            local key = getRegisterZoneKey(storeIndex)
            if hasBat then
                addRegisterInteraction(storeIndex)
            else
                removeInteraction(key)
            end
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for key, zoneId in pairs(activeInteractions) do
        RemoveInteractionZone(zoneId)
        activeInteractions[key] = nil
    end
    for key, zone in pairs(zones) do
        if zone and zone.remove then
            zone:remove()
        end
    end
    zones = {}

end)

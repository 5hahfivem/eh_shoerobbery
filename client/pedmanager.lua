-- Credit: adapted from sleepless_pedmanager by @SleeplessDevelopments
local Peds = require("shared.peds")
local pedZoneIds = {}

local function runPedOption(option, ped)
    if option.onSelect then
        option.onSelect({ entity = ped })
        return
    end

    if option.serverEvent then
        TriggerServerEvent(option.serverEvent, option.args)
        return
    end

    if option.event then
        TriggerEvent(option.event, option.args)
        return
    end

    if option.command then
        ExecuteCommand(option.command)
    end
end

local function addPedInteractionZones(data, pedData, currentPed)
    local options = pedData.targetOptions or pedData.interactOptions
    if not options then return end

    pedZoneIds[data] = pedZoneIds[data] or {}
    local zoneIds = pedZoneIds[data]

    for index = 1, #options do
        local option = options[index]
        local zoneId = AddInteractionZone({
            name = ("%s_%s_%s"):format(data.id or "ped", currentPed, index),
            coords = pedData.coords.xyz,
            radius = option.distance or option.radius or 2.0,
            icon = option.icon or "fa-solid fa-hand",
            label = option.label or "Interact",
            canInteract = function()
                if not DoesEntityExist(currentPed) then return false end
                if option.canInteract then
                    return option.canInteract(currentPed, GetEntityCoords(PlayerPedId()), option.args)
                end
                return true
            end,
            onSelect = function()
                runPedOption(option, currentPed)
            end
        })

        if zoneId then
            zoneIds[#zoneIds + 1] = zoneId
        end
    end
end

---@param data PedConfig
local function spawnPed(data)
    if data.ped then return end

    local pedData = data
    local pedModel = data.model

    lib.requestModel(pedModel, 5000)

    local coords = pedData.coords
    data.ped = CreatePed(5, pedModel, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
    SetModelAsNoLongerNeeded(pedModel)

    lib.waitFor(function()
        return DoesEntityExist(data.ped)
    end)

    local currentPed = data.ped --[[@as number]]
    SetPedDefaultComponentVariation(currentPed)
    FreezeEntityPosition(currentPed, true)
    SetEntityInvincible(currentPed, true)
    SetBlockingOfNonTemporaryEvents(currentPed, true)
    SetPedFleeAttributes(currentPed, 0, false)

    addPedInteractionZones(data, pedData, currentPed)

    if pedData.animation then
        ClearPedTasksImmediately(currentPed)
        lib.requestAnimDict(pedData.animation.dict, 5000)
        TaskPlayAnim(currentPed, pedData.animation.dict, pedData.animation.anim, 3.0, -8.0, -1, pedData.animation.flag or 1,
            0.0, false, false, false)
        RemoveAnimDict(pedData.animation.dict)
    end

    if pedData.scenario then
        ClearPedTasksImmediately(currentPed)
        TaskStartScenarioInPlace(currentPed, pedData.scenario, 0, false)
    end

    local propData = pedData.prop
    if propData then
        if type(propData.propModel) == "string" then
            propData.propModel = joaat(propData.propModel)
        end
        lib.requestModel(propData.propModel, 5000)

        local prop = CreateObject(propData.propModel, coords.x, coords.y, coords.z, false, false, false)
        pedData.prop.entity = prop
        SetModelAsNoLongerNeeded(propData.propModel)

        local bone = propData.bone
        if type(bone) == "string" then
            local boneName = bone --[[@as string]]
            bone = GetEntityBoneIndexByName(currentPed, boneName)
            pedData.prop.bone = bone
        end

        local pos = propData.pos or vec3(0.0, 0.0, 0.0)
        local rot = propData.rot or vec3(0.0, 0.0, 0.0)
        AttachEntityToEntity(
            prop,
            currentPed,
            GetPedBoneIndex(currentPed, bone or 28422),
            pos.x,
            pos.y,
            pos.z,
            rot.x,
            rot.y,
            rot.z,
            true,
            true,
            false,
            true,
            0,
            true
        )
    end

    if pedData.onSpawn then
        pedData.onSpawn(data.ped)
    end
end

---@param data PedConfig
local function dismissPed(data)
    if data.onDespawn then
        data.onDespawn(data.ped)
    end

    if data.prop and data.prop.entity then
        DeleteEntity(data.prop.entity)
        data.prop.entity = nil
    end

    if data.ped and DoesEntityExist(data.ped) then
        local zoneIds = pedZoneIds[data]
        if zoneIds then
            for i = 1, #zoneIds do
                RemoveInteractionZone(zoneIds[i])
            end
            pedZoneIds[data] = nil
        end
        DeleteEntity(data.ped)
    end

    data.ped = nil
end

---@param data PedConfig
local function addPed(data)
    data.resource = GetInvokingResource() or GetCurrentResourceName()

    local dataType = type(data.coords)
    assert(dataType == "vector4" or dataType == "table",
        "pedmanager expected a vector4 or array of vector4s, but got " .. dataType)

    if dataType == "vector4" then
        data.coords = { data.coords }
    end

    local points = {}
    for i = 1, #data.coords do
        local pedData = lib.table.clone(data)
        pedData.coords = data.coords[i] --[[@as vector4]]

        assert(type(pedData.coords) == "vector4", "pedmanager expected a vector4, but got " .. type(pedData.coords))

        local point = lib.points.new({
            coords = pedData.coords.xyz,
            distance = pedData.renderDistance,
        })

        function point:onEnter()
            spawnPed(pedData)
        end

        function point:onExit()
            dismissPed(pedData)
            lib.hideContext()
        end

        RegisterNetEvent("onResourceStop", function(resourceName)
            if data.resource == resourceName or resourceName == GetCurrentResourceName() then
                dismissPed(pedData)
                point:remove()
            end
        end)

        points[i] = point
    end

    return #points == 1 and points[1] or points
end

exports("addPed", addPed)

CreateThread(function()
    for i = 1, #Peds do
        addPed(Peds[i])
    end
end)

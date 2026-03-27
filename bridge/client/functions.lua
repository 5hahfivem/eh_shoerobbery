local Config = require("shared.config")

---@param data table
---@param finished? function
---@param cancelled? function
function ProgressBar(data, finished, cancelled)
    if Config.Progress == "ox_lib_bar" then
        if lib.progressBar(data) then
            if finished then finished() end
        else
            if cancelled then cancelled() end
        end
    elseif Config.Progress == "ox_lib_circle" then
        if lib.progressCircle(data) then
            if finished then finished() end
        else
            if cancelled then cancelled() end
        end
    elseif Config.Progress == "mythic" and Progress then
        Progress:Progress(data, function(cancel)
            if not cancel then
                if finished then finished() end
            else
                if cancelled then cancelled() end
            end
        end)
    end
end

---@param message string
---@param type 'inform' | 'error' | 'success' | 'warning'
---@param time? integer
function Notify(message, type, time)
    if Config.Notifications ~= "gta" then
        message = message:gsub("~.-~", "")
    end

    if Config.Notifications == "ox_lib" then
        lib.notify({
            description = message,
            type = type,
            duration = time or 5000
        })
    elseif Config.Notifications == "qb" and QBCore then
        QBCore.Functions.Notify(message, type)
    elseif Config.Notifications == "esx" and ESX then
        ESX.ShowNotification(message)
    elseif Config.Notifications == "mythic" and Notification then
        if type == "inform" then
            Notification:Info(message, time or 5000)
        elseif type == "error" then
            Notification:Error(message, time or 5000)
        elseif type == "success" then
            Notification:Success(message, time or 5000)
        elseif type == "warning" then
            Notification:Warn(message, time or 5000)
        end
    elseif Config.Notifications == "okok" then
        exports["okokNotify"]:Alert(message, time or 5000, type, false)
    elseif Config.Notifications == "sd-notify" then
        exports["sd-notify"]:Notify(message, type)
    elseif Config.Notifications == "wasabi_notify" then
        exports.wasabi_notify:notify(message, time or 5000, type, false)
    else
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, false)
    end
end

RegisterNetEvent("eh_shoerobbery:client:notify", function(message, nType, time)
    Notify(message, nType, time)
end)

function HelpNotify(text)
    AddTextEntry("eh_shoerobbery_help", text)
    BeginTextCommandDisplayHelp("eh_shoerobbery_help")
    EndTextCommandDisplayHelp(0, false, true, -1)
end

local mythicZoneHandlers = {}

RegisterNetEvent("eh_shoerobbery:client:mythicZoneSelect", function(payload)
    local zoneId = payload
    if type(payload) == "table" then
        zoneId = payload.zoneId or payload.id or payload.data
    end

    local zoneData = zoneId and mythicZoneHandlers[zoneId]
    if not zoneData then return end
    if zoneData.canInteract and not zoneData.canInteract() then return end
    zoneData.onSelect()
end)

---@param data table
---@return string|number|nil
function AddInteractionZone(data)
    if Config.Target == "ox_target" and GetResourceState("ox_target") == "started" then
        local zoneName = data.name or ("eh_shoe_zone_%s"):format(math.random(100000, 999999))
        exports.ox_target:addSphereZone({
            name = zoneName,
            coords = data.coords,
            radius = data.radius or 1.5,
            debug = data.debug or false,
            options = {
                {
                    name = zoneName .. "_opt",
                    label = data.label,
                    icon = data.icon or "fa-solid fa-hand",
                    canInteract = data.canInteract,
                    onSelect = data.onSelect
                }
            }
        })
        return zoneName
    elseif Config.Target == "sleepless_interact" and GetResourceState("sleepless_interact") == "started" then
        return exports.sleepless_interact:addCoords(data.coords, {
            label = data.label,
            icon = data.icon or "hand",
            distance = data.radius or 1.5,
            canInteract = data.canInteract,
            onSelect = function()
                data.onSelect()
            end
        })
    elseif Config.Target == "mythic-targeting" and Targeting and Targeting.Zones then
        local zoneName = data.zoneId or data.name or ("eh_shoe_zone_%s"):format(math.random(100000, 999999))
        local circleOptions = data.options or { debugPoly = data.debug or false }
        local menuArray = data.menuArray

        if not menuArray then
            mythicZoneHandlers[zoneName] = {
                canInteract = data.canInteract,
                onSelect = data.onSelect
            }

            menuArray = {
                {
                    icon = data.icon or "hand",
                    text = data.label,
                    event = "eh_shoerobbery:client:mythicZoneSelect",
                    data = { zoneId = zoneName },
                    isEnabled = function()
                        if data.canInteract then
                            return data.canInteract()
                        end
                        return true
                    end
                }
            }
        end

        Targeting.Zones:AddCircle(
            zoneName,
            data.icon or "hand",
            data.coords,
            data.radius or 1.5,
            circleOptions,
            menuArray,
            data.proximity or data.radius or 1.5,
            true
        )
        Targeting.Zones:Refresh()
        return zoneName
    end

    return nil
end

---@param zoneId string|number|nil
function RemoveInteractionZone(zoneId)
    if not zoneId then return end

    if Config.Target == "ox_target" and GetResourceState("ox_target") == "started" then
        exports.ox_target:removeZone(zoneId)
    elseif Config.Target == "sleepless_interact" and GetResourceState("sleepless_interact") == "started" then
        exports.sleepless_interact:removeCoords(zoneId)
    elseif Config.Target == "mythic-targeting" and Targeting and Targeting.Zones then
        mythicZoneHandlers[zoneId] = nil
        Targeting.Zones:RemoveZone(zoneId)
        Targeting.Zones:Refresh()
    end
end

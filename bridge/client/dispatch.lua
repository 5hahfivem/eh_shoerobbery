local Config = require("shared.config")

function RobberyAlert(coords)
    if Config.Dispatch == "cd_dispatch" then
        TriggerServerEvent("cd_dispatch:AddNotification", {
            job_table = Config.DispatchJobs,
            coords = coords,
            title = "10-68 - Store Robbery",
            message = "Robbery reported at Binco.",
            flash = 0,
            unique_id = "eh_shoerobbery",
            sound = 1,
            blip = { sprite = 52, scale = 1.0, colour = 1, flashes = false, time = 5 }
        })
    elseif Config.Dispatch == "qs-dispatch" then
        TriggerServerEvent("qs-dispatch:server:CreateDispatchCall", {
            job = Config.DispatchJobs,
            callLocation = coords,
            callCode = { code = "10-68", snippet = "Store Robbery" },
            message = "Robbery reported at Binco.",
            flashes = false,
            blip = { sprite = 52, scale = 1.0, colour = 1, time = (5 * 60000) }
        })
    elseif Config.Dispatch == "ps-dispatch" then
        exports["ps-dispatch"]:StoreRobbery()
    elseif Config.Dispatch == "rcore_dispatch" then
        TriggerServerEvent("rcore_dispatch:server:sendAlert", {
            code = "10-68",
            default_priority = "medium",
            coords = coords,
            job = Config.DispatchJobs,
            text = "Store Robbery",
            type = "alerts",
            blip_time = 0,
            blip = { sprite = 52, scale = 1.0, colour = 1, radius = 0 }
        })
    elseif Config.Dispatch == "mythic-mdt" then
        TriggerServerEvent("EmergencyAlerts:Server:DoPredefined", "storeRobbery", {
            icon = "store",
            details = "Robbery reported at Binco."
        })
    elseif Config.Dispatch == "custom" then
        -- Custom dispatch integration.
    end
end

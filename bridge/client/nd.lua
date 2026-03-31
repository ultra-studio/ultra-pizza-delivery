--[[
    Ultra Studio - Free Resource
    Version: v1.0.0
    © 2026 Ultra Studio. All rights reserved.
    This project is free to use, but it may not be resold or redistributed without permission.
    Credits: Ultra Studio
]]

if not lib.checkDependency('ND_Core', '2.0.0') then
    return
end

NDCore = {}

lib.load('@ND_Core.init')

RegisterNetEvent('ND:characterUnloaded', function()
    LocalPlayer.state.isLoggedIn = false
    OnPlayerUnload()
end)

RegisterNetEvent('ND:characterLoaded', function(character)
    LocalPlayer.state.isLoggedIn = true
    OnPlayerLoaded()
end)

function hasPlyLoaded()
    return LocalPlayer.state.isLoggedIn
end

function DoNotification(text, nType)
    lib.notify({
        title = 'Notification',
        description = text,
        type = nType,
    })
end

function handleVehicleKeys(veh)
    -- Add your preferred ND vehicle key integration here if your server uses one.
end

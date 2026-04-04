--[[
    Ultra Studio - Free Resource
    Version: v1.0.1
    (c) 2026 Ultra Studio. All rights reserved.
    This project is free to use, but it may not be resold or redistributed without permission.
    Credits: Ultra Studio
]]

if GetResourceState('es_extended') ~= 'started' then
    return
end

local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerLoaded = true
    OnPlayerLoaded()
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    OnPlayerUnload()
end)

function handleVehicleKeys(veh)
    -- Add your preferred ESX vehicle key integration here if your server uses one.
end

function hasPlyLoaded()
    return ESX.PlayerLoaded
end

function DoNotification(text, notificationType)
    ESX.ShowNotification(text, notificationType)
end


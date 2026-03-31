--[[
    Ultra Studio - Free Resource
    Version: v1.0.0
    © 2026 Ultra Studio. All rights reserved.
    This project is free to use, but it may not be resold or redistributed without permission.
    Credits: Ultra Studio
]]

if GetResourceState('qb-core') ~= 'started' then
    return
end

local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    OnPlayerLoaded()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    OnPlayerUnload()
end)

function handleVehicleKeys(veh)
    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(veh))
end

function hasPlyLoaded()
    return LocalPlayer.state.isLoggedIn
end

function DoNotification(text, notificationType)
    QBCore.Functions.Notify(text, notificationType)
end

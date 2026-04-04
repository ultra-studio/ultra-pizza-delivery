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

function GetPlayer(id)
    return ESX.GetPlayerFromId(id)
end

function DoNotification(src, text)
    TriggerClientEvent('esx:showNotification', src, text)
end

function AddMoney(xPlayer, moneyType, amount)
    local account = moneyType == 'cash' and 'money' or moneyType
    xPlayer.addAccountMoney(account, amount, 'ultra-studio-pizzajob')
end

function handleExploit(id, reason)
    DropPlayer(id, 'You were dropped from the server.')
    print(('[^3WARNING^7] Player: ^5%s^7 attempted to exploit Ultra Studio Pizza Job. Reason: %s'):format(id, reason))
end

AddEventHandler('esx:playerLogout', function(playerId)
    ServerOnLogout(playerId)
end)


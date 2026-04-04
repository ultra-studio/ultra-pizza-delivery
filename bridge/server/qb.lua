--[[
    Ultra Studio - Free Resource
    Version: v1.0.1
    (c) 2026 Ultra Studio. All rights reserved.
    This project is free to use, but it may not be resold or redistributed without permission.
    Credits: Ultra Studio
]]

if GetResourceState('qb-core') ~= 'started' then
    return
end

local QBCore = exports['qb-core']:GetCoreObject()

function GetPlayer(id)
    return QBCore.Functions.GetPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('QBCore:Notify', src, text, nType)
end

function AddMoney(Player, moneyType, amount)
    Player.Functions.AddMoney(moneyType, amount, 'ultra-studio-pizzajob')
end

function handleExploit(id, reason)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(id),
        QBCore.Functions.GetIdentifier(id, 'license'),
        QBCore.Functions.GetIdentifier(id, 'discord'),
        QBCore.Functions.GetIdentifier(id, 'ip'),
        reason,
        2147483647,
        'ultra-studio-pizzajob'
    })
    DropPlayer(id, 'You were banned from the server for exploiting.')
end

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(source)
    ServerOnLogout(source)
end)


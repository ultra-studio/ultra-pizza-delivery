--[[
    Ultra Studio - Free Resource
    Version: v1.0.0
    © 2026 Ultra Studio. All rights reserved.
    This project is free to use, but it may not be resold or redistributed without permission.
    Credits: Ultra Studio
]]

local ServerConfig = lib.require('config.server')

local playerShifts = {}

-- Spawn the delivery vehicle and place the player directly into it.
local function createPizzaVehicle(playerSource)
    local spawn = ServerConfig.vehicleSpawn
    local vehicle = CreateVehicle(ServerConfig.vehicleModel, spawn.x, spawn.y, spawn.z, spawn.w, true, true)
    local playerPed = GetPlayerPed(playerSource)

    while not DoesEntityExist(vehicle) do
        Wait(0)
    end

    while GetVehiclePedIsIn(playerPed, false) ~= vehicle do
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        Wait(0)
    end

    return NetworkGetNetworkIdFromEntity(vehicle)
end

-- Build a unique set of delivery points for the current shift.
local function getRandomizedLocations()
    local deliveries = {}
    local usedIndexes = {}
    local targetCount = math.min(ServerConfig.deliveriesPerShift, #ServerConfig.deliveryLocations)

    while #deliveries < targetCount do
        local index = math.random(#ServerConfig.deliveryLocations)

        if not usedIndexes[index] then
            deliveries[#deliveries + 1] = ServerConfig.deliveryLocations[index]
            usedIndexes[index] = true
        end
    end

    return deliveries
end

local function getRandomPayout()
    return math.random(ServerConfig.payout.min, ServerConfig.payout.max)
end

-- Remove the active shift and clean up any spawned vehicle entity.
local function cleanupShift(playerSource)
    local shift = playerShifts[playerSource]
    if not shift then
        return false
    end

    if DoesEntityExist(shift.entity) then
        DeleteEntity(shift.entity)
    end

    playerShifts[playerSource] = nil
    return true
end

lib.callback.register('ultra_pizzajob:server:spawnVehicle', function(source)
    if playerShifts[source] then
        return false
    end

    local networkId = createPizzaVehicle(source)
    local locations = getRandomizedLocations()
    if #locations == 0 then
        return false
    end

    local currentIndex = math.random(#locations)
    local currentLocation = locations[currentIndex]

    table.remove(locations, currentIndex)

    playerShifts[source] = {
        entity = NetworkGetEntityFromNetworkId(networkId),
        locations = locations,
        payment = getRandomPayout(),
        current = currentLocation,
    }

    return networkId, playerShifts[source]
end)

lib.callback.register('ultra_pizzajob:server:clockOut', function(source)
    return cleanupShift(source)
end)

lib.callback.register('ultra_pizzajob:server:payment', function(source)
    local player = GetPlayer(source)
    local playerPosition = GetEntityCoords(GetPlayerPed(source))
    local shift = playerShifts[source]

    if not player or not shift or #(playerPosition - shift.current) > 5.0 then
        handleExploit(source, 'Attempted to trigger pizza payment outside a valid delivery zone.')
        return false
    end

    AddMoney(player, ServerConfig.payoutAccount, shift.payment)

    if #shift.locations == 0 then
        DoNotification(source, ('You received $%s. No deliveries remain, return the vehicle.'):format(shift.payment), 'success')
        return true
    end

    DoNotification(source, ('You received $%s. Deliveries remaining: %s'):format(shift.payment, #shift.locations), 'success')

    local nextIndex = math.random(#shift.locations)
    shift.current = shift.locations[nextIndex]
    shift.payment = getRandomPayout()

    table.remove(shift.locations, nextIndex)

    return true, shift
end)

AddEventHandler('playerDropped', function()
    cleanupShift(source)
end)

function ServerOnLogout(playerSource)
    cleanupShift(playerSource)
end

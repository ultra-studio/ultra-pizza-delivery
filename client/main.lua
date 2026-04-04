--[[
    Ultra Studio - Free Resource
    Version: v1.0.1
    (c) 2026 Ultra Studio. All rights reserved.
    This project is free to use, but it may not be resold or redistributed without permission.
    Credits: Ultra Studio
]]

local SharedConfig = lib.require('config.shared')

-- Validate hard dependencies early to avoid runtime errors later.
if GetResourceState('ox_lib') ~= 'started' then
    print('[Ultra Pizza Job] ox_lib is required but not started.')
    return
end

if GetResourceState('qb-target') ~= 'started' then
    print('[Ultra Pizza Job] qb-target is required but not started.')
    return
end

local state = {
    isHired = false,
    isHoldingPizza = false,
    isDeliveryInProgress = false,
    currentDelivery = nil,
    deliveryVehicle = nil,
    deliveryBlip = nil,
    bossPed = nil,
    bossPoint = nil,
    pizzaProp = nil,
}

local function showNotification(message, notificationType)
    DoNotification(message, notificationType)
end

-- Create the permanent map marker for the pizza job hub.
local function createBossBlip()
    local blip = AddBlipForCoord(SharedConfig.bossCoords.x, SharedConfig.bossCoords.y, SharedConfig.bossCoords.z)
    SetBlipSprite(blip, SharedConfig.bossBlip.sprite)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, SharedConfig.bossBlip.scale)
    SetBlipColour(blip, SharedConfig.bossBlip.colour)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(SharedConfig.bossBlip.label)
    EndTextCommandSetBlipName(blip)
end

local function clearDeliveryBlip()
    if state.deliveryBlip and DoesBlipExist(state.deliveryBlip) then
        RemoveBlip(state.deliveryBlip)
    end

    state.deliveryBlip = nil
end

-- Toggle the carry animation and pizza box prop used during deliveries.
local function setPizzaCarryState(enabled)
    if enabled then
        -- Use joaat hash to avoid backtick-literal diagnostics in editors.
        local model = joaat('prop_pizza_box_02')
        local playerCoords = GetEntityCoords(cache.ped)

        lib.requestModel(model)
        state.pizzaProp = CreateObject(model, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
        AttachEntityToEntity(state.pizzaProp, cache.ped, GetPedBoneIndex(cache.ped, 28422), 0.01, -0.10, -0.159, 20.0, 0.0, 0.0, true, true, false, true, 0, true)

        lib.requestAnimDict('anim@heists@box_carry@')
        TaskPlayAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 5.0, 5.0, -1, 51, 0, 0, 0, 0)
        SetModelAsNoLongerNeeded(model)

        CreateThread(function()
            while DoesEntityExist(state.pizzaProp) do
                if not IsEntityPlayingAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 3) then
                    TaskPlayAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 5.0, 5.0, -1, 51, 0, 0, 0, 0)
                end

                Wait(1000)
            end

            RemoveAnimDict('anim@heists@box_carry@')
        end)
    elseif DoesEntityExist(state.pizzaProp) then
        DetachEntity(state.pizzaProp, true, false)
        DeleteEntity(state.pizzaProp)
        state.pizzaProp = nil
        ClearPedTasksImmediately(cache.ped)
    end

    state.isHoldingPizza = enabled
end

local function removeVehicleInteractions()
    if state.deliveryVehicle and DoesEntityExist(state.deliveryVehicle) then
        exports['qb-target']:RemoveTargetEntity(state.deliveryVehicle, {
            SharedConfig.labels.takePizza,
            SharedConfig.labels.returnPizza,
        })
    end
end

-- Reset every client-side job reference when the player stops working or unloads.
local function resetJobState()
    exports['qb-target']:RemoveZone('ultra_pizzajob_delivery')
    clearDeliveryBlip()
    removeVehicleInteractions()
    setPizzaCarryState(false)

    state.isHired = false
    state.isHoldingPizza = false
    state.isDeliveryInProgress = false
    state.currentDelivery = nil
    state.deliveryVehicle = nil

    if state.bossPed and DoesEntityExist(state.bossPed) then
        exports['qb-target']:RemoveTargetEntity(state.bossPed, {
            SharedConfig.labels.startWork,
            SharedConfig.labels.finishWork,
        })
        DeleteEntity(state.bossPed)
        state.bossPed = nil
    end

    if state.bossPoint then
        state.bossPoint:remove()
        state.bossPoint = nil
    end
end

local function takePizzaFromVehicle()
    if IsPedInAnyVehicle(cache.ped, false) or IsEntityDead(cache.ped) or state.isHoldingPizza then
        return
    end

    local playerPosition = GetEntityCoords(cache.ped)
    if not state.currentDelivery or #(playerPosition - state.currentDelivery) >= 30.0 then
        showNotification(SharedConfig.notifications.tooFarFromCustomer, 'error')
        return
    end

    setPizzaCarryState(true)
end

-- Start a fresh delivery objective and register the delivery interaction zone.
local function startNextDelivery(deliveryData)
    if state.isDeliveryInProgress then
        return
    end

    state.currentDelivery = deliveryData.current
    state.deliveryBlip = AddBlipForCoord(state.currentDelivery.x, state.currentDelivery.y, state.currentDelivery.z)

    SetBlipSprite(state.deliveryBlip, 1)
    SetBlipDisplay(state.deliveryBlip, 4)
    SetBlipScale(state.deliveryBlip, 0.8)
    SetBlipFlashes(state.deliveryBlip, true)
    SetBlipAsShortRange(state.deliveryBlip, true)
    SetBlipColour(state.deliveryBlip, 2)
    SetBlipRoute(state.deliveryBlip, true)
    SetBlipRouteColour(state.deliveryBlip, 2)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(SharedConfig.labels.nextCustomer)
    EndTextCommandSetBlipName(state.deliveryBlip)

    exports['qb-target']:AddCircleZone('ultra_pizzajob_delivery', state.currentDelivery, SharedConfig.deliveryZoneRadius, {
        name = 'ultra_pizzajob_delivery',
        debugPoly = false,
        useZ = true,
    }, {
        options = {
            {
                icon = 'fa-solid fa-pizza-slice',
                label = SharedConfig.labels.deliverPizza,
                action = function()
                    if not state.isHoldingPizza or not state.isHired then
                        showNotification(SharedConfig.notifications.takePizzaHint, 'error')
                        return
                    end

                    lib.requestAnimDict('timetable@jimmy@doorknock@')
                    TaskPlayAnim(cache.ped, 'timetable@jimmy@doorknock@', 'knockdoor_idle', 3.0, 1.0, -1, 49, 0, true, true, true)
                    RemoveAnimDict('timetable@jimmy@doorknock@')

                    if lib.progressCircle({
                        duration = 7000,
                        position = 'bottom',
                        label = SharedConfig.labels.deliverProgress,
                        useWhileDead = true,
                        canCancel = false,
                        disable = {
                            move = true,
                            car = true,
                            mouse = false,
                            combat = true,
                        },
                    }) then
                        local success, nextDeliveryData = lib.callback.await('ultra_pizzajob:server:payment', false)
                        if not success then
                            return
                        end

                        clearDeliveryBlip()
                        exports['qb-target']:RemoveZone('ultra_pizzajob_delivery')
                        state.isDeliveryInProgress = false
                        setPizzaCarryState(false)

                        if nextDeliveryData then
                            startNextDelivery(nextDeliveryData)
                        end
                    end
                end,
            },
        },
        distance = SharedConfig.interactDistance,
    })

    state.isDeliveryInProgress = true
    showNotification(SharedConfig.notifications.newDelivery, 'success')
end

local function applyFuel(vehicle)
    if SharedConfig.fuel.enabled then
        exports[SharedConfig.fuel.resource]:SetFuel(vehicle, SharedConfig.fuel.level)
    else
        Entity(vehicle).state.fuel = SharedConfig.fuel.level
    end
end

local function registerVehicleInteractions()
    exports['qb-target']:AddTargetEntity(state.deliveryVehicle, {
        options = {
            {
                icon = 'fa-solid fa-pizza-slice',
                label = SharedConfig.labels.takePizza,
                action = function()
                    takePizzaFromVehicle()
                end,
                canInteract = function()
                    return state.isHired and state.isDeliveryInProgress and not state.isHoldingPizza
                end,
            },
            {
                icon = 'fa-solid fa-pizza-slice',
                label = SharedConfig.labels.returnPizza,
                action = function()
                    setPizzaCarryState(false)
                end,
                canInteract = function()
                    return state.isHired and state.isDeliveryInProgress and state.isHoldingPizza
                end,
            },
        },
        distance = SharedConfig.vehicleInteractDistance,
    })
end

local function pullOutVehicle(networkId, deliveryData)
    state.deliveryVehicle = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(networkId) then
            return NetToVeh(networkId)
        end
    end, 'Could not load entity in time.', 1000)

    if state.deliveryVehicle == 0 then
        showNotification(SharedConfig.notifications.vehicleSpawnFailed, 'error')
        return
    end

    SetVehicleNumberPlateText(state.deliveryVehicle, ('PIZZA%s'):format(math.random(1000, 9999)))
    SetVehicleColours(state.deliveryVehicle, 111, 111)
    SetVehicleDirtLevel(state.deliveryVehicle, 1.0)
    SetVehicleEngineOn(state.deliveryVehicle, true, true)
    handleVehicleKeys(state.deliveryVehicle)

    state.isHired = true
    startNextDelivery(deliveryData)
    applyFuel(state.deliveryVehicle)
    registerVehicleInteractions()
end

local function finishWork()
    local playerPosition = GetEntityCoords(cache.ped)
    local bossPosition = SharedConfig.bossCoords.xyz

    if #(playerPosition - bossPosition) > 10.0 or not state.isHired then
        return
    end

    local success = lib.callback.await('ultra_pizzajob:server:clockOut', false)
    if not success then
        return
    end

    clearDeliveryBlip()
    exports['qb-target']:RemoveZone('ultra_pizzajob_delivery')
    removeVehicleInteractions()
    setPizzaCarryState(false)

    state.isHired = false
    state.isDeliveryInProgress = false
    state.currentDelivery = nil
    state.deliveryVehicle = nil

    showNotification(SharedConfig.notifications.shiftEnded, 'success')
end

local function removeBossPed()
    if state.bossPed and DoesEntityExist(state.bossPed) then
        exports['qb-target']:RemoveTargetEntity(state.bossPed, {
            SharedConfig.labels.startWork,
            SharedConfig.labels.finishWork,
        })
        DeleteEntity(state.bossPed)
        state.bossPed = nil
    end
end

-- Spawn the boss NPC only when the player is close enough to interact.
local function spawnBossPed()
    if state.bossPed and DoesEntityExist(state.bossPed) then
        return
    end

    local bossModelHash = joaat(SharedConfig.bossModel)
    lib.requestModel(bossModelHash)
    state.bossPed = CreatePed(0, bossModelHash, SharedConfig.bossCoords, false, false)

    SetEntityAsMissionEntity(state.bossPed, true, true)
    SetPedFleeAttributes(state.bossPed, 0, false)
    SetBlockingOfNonTemporaryEvents(state.bossPed, true)
    SetEntityInvincible(state.bossPed, true)
    FreezeEntityPosition(state.bossPed, true)

    lib.requestAnimDict('amb@world_human_leaning@female@wall@back@holding_elbow@idle_a')
    TaskPlayAnim(state.bossPed, 'amb@world_human_leaning@female@wall@back@holding_elbow@idle_a', 'idle_a', 8.0, 1.0, -1, 1, 0, 0, 0, 0)
    RemoveAnimDict('amb@world_human_leaning@female@wall@back@holding_elbow@idle_a')
    SetModelAsNoLongerNeeded(bossModelHash)

    exports['qb-target']:AddTargetEntity(state.bossPed, {
        options = {
            {
                icon = 'fa-solid fa-pizza-slice',
                label = SharedConfig.labels.startWork,
                action = function()
                    local networkId, deliveryData = lib.callback.await('ultra_pizzajob:server:spawnVehicle', false)
                    if networkId and deliveryData then
                        pullOutVehicle(networkId, deliveryData)
                    end
                end,
                canInteract = function()
                    return not state.isHired
                end,
            },
            {
                icon = 'fa-solid fa-pizza-slice',
                label = SharedConfig.labels.finishWork,
                action = function()
                    finishWork()
                end,
                canInteract = function()
                    return state.isHired
                end,
            },
        },
        distance = SharedConfig.interactDistance,
    })
end

local function createBossPoint()
    if state.bossPoint then
        return
    end

    state.bossPoint = lib.points.new({
        coords = SharedConfig.bossCoords.xyz,
        distance = 50,
        onEnter = spawnBossPed,
        onExit = removeBossPed,
    })
end

function OnPlayerLoaded()
    createBossPoint()
end

function OnPlayerUnload()
    resetJobState()
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName or not hasPlyLoaded() then
        return
    end

    createBossPoint()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    resetJobState()
end)

createBossBlip()


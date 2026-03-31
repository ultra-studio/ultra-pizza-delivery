--[[
    Ultra Studio - Free Resource
    Version: v1.0.0
    © 2026 Ultra Studio. All rights reserved.
    This project is free to use, but it may not be resold or redistributed without permission.
    Credits: Ultra Studio
]]

return {
    jobName = 'Pizza Job',
    bossModel = `u_m_y_party_01`,
    bossCoords = vec4(538.35, 101.80, 95.54, 164.05),
    deliveryZoneRadius = 1.3,
    interactDistance = 1.5,
    vehicleInteractDistance = 2.5,
    bossBlip = {
        sprite = 93,
        scale = 1.0,
        colour = 17,
        label = 'Pizza Job',
    },
    fuel = {
        enabled = false,
        resource = 'ps-fuel',
        level = 100.0,
    },
    notifications = {
        tooFarFromCustomer = 'You are not close enough to the customer''s house.',
        vehicleSpawnFailed = 'The delivery vehicle could not be spawned.',
        shiftEnded = 'You ended your shift.',
        newDelivery = 'You have a new delivery.',
        takePizzaHint = 'You need to collect the pizza from the vehicle first.',
    },
    labels = {
        startWork = 'Start Work',
        finishWork = 'Finish Work',
        takePizza = 'Take Pizza',
        returnPizza = 'Return Pizza',
        deliverPizza = 'Deliver Pizza',
        nextCustomer = 'Next Customer',
        deliverProgress = 'Delivering pizza',
    },
}

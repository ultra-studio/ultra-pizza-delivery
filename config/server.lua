--[[
    Ultra Studio - Free Resource
    Version: v1.0.1
    (c) 2026 Ultra Studio. All rights reserved.
    This project is free to use, but it may not be resold or redistributed without permission.
    Credits: Ultra Studio
]]

return {
    deliveriesPerShift = 5,
    payoutAccount = 'cash',
    payout = {
        min = 30,
        max = 50,
    },
    deliveryLocations = {
        vec3(224.11, 513.52, 140.92),
        vec3(57.51, 449.71, 147.03),
        vec3(-297.81, 379.83, 112.10),
        vec3(-595.78, 393.00, 101.88),
        vec3(-842.68, 466.85, 87.60),
        vec3(-1367.36, 610.73, 133.88),
        vec3(944.44, -463.19, 61.55),
        vec3(970.42, -502.50, 62.14),
        vec3(1099.50, -438.65, 67.79),
        vec3(1229.60, -725.41, 60.96),
        vec3(288.05, -1094.98, 29.42),
        vec3(-32.35, -1446.46, 31.89),
        vec3(-34.29, -1847.21, 26.19),
        vec3(130.59, -1853.27, 25.23),
        vec3(192.20, -1883.30, 25.06),
        vec3(348.64, -1820.87, 28.89),
        vec3(427.28, -1842.14, 28.46),
        vec3(291.48, -1980.15, 21.60),
        vec3(279.87, -2043.67, 19.77),
        vec3(1297.25, -1618.04, 54.58),
        vec3(1381.98, -1544.75, 57.11),
        vec3(1245.40, -1626.85, 53.28),
        vec3(315.09, -128.31, 69.98),
    },
    -- Vehicle model name kept as a string to avoid diagnostic errors.
    vehicleModel = 'faggio',
    vehicleSpawn = vec4(535.30, 95.58, 96.32, 159.15),
    exploitDropMessage = 'You were removed from the server for exploiting the pizza job.',
    resourceAccountTag = 'ultra-studio-pizzajob',
}


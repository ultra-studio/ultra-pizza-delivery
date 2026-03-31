--[[
    Ultra Studio - Free Resource
    Version: v1.0.0
    © 2026 Ultra Studio. All rights reserved.
    This project is free to use, but it may not be resold or redistributed without permission.
    Credits: Ultra Studio
]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Ultra Studio'
description 'Ultra Studio Pizza Job'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/shared.lua',
}

client_scripts {
    'bridge/client/*.lua',
    'client/main.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'bridge/server/*.lua',
    'config/server.lua',
    'server/main.lua',
}

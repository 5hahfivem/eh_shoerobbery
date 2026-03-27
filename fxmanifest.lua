fx_version 'cerulean'
game 'gta5'

name 'eh_shoerobbery'
author '>^._.^<'
description 'Binco register and shoebox robbery'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/locale.lua',
    'bridge/framework.lua'
}
client_scripts {
    'bridge/client/functions.lua',
    'bridge/client/dispatch.lua',
    'bridge/client/esx.lua',
    'bridge/client/qb.lua',
    'bridge/client/qbox.lua',
    'bridge/client/mythic.lua',
    'client/main.lua'
}
server_scripts {
    'bridge/server/esx.lua',
    'bridge/server/qb.lua',
    'bridge/server/qbox.lua',
    'server/main.lua'
}

files { 'locales/*.json' }

dependencies { 'ox_lib' }
lua54 'yes'

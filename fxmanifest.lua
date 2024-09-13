fx_version 'cerulean'
game 'gta5'
version '1.0.0'
lua54 'yes'
use_fxv2_oal 'yes'
author 'ENT510'
description 'chat For Fivem Server'
shared_scripts { 'shared/*.lua','@ox_lib/init.lua',"framework/GetFramework.lua",}
client_scripts {'client/**/*'}
server_scripts {'@oxmysql/lib/MySQL.lua','server/**/*'}
files { "framework/legacy/*.lua", "framework/esx/*.lua","framework/qbox/*.lua", 'web/build/index.html','web/build/**/*',}
ui_page 'web/build/index.html'


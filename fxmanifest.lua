game "gta5"
fx_version "cerulean"
use_experimental_fxv2_oal "yes"
lua54 "yes"

shared_script "@ox_lib/init.lua"

shared_script "utils/*.lua"
client_script "client/*.lua"
server_script "server/*.lua"
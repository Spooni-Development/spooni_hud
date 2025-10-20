fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'

name 'spooni_hud'
author 'Spooni'
description 'Performance-optimized HUD for RedM/VORP Framework'
version '2'

dependencies {
    'vorp_core'
}

shared_scripts {
    'shared/*.lua'
}

server_scripts {
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/css/*.css',
    'ui/js/*.js',
    'ui/fonts/*',
    'ui/img/*'
}
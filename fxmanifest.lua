fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Bob\'s Mods'
description 'A modern ambient health screen and last stand display'
version '0.01'


shared_scripts {
  'shared/config.lua',
  'shared/utils.lua'
}

client_scripts {
  'client/utils.lua',
  'client/client.lua',
}

server_script {
  'server/utils.lua',
  'server/server.lua',

}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/script.js',
  'html/style.css'
}

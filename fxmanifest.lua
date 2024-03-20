fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'BM-LastStandUI'
version '0.01'


shared_scripts {
  'shared/config.lua',
  'shared/utils.lua'
}

client_scripts {
  'client/main.lua',
  'client/utils.lua'
}

server_script {
  'server/main.lua',
  'server/utils.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/script.js',
  'html/style.css'
}

QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('bm-AmbientHealthUI:GetPlayers', function(_, cb)
  local Players = QBCore.Functions.GetQBPlayers()
  cb(Players)
end)

print("^1[Bob\'s Mods] ^2AmbientHealthUI ^7- ^5Server^7")

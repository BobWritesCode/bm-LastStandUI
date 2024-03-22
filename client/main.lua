local QBCore = exports['qb-core']:GetCoreObject()

local isUIOpen = false
AddEventHandler('onResourceStart', function(resourceName)
  if GetCurrentResourceName() ~= resourceName then return end
end)

function OpenUI()
  SendNUIMessage({
    action = 'OpenUI',
    timer = Config.LastStandTime
  })
end

function CloseUI()
  SendNUIMessage({
    action = 'CloseUI',
  })
end

CreateThread(function()
  while true do
    Wait(100)
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)
    local Player = QBCore.Functions.GetPlayerData()
    if (Player.metadata['inlaststand'] or Player.metadata['isdead'] or health == 0) and not isUIOpen then
      OpenUI()
      isUIOpen = true
    end
    if (not Player.metadata['inlaststand'] and not Player.metadata['isdead']) and isUIOpen then
      CloseUI()
      isUIOpen = false
    end
  end
end)

exports('OpenUI', OpenUI)
exports('CloseUI', CloseUI)

print("^4[Log] ^3bm-LastStandUI ^2started^7")

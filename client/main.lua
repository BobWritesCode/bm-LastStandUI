local QBCore = exports['qb-core']:GetCoreObject()

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


print("^4[Log] ^3bm-LastStandUI ^2started^7")

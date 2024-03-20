local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('onResourceStart', function(resourceName)
  if GetCurrentResourceName() ~= resourceName then return end
end)

print("^4[Log] ^3bm-LastStandUI ^2started^7")

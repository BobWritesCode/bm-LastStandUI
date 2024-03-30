QBCore = exports['qb-core']:GetCoreObject()
local hasStarted = false
local isPingOnCooldown = false
IsAlive = true
local NUIReady = false
local isMedicAvaliable = false

AddEventHandler('onResourceStart', function(resourceName)
  DebugPrint2('Function: ', 'onResourceStart')
  DebugPrint2('GetCurrentResourceName(): ', GetCurrentResourceName())
  DebugPrint2('resourceName: ', resourceName)
  if GetCurrentResourceName() ~= resourceName then return end
  UnBlur()
  StartUp()
end)

AddEventHandler('onResourceStop', function()
  DebugPrint2('Function: ', 'onResourceStop')
  UnBlur()
end)

RegisterNUICallback('nuiReady', function(_, cb)
  cb('pass')
  NUIReady = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
  DebugPrint2('Function: ', 'QBCore:Client:OnPlayerLoaded')
  StartUp()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
  DebugPrint2('Function: ', 'QBCore:Client:OnPlayerUnload')
  hasStarted = false
end)

function StartUp()
  DebugPrint2('Function: ', 'StartUp()')
  local i = 0
  while not NUIReady and i < 10 do
    i = i + 1
    DebugPrint2('Loading NUI...', i)
    Wait(1000)
    if i == 10 then
      ErrorPrint('NUI did not load', '')
    end
  end
  SendNUIMessage({ action = 'Debug', debug = Config.Debug })
  if hasStarted then return end
  hasStarted = true
  OpenUI()
  MainThread()
end

function OpenUI()
  DebugPrint2('Function: ', 'OpenUI()')
  SendNUIMessage({ action = 'UpdateMessage', el = "line-3", displayMsg = Config.lang.beetweenPings })
  SendNUIMessage({ action = 'UpdateMessage', el = "incapacitated", displayMsg = Config.lang.incapacitated })
  if not isMedicAvaliable then
    SendNUIMessage({ action = 'UpdateMessage', el = "line-4", displayMsg = Config.lang.noMedicGiveUpPrior })
  else
    SendNUIMessage({ action = 'UpdateMessage', el = 'line-4', displayMsg = Config.lang.giveUpPrior })
  end
  if not Config.showClosestMedic then SendNUIMessage({ action = 'Display', el = "line-1", show = 'none' }) end
end

function MainThread()
  DebugPrint2('Function: ', 'MainThread()')
  local Player = QBCore.Functions.GetPlayerData()
  local health = GetEntityHealth(PlayerPedId())
  local prevHealth = health
  local wasDeadLastLoop = (Player.metadata['inlaststand'] or Player.metadata['isdead'])
  IsAlive = not (Player.metadata['inlaststand'] or Player.metadata['isdead'])
  -- OpenUI()
  CreateThread(function()
    local isFirstLoop = true -- This is to check when player loads and is already down or player is down at script restart.
    while hasStarted do
      Wait(100)
      Player = QBCore.Functions.GetPlayerData()
      health = GetEntityHealth(PlayerPedId())
      local isDead = (Player.metadata['inlaststand'] or Player.metadata['isdead'])
      ---
      if (not wasDeadLastLoop and isDead) or (isDead and isFirstLoop) then --and health == 0 and health < prevHealth and IsAlive
        PlayerDied()
        if isFirstLoop then
          SendNUIMessage({ action = 'Display', el = "footer", show = "flex" })
          Blur()
        end
      elseif health ~= prevHealth and IsAlive then
        if health == 0 then
          DeathScreen()
          IsAlive = false
        end
        PlayerTookDamage(health)
      elseif wasDeadLastLoop and not isDead then -- Player revied
        PlayerWasRevived(health)
      end
      ---
      prevHealth = health
      wasDeadLastLoop = isDead
      isFirstLoop = false
    end
  end)
end

function PlayerDied()
  DebugPrint('--- Player died ---')
  IsAlive = false
  SendNUIMessage({ action = 'UpdateHp', hp = 0, maxHp = 200 - 100 })
  SendNUIMessage({ action = 'Died', timer = Config.LastStandTime })
  if not isMedicAvaliable then
    SendNUIMessage({ action = 'UpdateMessage', el = "line-4", displayMsg = Config.lang.noMedicGiveUpPrior })
  else
    SendNUIMessage({ action = 'UpdateMessage', el = 'line-4', displayMsg = Config.lang.giveUpPrior })
  end
  local displayMsg
  if Config.willAutoPingMedic then
    PingMedic()
    displayMsg = Config.lang.EMSNotified
  else
    displayMsg = Config.lang.pingMedic
  end
  SendNUIMessage({ action = 'UpdateMessage', el = "line-2", displayMsg = displayMsg })
  DeadTimer()
end

function PlayerTookDamage(health)
  DebugPrint('--- Current health different to prevHealth ---')
  SendNUIMessage({
    action = 'UpdateHp',
    hp = health - 100,
    maxHp = 200 - 100
  })
end

function PlayerWasRevived(health)
  DebugPrint('--- Player was revived ---')
  IsAlive = true
  SendNUIMessage({ action = 'Display', el = "footer", show = "none" })
  SendNUIMessage({ action = 'Revived', hp = health - 100, maxHp = 200 - 100 })
  UnBlur()
end

-- Function to allow player to ping for medic.
function PingMedic()
  CreateThread(function()
    DebugPrint2('Function: ', 'PingMedic()')
    if isPingOnCooldown then return end
    Config.functions.pingMedic()
  end)
end

function DeadTimer()
  DebugPrint2('Function: ', 'DeadTimer()')
  CreateThread(function()
    local _ = GetClosestMedic()
    local deathCountdown
    if isMedicAvaliable then
      deathCountdown = Config.LastStandTime + 1
    else
      deathCountdown = Config.noMedicLastStandTime + 1
    end
    local pingCoooldown = Config.TimeBetweenEMSPings + 1
    local isPingOnCoolDown = Config.willAutoPingMedic
    local timeWait = 50                    -- Pick a number that is lower and devisable to 1000
    local parsesRequired = 1000 / timeWait -- How many iterations in loop are required to be ~ 1 second.
    local i = parsesRequired
    local holdCd = 5
    local blurCountdown = Config.howLongScreenBlurLasts
    ---
    while not IsAlive do
      if IsControlPressed(0, Config.key.pingMedic) and isMedicAvaliable then
        if not isPingOnCoolDown then
          PingMedic()
          pingCoooldown = Config.TimeBetweenEMSPings + 1
          isPingOnCoolDown = true
          SendNUIMessage({ action = 'UpdateMessage', el = "line-2", displayMsg = Config.lang.EMSNotified })
          SendNUIMessage({
            action = 'UpdateMessage',
            el = "line-3",
            displayMsg = Config.lang.pingCooldown ..
                " (" .. pingCoooldown .. ")"
          })
          if not Config.canRespawnOnCooldown then
            SendNUIMessage({
              action = 'UpdateMessage',
              el = 'line-4',
              displayMsg =
                  Config.lang.giveUponCooldown
            })
          end
        end
      end
      if i == parsesRequired then
        --- Get nearest medic distance and display
        UpdateNearestMedic()
        --- THE DEATH TIMER
        if deathCountdown > 0 then
          deathCountdown = deathCountdown - 1
          UpdateNUITImer(deathCountdown)
        elseif deathCountdown == 0 then
          deathCountdown = -1
          SendNUIMessage({ action = 'Display', el = "time-container", show = "none" })
          SendNUIMessage({ action = 'Display', el = "CD", show = "block" })
        end
        --- PING COOL DOWN TIMER
        if pingCoooldown > 0 then
          pingCoooldown = pingCoooldown - 1
        end
        if not isMedicAvaliable then
          SendNUIMessage({ action = 'UpdateMessage', el = "line-2", displayMsg = Config.lang.noOneToPing })
          SendNUIMessage({ action = 'UpdateMessage', el = "line-3", displayMsg = Config.lang.yourOnlyOption })
          SendNUIMessage({ action = 'UpdateMessage', el = "line-4", displayMsg = Config.lang.noMedicGiveUpPrior })
        elseif isPingOnCoolDown > 0 then
          SendNUIMessage({
            action = 'UpdateMessage',
            el = "line-3",
            displayMsg = Config.lang.pingCooldown ..
                " (" .. pingCoooldown .. ")"
          })
        elseif pingCoooldown <= 0 then
          isPingOnCoolDown = false
          SendNUIMessage({ action = 'UpdateMessage', el = "line-2", displayMsg = Config.lang.pingMedic })
          SendNUIMessage({ action = 'UpdateMessage', el = "line-3", displayMsg = Config.lang.beetweenPings })
        end
        --- GIVE UP
        if not Config.canRespawnOnCooldown and isPingOnCoolDown then
          SendNUIMessage({ action = 'UpdateMessage', el = 'line-4', displayMsg = Config.lang.giveUponCooldown })
          SendNUIMessage({ action = 'HideEl', el = "CD", show = false })
          holdCd = 5
        else
          if IsControlPressed(0, Config.key.giveUp)
              and deathCountdown == -1
              and holdCd > 0 then
            SendNUIMessage({ action = 'UpdateMessage', el = 'line-4', displayMsg = "Keep holding to respawn..." })
            SendNUIMessage({ action = 'HideEl', el = "CD", show = true })
            holdCd, i = HoldingKeyForRespawn(holdCd, i, parsesRequired)
            if holdCd == 0 then
              PlayerRespawn()
              IsAlive = true
              return
            end
          elseif deathCountdown == -1 then
            holdCd = 6
            SendNUIMessage({ action = 'HideEl', el = "CD", show = false })
            SendNUIMessage({ action = 'UpdateMessage', el = "CD", displayMsg = holdCd })
            SendNUIMessage({ action = 'UpdateMessage', el = 'line-4', displayMsg = Config.lang.giveUp })
          end
        end
        --- Blur
        if Config.howLongScreenBlurLasts > 0 then
          blurCountdown = blurCountdown - 1
          if blurCountdown == 0 then
            UnBlur()
          end
        end
        ---
      end
      if i >= parsesRequired then i = 0 end
      i = i + 1
      Wait(timeWait)
    end
    ---
  end)
end

function HoldingKeyForRespawn(holdCd, i, parsesRequired)
  if i == -1 and holdCd >= 5 then
    SendNUIMessage({ action = 'UpdateMessage', el = "CD", displayMsg = holdCd })
  elseif i == parsesRequired then
    holdCd = holdCd - 1
    i = 0
    if holdCd > 0 then
      SendNUIMessage({ action = 'UpdateMessage', el = "CD", displayMsg = holdCd })
    end
  end
  i = i + 1
  return holdCd, i
end

function UpdateNearestMedic()
  CreateThread(function()
    if not Config.showClosestMedic then return end
    local dist = GetClosestMedic()
    local displayMsg
    if isMedicAvaliable then
      DebugPrint2("dist: ", dist)
      dist = math.floor(dist)
      displayMsg = 'Nearest medic is ' .. tostring(dist) .. ' away. Hold tight.'
    else
      displayMsg = Config.lang.noMedicsOnline
    end
    SendNUIMessage({
      action = 'UpdateMessage',
      el = "line-1",
      displayMsg = displayMsg
    })
  end)
end

function GetClosestMedic()
  local p = promise.new()
  QBCore.Functions.TriggerCallback('bm-AmbientHealthUI:GetPlayers', function(Players)
    -- DebugPrint('bm-AmbientHealthUI:GetMedics')
    local Player = QBCore.Functions.GetPlayerData()
    -- DebugPrint2('my source: ', Player.source)
    local myCoords = GetEntityCoords(PlayerPedId())
    -- DebugPrint2('myCoords: ', myCoords)
    local closestDistance = -1
    local foundMedic = false
    --- Cycle through active players
    for _, player in pairs(Players) do
      -- DebugPrint2('other player source: ', player.PlayerData.source)
      --- Skip checking self
      if player.PlayerData.source ~= Player.source then
        --- Check player to see if they have valid role
        for _, role in ipairs(Config.medicJobs) do
          --- If has valid role then get required details.
          if role == player.PlayerData.job.name and player.PlayerData.job.onduty then
            -- DebugPrint2('Medic found: ', player.PlayerData.source)
            foundMedic = true
            local ped = GetPlayerPed(GetPlayerFromServerId(player.PlayerData.source))
            local coords = QBCore.Functions.GetCoords(ped)
            -- DebugPrint2('Medic coords: ', coords)
            local pos = vec3(coords.x, coords.y, coords.z)
            local distance = #(myCoords - pos)
            -- DebugPrint2('distance: ', distance)
            if distance ~= 0.0 and closestDistance == -1 or closestDistance > distance then
              closestDistance = distance
            end
            break
          end
          if foundMedic then break end
          for _, role2 in ipairs(Config.backupMedicJobs) do
            if role2 == player.PlayerData.job.name  and player.PlayerData.job.onduty then
              -- DebugPrint2('Backup Medic found: ', player.PlayerData.source)
              foundMedic = true
              local ped = GetPlayerPed(player.PlayerData.source)
              local coords = QBCore.Functions.GetCoords(ped)
              local pos = vec3(coords.x, coords.y, coords.z)
              local distance = #(myCoords - pos)
              if distance ~= 0 and closestDistance == -1 or closestDistance > distance then
                closestDistance = distance
              end
              break
            end
          end
        end
      end
    end
    ---
    isMedicAvaliable = foundMedic
    p:resolve(closestDistance)
  end)
  local r = tonumber(Citizen.Await(p))
  -- DebugPrint2('closestDistance: ', r)
  return r
end

function DeathScreen()
  CreateThread(function()
    DoScreenFadeOut(1)
    SendNUIMessage({ action = 'Display', el = "footer", show = "none" })
    Wait(6000)
    SendNUIMessage({ action = 'Display', el = "footer", show = "flex" })
    DoScreenFadeIn(3000)
  end)
    Blur()
end

function Blur()
  CreateThread(function() TriggerScreenblurFadeIn(3000) end)
end

function UnBlur()
  CreateThread(function() TriggerScreenblurFadeOut(3000) end)
end

function SecondsToMinutesAndSeconds(seconds)
  local minutes = math.floor(seconds / 60)
  local remainingSeconds = seconds % 60
  return string.format("%02d", minutes), string.format("%02d", remainingSeconds)
end

function UpdateNUITImer(deathCountdown)
  CreateThread(function()
    local minutes, seconds = SecondsToMinutesAndSeconds(deathCountdown)
    SendNUIMessage({ action = 'UpdateMessage', el = "M1", displayMsg = minutes:sub(1, 1) })
    SendNUIMessage({ action = 'UpdateMessage', el = "M2", displayMsg = minutes:sub(2, 2) })
    SendNUIMessage({ action = 'UpdateMessage', el = "S1", displayMsg = seconds:sub(1, 1) })
    SendNUIMessage({ action = 'UpdateMessage', el = "S2", displayMsg = seconds:sub(2, 2) })
  end)
end

-- Handles when a player has decided to respawn by holding the respawn key for X seconds.
function PlayerRespawn()
  DebugPrint2('Function: ', 'PlayerRespawn()')
  Config.functions.respawn()

  SendNUIMessage({ action = 'UpdateMessage', el = 'line-4', displayMsg = "Respawning...." })
  local health = GetEntityHealth(PlayerPedId())
  IsAlive = true
  SendNUIMessage({ action = 'UpdateHp', hp = health, maxHp = 100 })
  SendNUIMessage({ action = 'Display', el = 'footer', show = "none" })
  UnBlur()
end

print("^1[Bob\'s Mods] ^2AmbientHealthUI ^7- ^5Client^7")

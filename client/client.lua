QBCore = exports['qb-core']:GetCoreObject()
local hasStarted = false
local isPingOnCooldown = false
local isAlive = true
local NUIReady = false

AddEventHandler('onResourceStart', function(resourceName)
  DebugPrint2('Function: ', 'onResourceStart')
  DebugPrint2('GetCurrentResourceName(): ', GetCurrentResourceName())
  DebugPrint2('resourceName: ', resourceName)
  if GetCurrentResourceName() ~= resourceName then return end
  StartUp()
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
  if hasStarted then return end
  hasStarted = true
  OpenUI()
  MainThread()
end

function OpenUI()
  DebugPrint2('Function: ', 'OpenUI()')
  SendNUIMessage({ action = 'UpdateMessage', el = "ping-medic-cd", displayMsg = Config.lang.beetweenPings })
  SendNUIMessage({ action = 'UpdateMessage', el = "incapacitated", displayMsg = Config.lang.incapacitated })
  SendNUIMessage({ action = 'UpdateMessage', el = "respawn", displayMsg = Config.lang.giveUpPrior })
end

function MainThread()
  DebugPrint2('Function: ', 'MainThread()')
  local Player = QBCore.Functions.GetPlayerData()
  local health = GetEntityHealth(PlayerPedId())
  local prevHealth = health
  local wasDeadLastLoop = (Player.metadata['inlaststand'] or Player.metadata['isdead'])
  isAlive = not (Player.metadata['inlaststand'] or Player.metadata['isdead'])
  -- OpenUI()
  CreateThread(function()
    local isFirstLoop = true -- This is to check when player loads and is already down or player is down at script restart.
    while hasStarted do
      Wait(100)
      Player = QBCore.Functions.GetPlayerData()
      health = GetEntityHealth(PlayerPedId())
      local isDead = (Player.metadata['inlaststand'] or Player.metadata['isdead'])
      ---
      if (not wasDeadLastLoop and isDead) or (isDead and isFirstLoop) then --and health == 0 and health < prevHealth and isAlive
        PlayerDied()
      elseif health ~= prevHealth and isAlive then
        PlayerTookDamager(health)
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
  isAlive = false
  SendNUIMessage({ action = 'UpdateHp', hp = 0, maxHp = 200 - 100 })
  SendNUIMessage({ action = 'Died', timer = Config.LastStandTime })
  SendNUIMessage({ action = 'UpdateMessage', el = "respawn", displayMsg = Config.lang.giveUpPrior })
  local displayMsg
  if Config.willAutoPingMedic then
    PingMedic()
    displayMsg = Config.lang.EMSNotified
  else
    displayMsg = Config.lang.pingMedic
  end
  SendNUIMessage({ action = 'UpdateMessage', el = "ping-medic", displayMsg = displayMsg })
  DeadTimer()
  -- CheckForKeyPressThread()
end

function PlayerTookDamager(health)
  DebugPrint('--- Current health different to prevHealth ---')
  SendNUIMessage({
    action = 'UpdateHp',
    hp = health - 100,
    maxHp = 200 - 100
  })
end

function PlayerWasRevived(health)
  DebugPrint('--- Player was revived ---')
  isAlive = true
  SendNUIMessage({ action = 'Display', el = "footer", show = "none" })
  SendNUIMessage({ action = 'Revived', hp = health - 100, maxHp = 200 - 100 })
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
    local deathCountdown = Config.LastStandTime + 1
    local pingCoooldown = Config.TimeBetweenEMSPings + 1
    local isPingOnCoolDown = Config.willAutoPingMedic
    local timeWait = 50                   -- Pick a number that is lower and devisable to 1000
    local parsesRequired = 1000 / timeWait -- How many iterations in loop are required to be ~ 1 second.
    local i = parsesRequired
    local holdCd = 5
    ---
    while not isAlive do
      if IsControlPressed(0, Config.key.pingMedic) then
        if not isPingOnCoolDown then
          PingMedic()
          pingCoooldown = Config.TimeBetweenEMSPings + 1
          isPingOnCoolDown = true
          SendNUIMessage({ action = 'UpdateMessage', el = "ping-medic", displayMsg = Config.lang.EMSNotified })
          SendNUIMessage({
            action = 'UpdateMessage',
            el = "ping-medic-cd",
            displayMsg = Config.lang.pingCooldown ..
                " (" .. pingCoooldown .. ")"
          })
          if not Config.canRespawnOnCooldown then SendNUIMessage({ action = 'UpdateMessage', el = "respawn", displayMsg = Config.lang.giveUponCooldown }) end
        end
      end
      if i == parsesRequired then
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
        if isPingOnCoolDown then
          pingCoooldown = pingCoooldown - 1
          SendNUIMessage({
            action = 'UpdateMessage',
            el = "ping-medic-cd",
            displayMsg = Config.lang.pingCooldown ..
                " (" .. pingCoooldown .. ")"
          })
          if pingCoooldown <= 0 then
            isPingOnCoolDown = false
            SendNUIMessage({ action = 'UpdateMessage', el = "ping-medic", displayMsg = Config.lang.pingMedic })
            SendNUIMessage({ action = 'UpdateMessage', el = "ping-medic-cd", displayMsg = Config.lang.beetweenPings })
          end
        end
        --- GIVE UP
        if not Config.canRespawnOnCooldown and isPingOnCoolDown then
          SendNUIMessage({ action = 'UpdateMessage', el = "respawn", displayMsg = Config.lang.giveUponCooldown })
          SendNUIMessage({ action = 'HideEl', el = "CD", show = false })
          holdCd = 5
        else
          if IsControlPressed(0, Config.key.giveUp)
              and deathCountdown == -1
              and holdCd > 0 then
            SendNUIMessage({ action = 'UpdateMessage', el = "respawn", displayMsg = "Keep holding to respawn..." })
            SendNUIMessage({ action = 'HideEl', el = "CD", show = true })
            holdCd, i = HoldingKeyForRespawn(holdCd, i, parsesRequired)
            if holdCd == 0 then
              PlayerRespawn()
              isAlive = true
              return
            end
          elseif deathCountdown == -1 then
            holdCd = 5
            SendNUIMessage({ action = 'HideEl', el = "CD", show = false })
            SendNUIMessage({ action = 'UpdateMessage', el = "CD", displayMsg = holdCd })
            SendNUIMessage({ action = 'UpdateMessage', el = "respawn", displayMsg = Config.lang.giveUp })
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
  if i == 0 and holdCd >= 5 then
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
  SendNUIMessage({ action = 'UpdateMessage', el = "respawn", displayMsg = "Respawning...." })
  local health = GetEntityHealth(PlayerPedId())
  isAlive = true
  SendNUIMessage({ action = 'Revived', hp = health - 100, maxHp = 200 - 100 })
end

print("^1[Bob\'s Mods] ^2AmbientHealthUI ^7- ^5Client^7")

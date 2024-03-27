Config = {


  Debug = true,                 -- Toggle debug messages on and off.
  LastStandTime = 5,            -- Seconds
  TimeBetweenEMSPings = 5,     -- Seconds - How often can a player ping EMS while down
  willAutoPingMedic = false,    -- When a player is downed, will EMS got an automatic ping?
  canRespawnOnCooldown = false, -- Can a player force response during ping cooldown?
  -- willAutoRespawn = false, -- COMING: When timer is up will player auto response

  key = {           -- https://docs.fivem.net/docs/game-references/controls/#controls
    pingMedic = 47, -- G
    giveUp = 38,    -- E
  },

  functions = {
    -- respawn : Function to run when player choose to respawn
    respawn = function()
      TriggerEvent('hospital:client:RespawnAtHospital')
      TriggerServerEvent('hospital:server:ambulanceAlert', "Civ taken to LSMC")
    end,
    -- pingMedic : Function to ping medic when player is down.
    pingMedic = function()
      TriggerServerEvent('hospital:server:ambulanceAlert', "Civ down")
    end,
  },

  lang = {
    incapacitated = "You are incapacitated",
    EMSNotified = "Medics have been notified. Please wait for rescue.",
    pingMedic = "Press [G] to alert medical services.",
    giveUpPrior = "Wait for medic or timer to reach zero.",
    giveUp = "Hold [E] to wake up at LSMC. All items on person will be lost.",
    giveUponCooldown = "You cannot respawn during ping cooldown",
    pingCooldown = "Ping cooldown",
    beetweenPings = "or"
  }
}

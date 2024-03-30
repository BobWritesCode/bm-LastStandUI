Config = {

  Debug = true,                 -- Toggle debug messages on and off.
  LastStandTime = 300,           -- Seconds - Last stand time if medic or backup avaliable.
  noMedicLastStandTime = 60,     -- Seconds - Last stand time if no medic or backup avaliable.
  TimeBetweenEMSPings = 120,     -- Seconds - How often can a player ping EMS while down
  willAutoPingMedic = false,     -- When a player is downed, will EMS got an automatic ping?
  canRespawnOnCooldown = false,  -- Can a player force response during ping cooldown?
  showClosestMedic = true,       -- Will distance to the cloestest medic be shown to the player
  shouldScreenBlur = true,
  howLongScreenBlurLasts = -1, -- Set it -1 perm while down, or number of seconds.
  -- willAutoRespawn = false, -- COMING: When timer is up will player auto response

  medicJobs = {'ambulance', 'ems'}, -- List of all roles that are medics. i.e. {'ambulance', 'leo'}
  backupMedicJobs = {'leo', 'police'}, -- List of roles that will take over as medics if no EMS is avaliable.

  key = {           -- https://docs.fivem.net/docs/game-references/controls/#controls
    pingMedic = 47, -- G
    giveUp = 38,    -- E
  },

  functions = {
    -- respawn : Function to run when player choose to respawn. (called Client side)
    respawn = function()
      TriggerEvent('hospital:client:RespawnAtHospital')
      TriggerServerEvent('hospital:server:ambulanceAlert', "Civ taken to LSMC")
    end,
    -- pingMedic : Function to ping medic when player is down. (called Client side)
    pingMedic = function()
      TriggerServerEvent('hospital:server:ambulanceAlert', "Civ down")
    end,
  },

  lang = {
    incapacitated = "You are incapacitated",
    EMSNotified = "Medics have been notified. Please wait for rescue.",
    pingMedic = "Press [G] to alert medical services.",
    giveUpPrior = "Wait for medic or timer to reach zero.",
    noMedicGiveUpPrior = 'Wait for for timer to reach zero.',
    giveUp = "Hold [E] to wake up at LSMC. All items on person will be lost.",
    giveUponCooldown = "You cannot respawn during ping cooldown",
    pingCooldown = "Ping cooldown",
    beetweenPings = "or",
    noMedicsOnline = 'No medics avaliable at this time.',
    noOneToPing = 'You should have been more careful.',
    yourOnlyOption = 'Take this time to think about your actions.'
  }
}

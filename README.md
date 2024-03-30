# [Bob's Mods] Last Stand UI

## WORK IN PROGRESS NOT CLOSE TO FINISH - DO NOT USE

Free free to bookmark, to get the latest updates.

## Description

This script provides an updated last stand UI.

## Features

- Unique on screen ambient damage visual
- Fully customisable config
- Death camera

## Important to note

- You will require some basic knowledge on how to locate code inside qb-ambulancejob and to either delete or comment that code out. If you are a server dev this should be simple for you. The installation instructions may vary based on if you have already edited the code before or using a different version on the code.

## Dependencies

- QB-Core

## Screenshots

![Last Stand UI](https://i.imgur.com/ObKuQwE.png)

## Installation

You need to make the following changes in qb-ambulancejob if you are using this as your respawner.\
**IMPORTANT:** This is based on version 1.2.4. If you are using a different version then this may vary

### qb-ambulance job changes

#### client.lua

- Go to qb-ambulancejob/client/client.lua
- Comment out line 121.

```lua
DeathTimer()
```

#### dead.lua

- Go to qb-ambulancejob/client/dead.lua
- Comment out lines 54.

```lua
TriggerServerEvent('hospital:server:ambulanceAlert', Lang:t('info.civ_died'))
```

- Go to qb-ambulancejob/client/dead.lua
- Comment out lines 59 to 81.

```lua
function DeathTimer()
    hold = 5
    while isDead do
        Wait(1000)
        deathTime = deathTime - 1
        if deathTime <= 0 then
            if IsControlPressed(0, 38) and hold <= 0 and not isInHospitalBed then
                TriggerEvent('hospital:client:RespawnAtHospital')
                hold = 5
            end
            if IsControlPressed(0, 38) then
                if hold - 1 >= 0 then
                    hold = hold - 1
                else
                    hold = 0
                end
            end
            if IsControlReleased(0, 38) then
                hold = 5
            end
        end
    end
end
```

- Go to qb-ambulancejob/client/client.lua
- Comment out lines 154 to 160.

```lua
if not isInHospitalBed then
    if deathTime > 0 then
        DrawTxt(0.93, 1.44, 1.0, 1.0, 0.6, Lang:t('info.respawn_txt', { deathtime = math.ceil(deathTime) }), 255, 255, 255, 255)
    else
        DrawTxt(0.865, 1.44, 1.0, 1.0, 0.6, Lang:t('info.respawn_revive', { holdtime = hold, cost = Config.BillCost }), 255, 255, 255, 255)
    end
end
```

- Go to qb-ambulancejob/client/dead.lua
- Comment out lines 182 to 199.

```lua
elseif InLaststand then
    sleep = 5

    if LaststandTime > Config.MinimumRevive then
        DrawTxt(0.94, 1.44, 1.0, 1.0, 0.6, Lang:t('info.bleed_out', { time = math.ceil(LaststandTime) }), 255, 255, 255, 255)
    else
        DrawTxt(0.845, 1.44, 1.0, 1.0, 0.6, Lang:t('info.bleed_out_help', { time = math.ceil(LaststandTime) }), 255, 255, 255, 255)
        if not emsNotified then
            DrawTxt(0.91, 1.40, 1.0, 1.0, 0.6, Lang:t('info.request_help'), 255, 255, 255, 255)
        else
            DrawTxt(0.90, 1.40, 1.0, 1.0, 0.6, Lang:t('info.help_requested'), 255, 255, 255, 255)
        end

        if IsControlJustPressed(0, 47) and not emsNotified then
            TriggerServerEvent('hospital:server:ambulanceAlert', Lang:t('info.civ_down'))
            emsNotified = true
        end
    end
```

#### job.lua

- Go to qb-ambulancejob/client/job.lua
- Comment out line 127.

```lua
DeathTimer()
```

#### laststand.lua

- Go to qb-ambulancejob/client/laststand.lua
- Comment out line 71.

```lua
TriggerServerEvent('hospital:server:ambulanceAlert', Lang:t('info.civ_down'))
```

- Go to qb-ambulancejob/client/laststand.lua
- Comment out line 100.

```lua
DeathTimer()
```

## License

```.
[Bob's Mods] Last Stand UI
Copyright (C) 2024

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>
```

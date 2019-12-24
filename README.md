# Ham Radio

![Ham Radio screenshot](screenshot.png?raw=true)

This mod brings radio transmitters and receivers to the Minetest world.

Dependencies:
```
default
basic_materials?
technic?
digilines?
```
Craft recipes depend of the mods installed.

## Transmitter

Craft a transmitter and place it in the world. Right click on transmitter to open configuration dialog, then set frequency and RDS message.
- Empty frequency turns transmitter off.
- Transmitter information is displayed as info text when player points at it.
- RDS message can be multiline. However, it is transmitted line by line.
- RDS message and frequency can be set via digiline. Also, you can read transmitter configuration via digiline too.

## Beacon

Beacon is a simplified transmitter. After placement it automatically tunes on a random unoccupied frequency from predefined range. Beacon frequency range is determined by `beacon_frequency` setting.
- Beacon frequency is displayed as info text when player points at it.

## Receiver

Handheld receiver is a wielded tool.

- Left click opens configuration dialog to set frequency. Empty string turns receiver off.
- Shift + left click toggles reception of RDS messages.

When receiver is tuned to a frequency where at least one transmitter is present, HUD signal meter bar shows signal power. The signal power depends on distance and direction to the transmitter.

If RDS reception is toggled on, the RDS messages from all transmitters on this frequency are enqueued and will be send one by one as a chat messages to the player with 10 seconds interval. When RDS message queue becomes empty, it refills and starts over again.

## Stationary Receiver

Right click on receiver opens configuration window to set frequency. Receiver displays RDS messages as infotext in the same way as handheld receiver. It does not have signal power meter.
- You can operate the receiver via digiline in the same way as the transmitter.

## Digiline

```lua
-- channel "ham_radio_rds" accepts plain text
digiline.send('ham_radio_rds', 'new RDS message')

-- get transmitter info
digiline.send('ham_radio', { command = 'get' })
-- returns { frequency = 12345, rds_message = 'text' }

-- set frequency
digiline.send('ham_radio', { command = 'set_frequency', value = '12345' })
-- returns { update = 'frequency', success = true/false, message = errorMessage }

-- set RDS message
digiline.send('ham_radio', { command = 'set_rds_message', value = 'new RDS message' })
-- returns { update = 'rds_message', success = true }

-- get receiver info
digiline.send('ham_radio_receiver', { command = 'get' })
-- returns { frequency = 12345, rds_message = 'text' }

-- set receiver frequency
digiline.send('ham_radio_receiver', { command = 'set_frequency', value = '12345' })
-- returns { update = 'frequency', success = true/false, message = errorMessage }
```

## Config

See `config.lua` to see current parameters. You can edit this file to change them.

Default parameters:
 - Frequency range: 0 - 9999999
 - Locked frequency range: 100000 - 9999999 
    - Only one transmitter is allowed for the frequency in this range.
 - Beacon frequency range: 1000000 - 99999999 
   - Beacon frequency is auto-assigned from this range. 
   - Please note, this range overlaps with locked frequency range to ensure each beacon receives unique frequency.
 - RDS interval: 10 seconds
   - This setting affects handheld receivers only. The interval should be high enough to avoid spamming chat with repeated messages.
   - RDS interval for stationary receiver is 5 seconds and can't be changed.

## What's next?

- Place beacons or transmitters anywhere in the world, give frequency to other players and let them search for them
- Pick a frequency which all players can use for their announcements to organize radio bulletin board
- Operate your transmitters with digiline to receive notification on radio
- ???
- PROFIT

## Author and license

(c) techniX 2019

Source code: MIT

Textures: CC BY-SA 3.0

Sounds: cut from "G32-20-Tuning Radio" by craigsmith, CC 0

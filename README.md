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
- RDS message and frequency can be set via digiline. Also, you can read transmitter configuration via digiline too.

## Beacon

Beacon is a simplified transmitter. After placement it automatically tunes on a random unoccupied frequency from predefined range. Beacon frequency range is determined by `beacon_frequency` setting.
- Beacon frequency is displayed as info text when player points at it.

## Receiver

Handheld receiver is a wielded tool.

- Left click opens configuration dialog to set frequency. Empty string turns receiver off.
- Right click toggles reception of RDS messages.

When receiver is tuned to a frequency where at least one transmitter is present, HUD signal meter bar shows signal power. The signal power depends on distance and direction to the transmitter. 

If RDS reception is toggled on, the RDS messages from all transmitters on this frequency are enqueued and will be send one by one as a chat messages to the player with 10 seconds interval. When RDS message queue becomes empty, it refills and starts over again.

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



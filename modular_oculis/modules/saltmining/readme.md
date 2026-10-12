https://github.com/OculisStation/OculisStation/pull/276
//DONT FORGET TO GET THE PULL REQUEST ID LATER BOZO

## Salted Zens Mega Mining Items Port

Module ID: SALTMINING

### Description: Why Is It So ORANGE

Adds a bunch of mining gear that I (Salted-Zen) created for monkestation
and a change that nerfs them a little in pvp (by notghosti)

Adds the following (summarized)

Surplus Necropolis Crates (Purchaseable tendril crates)
PKShockwave Rework (No more point blank)
PKSMG (The first limited ammo weapon, full auto)
PKShotgun rework (The slayer, the second limited ammo gun)
Arsenal Upgrade (Large package that includes 3 crushers, 5 limited ammo guns, and 3 backpacks)

Topped off with Ice-Types add fauna modifier to projectiles
and notghosti's wasteland weapons less effective on non waste creatures (aka make fauna_mod do something)
These are slightly modified in this module by me but the code is taken pretty much straight from these two so im giving them credit.

### TG Proc/File Changes: Help

### Modular Overrides: Oh God

### Defines: We got... alot

There is a new define added in a core file, due to its nature it was better to put it there.

code/\_\_DEFINES/computers.dm (Added the "Wasteland Weapons" Define for categories)
Change is on lines 14 - This define is used in the core file for mining orders, please see below.

modular_oculis/modules/saltmining/code/\_saltmining.dm
This one is in the module, but contains a ton of new defines to add a ton of extra ammo types exclusive for mining guns.
The list is as follows
MINER_SHOTGUN "kinetic shotgun" (Slayer / Goliath Hunter)
CALIBER_GOV_MINING ".45-70 Gov Mining" (Duster / Venator)
KINETIC_20G "20 Gauge Mining Shell" (Fenrir)
CALIBER_A762_KINETIC "7.65 Mining" (Hellhound)
CALIBER_MINER_950 ".950 JDJ Lightning" (Thor)

### Included files that are not contained in this module: Please Read

There are a few changes to core files due to the way things are coded, as to prevent errors.

code/modules/projectiles/guns/energy/kinetic_accelerator.dm (Added a toggleble "skillbased" variable and modified the kinetic projectile to account for this variable)
Changes are on lines 198 and 263

code/modules/projectiles/projectile.dm (Added lavafauna_mod variable to allow adding a multiplier for damage versus lavaland fauna. Also added a portion of code that makes this actually work)
Changes are on lines 275 and 409

code/game/machinery/computer/orders/order_computer/mining_order.dm (Added the category "Wasteland Weapons" to the shaft miner console)
Change is on lines 25, for the define please see above in defines.

modular_nova/modules/mapping/code/interdyne_mining.dm (Added the category "Wasteland Weapons" to interdynes mining console)
Change is on lines 18

code/datums/storage/subtypes/belts.dm (added all the ammos and their boxes to the explorer webbing, giving webbing more utility as small ammo storage)
Change is on lines 174 all the way to 197

modular_nova/modules/mining_pka/code/projectiles.dm (Commented out old defunct shockwave ammo casing so it could be moved into this module)
Change is on lines 17

modular_nova/modules/mining_crushers/code/crusher_conversion_kit.dm (Added into the kit the pilebunker and sickle so they can be attained)
Change is on lines 24 and 25

code/game/objects/effects/spawners/random/mining_loot.dm (Replaced power miner shard with wolf cloak)
Change is on lines 20

modular_nova/modules/mining_crushers/code/miningweapons.dm (Upgraded machete to 15 base and removed the two handed component, also buffed block chance to 25% - These changes bring the machete more in line with how I originally designed and planned it to be. Also removes two handing on the claws for the same reason as machete)
Change is on lines 25, 27, 53, and 218

code/datums/status_effects/neutral.dm (Changed the status effect that tracks crusher damage to always start at 100,000 damage, thus making a single detonation give crusher drop eligability)
Change is on lines 10

### Credits: Salted-Zen (made mostly everything, not fauna multipliers), notghosti, Ice-Type (Made the code for fauna multipliers on projectiles), Dwasint (Quad Shotgun sounds used on the Thor)

im cryin so many errors in here

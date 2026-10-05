https://github.com/OculisStation/OculisStation/pull/312

## Belt Satchels

Module ID: BELT_SATCHELS

### Description:

Allows satchels to be worn on the belt, in exchange for holding less and slowing you when paired with a backpack on your back.

In specific, allows `/obj/item/storage/backpack/satchel/`s to be worn on the belt, and slows you when you have a `/obj/item/storage/backpack/` on both your belt and back.

### TG Proc/File Changes:

- N/A

### Modular Overrides:

- `modular_oculis/master_files/code/game/objects/items/storage/backpack.dm`:
  - `/obj/item/storage/backpack/proc/equipped`
  - `/obj/item/storage/backpack/proc/dropped`
  - `/obj/item/storage/backpack/satchel/proc/Initialize`
  - `/obj/item/storage/backpack/satchel/var/slot_flags`

### Defines:

- `code\__DEFINES\~~oculis_defines\storage.dm`:
  - `PAIRED_STORAGE_DEFAULT_SLOWDOWN`

### Included files that are not contained in this module:

- N/A

### Credits:

- Shroopy - module creator
- [Monkestation](https://github.com/Monkestation/Monkestation2.0) - original source of the ported belt satchel code

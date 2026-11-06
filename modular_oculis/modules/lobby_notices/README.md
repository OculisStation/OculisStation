<!-- This should be copy-pasted into the root of your module folder as readme.md -->

https://github.com/OculisStation/OculisStation/pull/<!--PR Number-->

## Lobby Notices<!--Title of your addition.-->

Module ID: lobby_notices

### Description:

JSON example of how lobby_notices.json works.

```
[
	"this notice will show in both the chatbox, and tgui. will do HTML like the others but using classes that are used in the chatbox will not show in tgui as they are separate",
	{
		"TGUI_SAFE": "This shows in tgui! <span style='font-size: 110%'>you can also use html! but not the classes used the chatbox, as said above</span>",
		"CHATBOX_SAFE": "This shows in tgui! <span class='bold red'>(with special formatting!)</span>."
	},
	{
		"TGUI_SAFE": [
			"this is the first line",
			"this is the second line. notice how this object doesn't have a chatbox_safe?",
			"that means it'll only show in Tgui"
		]
	}
]
```

### TG Proc/File Changes:

- N/A
<!-- If you edited any core procs, you should list them here. You should specify the files and procs you changed.
E.g:
- `code/modules/mob/living.dm`: `proc/overriden_proc`, `var/overriden_var`
  -->
- `code/controllers/configuration/configuration.dm`
- - `/datum/controller/configuration/proc/Load`: Added `LoadMisc`
- `code/controllers/subsystem/ticker.dm`
- - `/datum/controller/subsystem/ticker/fire()`

### Modular Overrides:

- N/A
<!-- If you added a new modular override (file or code-wise) for your module, you should list it here. Code files should specify what procs they changed, in case of multiple modules using the same file.
E.g:
- `modular_oculis/master_files/sound/my_cool_sound.ogg`
- `modular_oculis/master_files/code/my_modular_override.dm`: `proc/overriden_proc`, `var/overriden_var`
  -->

### Defines:

- N/A
<!-- If you needed to add any defines, mention the files you added those defines in, along with the name of the defines. -->

### Included files that are not contained in this module:

- `config/oculis/lobby_notices.json`
- `tgui/packages/tgui/interfaces/Common/oculis/LobbyNotices.tsx`
- `tgui/packages/tgui/interfaces/Changelog.jsx`
- `tgui/packages/tgui/interfaces/JobSelection.tsx`

### Credits:

Flleeppyy

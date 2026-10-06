[https://github.com/OculisStation/OculisStation/pull/<!--PR Number-->](https://github.com/OculisStation/OculisStation/pull/1)

## Plexora Support

Module ID: PLEXORA

### Description:

Support for the Plexora discord bot, used for things such as server status, administration, etc.

### TG Proc/File Changes:

- `code/controllers/failsafe.dm`
  - `/datum/controller/failsafe/proc/Loop()`: Plexora notifications for MC failure
  - `/proc/recover_all_SS_and_recreate_master()`: Plexora notifications for MC recreation
- `code/controllers/master.dm`
  - `/datum/controller/master/Initialize()`: Plexora notifications for when MC finished init
- `code/datums/mocking/client.dm`
  - `/datum/client_interface/New(key)`: added the `key` arg
- `code/datums/http.dm`
  - `/datum/http_request/proc/prepare()`: Adds a default user-agent
- `code/datums/world_topic.dm`
  - `/datum/world_topic/proc/TryRun()`: JSON support added
- `code/game/world.dm`
  - `/world/Reboot()`: Plexora notification for server reboot
- `code/modules/admin/verbs/adminhelp.dm`
  - `CHECK_AHELP_ACTIVE` macro
  - `/datum/admin_help_tickets/proc/ClientLogin()`: Plexora notification for when user in a ticket reconnects
  - `/datum/admin_help_tickets/proc/ClientLogout()`: Plexora notification for when user in a ticket disconnects
  - `/datum/admin_help/New()`: Notifying Plexora when a new ticket is created
  - `/datum/admin_help/proc/Reopen()`: Notifying Plexora when a ticket is reopened
  - `/datum/admin_help/proc/Action()`: Notifying Plexora of various ticket actions/state updates
- `code/modules/admin/verbs/adminpm.dm`
  - `/client/proc/sends_adminpm_message()`: Plexora integration, and fixing some encode issues
- `code/modules/admin/verbs/adminsay.dm`
  - `ADMIN_VERB(cmd_admin_say)`: Relaying asays through Plexora.
- `code/modules/admin/verbs/server.dm`
  - `ADMIN_VERB(restart)`: Plexora notifications for admin-triggered server reboots.
- `code/modules/admin/chat_commands.dm`
  - `/datum/tgs_chat_command/validated/Run()`: Change `SSdiscord.lookup_ckey` reference to `SSplexora.lookup_ckey`
- `code/modules/admin/IsBanned.dm`
  - `/world/IsBanned()`: Discord verification support.
- `code/modules/admin/sql_ban_system.dm`
  - `/datum/admins/proc/create_ban()`: Plexora notifications for bans.
- `code/modules/admin/sql_message_system.dm`
  - `/proc/create_message()`: Plexora notifications for notes.
- `code/modules/discord/accountlink.dm`: **REMOVED**
- `code/modules/discord/tgs_commands.dm`
  - `/datum/tgs_chat_command/notify` **REMOVED**, as Plexora's functionality replaces it
- `code/modules/discord/toggle_notify.dm` **REMOVED**
- `code/modules/error_handler/error_handler.dm`: OOM notify call
- `code/modules/interview/interview.dm`
  - `/datum/interview/New()`, `/datum/interview/proc/approve()`, `/datum/interview/proc/deny()`: Plexora notifications for interviews.

### Modular Overrides:

- N/A

### Defines:

- `code/__DEFINES/~~oculis_defines/admin.dm`: `AHELP_CLOSETYPE_*` and `AHELP_CLOSEREASON_*` defines
- `code/__DEFINES/~~oculis_defines/plexora.dm`: many `PLEXORA_*` defines
- `code/__DEFINES/subsystems.dm`: `FIRE_PRIORITY_PLEXORA`

### Included files that are not contained in this module:

- N/A

### Credits:

Flleeppyy

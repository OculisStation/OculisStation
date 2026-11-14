/datum/experiment/physical/slap_someone
	name = "Investigate Facial Nociceptive Response"
	description = "We were wondering exactly how nociceptive stimuli are processed by humanoid facial musculature. Slap a tracked humanoid in the face. Hard. Not yourself, obviously."

/datum/experiment/physical/slap_someone/register_events()
	if(!ishuman(currently_scanned_atom))
		linked_experiment_handler.announce_message("Incorrect object for experiment.")
		return FALSE

	RegisterSignal(currently_scanned_atom, COMSIG_LIVING_SLAPPED, PROC_REF(check_experiment))
	linked_experiment_handler.announce_message("Experiment ready to start.")
	return TRUE

/datum/experiment/physical/slap_someone/unregister_events()
	UnregisterSignal(currently_scanned_atom, COMSIG_LIVING_SLAPPED)

/datum/experiment/physical/slap_someone/check_progress()
	. += EXPERIMENT_PROG_BOOL("Slap a tracked person (not yourself) in the face.", is_complete())

/datum/experiment/physical/slap_someone/proc/check_experiment(mob/living/slapped, mob/living/slapper)
	SIGNAL_HANDLER
	if((slapper.zone_selected == BODY_ZONE_HEAD) && (slapper != slapped))
		UnregisterSignal(currently_scanned_atom, COMSIG_LIVING_SLAPPED)
		finish_experiment(linked_experiment_handler)

/datum/quirk/affluent
	name = "Affluent"
	desc = "You've got a net worth and the extra credits to show for it; every time you get your wage, you get a bonus."
	value = 4
	quirk_flags = QUIRK_HIDE_FROM_SCAN | QUIRK_EXCLUDES_GHOSTROLES
	icon = FA_ICON_MONEY_CHECK_DOLLAR
	medical_record_text = "Light subtly bends around the patient, suggesting a high Weiss-Wiesemann/Rougon-Macquart coefficient."
	var/payday_bonus = PAYCHECK_COMMAND

/datum/quirk/affluent/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!human_holder.account_id)
		return
	var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[human_holder.account_id]"]
	RegisterSignal(account, COMSIG_PAYDAY_RECEIVED, PROC_REF(on_payday))
	to_chat(client_source.mob, span_notice("Feels good to be wealthy."))

/datum/quirk/affluent/proc/on_payday(datum/bank_account/source)
	SIGNAL_HANDLER
	source.account_balance += payday_bonus
	source.bank_card_talk("Bonus processed, account now holds [source.account_balance] [MONEY_SYMBOL].")

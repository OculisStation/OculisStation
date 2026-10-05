/datum/emote/roll
	key = "roll"
	affected_by_pitch = FALSE
	message = null

/datum/emote/roll/run_emote(mob/user, params, type_override, intentional)
	// Check if its a valid dice combination.
	if(!findtext(params, regex("\\d+d\\d+", "g"))) // Example: 1d20
		to_chat(user, span_warning("That's not a valid dice combination! Please use the combination of \[dice amount\]d\[dice sides\] and optionally \[+-number\] or \[reason\]! Like so: 2d20 or 2d20+5 or 2d20+5 reason."))
		return FALSE

	// Do we have a reason given?
	var/reason
	var/list/split_text = splittext(params, " ") // This can actually have more than one word in the reason
	var/dice_text = split_text[1] // so we take the first part (the dice and modifier)
	split_text -= dice_text // and set it aside
	if(length(split_text)) // and make the rest the reason.
		reason = jointext(split_text, " ")

	// Do we have a modifier?
	var/found_modifier = findtext(dice_text, regex("\[+-\]\\d+", "g"))
	var/modifier = found_modifier ? copytext(dice_text, found_modifier, 0) : null // Example: +10
	var/list/text_without_modifier
	if(modifier)
		text_without_modifier = splittext(dice_text, modifier)
	else
		text_without_modifier = list(dice_text)

	// Time to do actual dice calculations. And sanitization.
	var/list/split_dice_text = splittext(text_without_modifier[1], "d")
	// If at this point we ever have anything that isnt a normal number, take the first number and ignore the rest.
	var/dice_count = copytext(split_dice_text[1], 1, splittext(split_dice_text[1], regex("\\d+"))) // Example: 10
	var/dice_sides = copytext(split_dice_text[2], 1, splittext(split_dice_text[2], regex("\\d+"))) // Example: 5

	// Roll the dice.
	var/dice_rolled = list()
	var/total = 0
	for(var/i in 1 to text2num(dice_count))
		var/rolled = rand(1, text2num(dice_sides))
		dice_rolled += rolled
		total += rolled
	total += text2num(modifier)

	var/long_message = "[user] rolls [dice_count]d[dice_sides][modifier] and gets [jointext(dice_rolled, "+")][modifier]=[total].[reason ? " Reason: [reason]" : null]"
	if(length(long_message) <= MAX_MESSAGE_LEN && text2num(dice_count) > 1)
		user.client?.looc_message(long_message)
	else
		user.client?.looc_message("[user] rolls [dice_count]d[dice_sides][modifier] and gets [total].[reason ? " Reason: [reason]" : null]")
	params = null
	return ..()

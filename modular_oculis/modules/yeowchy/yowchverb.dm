GAME_VERB_DESC(/mob/living, ouch_thyself, "Ouch Thyself", "Deal damage to yourself.", "IC")
	set category = "IC"
	set name = "Ouch Thyself"
	set desc = "Allows you to damage yourself. Ough."

	var/unfunnyjoke = pick(list("Select Yeowchies", "I hurt myself... today...", "Damage Types", "Pick Thy Poison", "Applicable Pithy Quote", "Dumb Ways To Die", "Toe Stubbage Device"))
	if(prob(0.1))
		unfunnyjoke = "In 1998, The Undertaker"
	var/damagetype = tgui_input_list(src, "Select a damage type:", unfunnyjoke, list(BRUTE, BURN, TOX, OXY, STAMINA, "Blood"))
	if(!damagetype)
		return
	var/damageamount = tgui_input_number(src, "How much damage should you take:", "Quantify Ouches", 0, HUMAN_MAXHEALTH * 2, 0) // max health goes from full to crit, so that times 2 is from full to death.
	if(!damageamount)
		return
	var/tobodyzone = FALSE
	if(damagetype in list(BRUTE, BURN))
		tobodyzone = (tgui_alert(src, "Would you like this damage to be to your selected bodyzone?", "Oughghhghghghghhhh", list("Yes", "No")) == "Yes")
	switch(damagetype)
		if(TOX)
			adjust_tox_loss(damageamount, forced = TRUE)
		if(OXY)
			adjust_oxy_loss(damageamount)
		if("Blood")
			adjust_blood_volume(-damageamount, 0, INFINITY)
		if(STAMINA)
			adjust_stamina_loss(damageamount)
		if(BURN)
			if(tobodyzone)
				apply_damage(damageamount, BURN, zone_selected)
			else
				adjust_fire_loss(damageamount)
		if(BRUTE)
			if(tobodyzone)
				var/typeofbruteselection = tgui_alert(src, "What kinda brute damage we talking?", "Select attack type", list("Bashing", "Piercing", "Lacerating"))
				var/options = list("Bashing" = 0, "Lacerating" = SHARP_EDGED, "Piercing" = SHARP_POINTY)
				var/chosenoption = options[typeofbruteselection]
				apply_damage(damageamount, BRUTE, zone_selected, sharpness = chosenoption)
			else
				adjust_brute_loss(damageamount)

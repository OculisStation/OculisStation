/// Sound effect datums for randomized phone sounds
/datum/sound_effect/phone_rtb_handset
	file_paths = list(
		'modular_iris/modules/phone/sound/rtb_handset_1.ogg',
		'modular_iris/modules/phone/sound/rtb_handset_2.ogg',
		'modular_iris/modules/phone/sound/rtb_handset_3.ogg',
		'modular_iris/modules/phone/sound/rtb_handset_4.ogg',
		'modular_iris/modules/phone/sound/rtb_handset_5.ogg',
	)

/datum/looping_sound/phone_ringing
	start_sound = list('modular_iris/modules/phone/sound/telephone_ring.ogg' = 1)
	mid_sounds = list('modular_iris/modules/phone/sound/telephone_ring.ogg' = 1)
	volume = 25
	extra_range = 14
	mid_length = (3 SECONDS)
	max_loops = 10

/datum/looping_sound/telephone/ring
	start_sound = 'modular_iris/modules/phone/sound/dial.ogg'
	start_length = 3.2 SECONDS
	mid_sounds = 'modular_iris/modules/phone/sound/ring_outgoing.ogg'
	mid_length = 2.1 SECONDS
	volume = 10

/datum/looping_sound/telephone/busy
	start_sound = 'modular_iris/modules/phone/sound/phone_busy.ogg'
	start_length = 5.7 SECONDS
	mid_sounds = 'modular_iris/modules/phone/sound/phone_busy.ogg'
	mid_length = 5 SECONDS
	volume = 15

/datum/looping_sound/telephone/hangup
	start_sound = 'modular_iris/modules/phone/sound/remote_hangup.ogg'
	start_length = 0.6 SECONDS
	mid_sounds = 'modular_iris/modules/phone/sound/phone_busy.ogg'
	mid_length = 5 SECONDS
	volume = 15

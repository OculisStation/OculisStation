/datum/job/octavia
	title = ROLE_OCTAVIA
	policy_index = ROLE_OCTAVIA
	paycheck = PAYCHECK_CREW
	bounty_types = DYNE_JOB_SCIENCE
	paycheck_department = ACCOUNT_DS2

/datum/job/octavia/prisoner
	title = ROLE_OCTAVIA
	policy_index = ROLE_OCTAVIA
	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_RANDOM
	paycheck_department = null

/datum/job/octavia/command
	bounty_types = DS2_JOB_COMMAND
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_DS2
	head_announce = list(RADIO_CHANNEL_CYBERSUN)

/datum/job/octavia/engineer
	bounty_types = DS2_JOB_ENGINEER
	paycheck_department = ACCOUNT_DS2

/datum/job/octavia/science
	bounty_types = DS2_JOB_MECHANICAL
	paycheck_department = ACCOUNT_DS2

/datum/job/octavia/enforce
	bounty_types = DS2_JOB_ENFORCER
	paycheck_department = ACCOUNT_DS2

/**
 * This is the file you should use to add alternate titles for each job, just
 * follow the way they're done here, it's easy enough and shouldn't take any
 * time at all to add more or add some for a job that doesn't have any.
 */

/datum/job
	/// The list of alternative job titles people can pick from, null by default.
	var/list/alt_titles = null


/datum/job/ai
	alt_titles = list(
		"AI",
		"Automated Overseer",
		"Station Intelligence",
		"Site Intelligence", // OCULIS EDIT ADDITION
	)

/datum/job/assistant
	alt_titles = list(
		"Assistant",
		"Artist",
		"Businessman",
		"Businesswoman",
		"Civilian",
		"Entertainer",
		"Freelancer",
		"Tourist",
		"Trader",
		"Off-Duty Crew",
		"Off-Duty Staff",
		"Colonist",
		"Contractor",
		"Visitor",
		"Traveler",
	)

/datum/job/atmospheric_technician
	alt_titles = list(
		"Atmospheric Technician",
		"Atmospheric Trainee",
		"Emergency Fire Technician",
		"Fusion Reactor Operator",
		"Gas Synthesis Technician",
		"Nuclear Reactor Operator",
		"Firefighter",
		"Life Support Technician",
		"Apprentice Atmospheric Technician",
	)

/datum/job/barber
	alt_titles = list(
		"Barber",
		"Aethestician",
		"Colorist",
		"Salon Manager",
		"Salon Technician",
		"Stylist",
	)

/datum/job/bartender
	alt_titles = list(
		"Bartender",
		"Barman",
		"Barmaid",
		"Barista",
		"Bar Manager",
		"Beverage Architect",
		"Barkeeper",
		"Mixologist",
		"Tavernkeeper", // OCULIS EDIT ADDITION
	)

/datum/job/bitrunner
	alt_titles = list(
		"Bitrunner",
		"Bitdomain Technician",
		"Data Retrieval Specialist",
		"Netdiver",
		"Pod Jockey",
		"Union Bitrunner",
		"Junior Runner",
	)

/datum/job/bridge_assistant
	alt_titles = list(
		"Bridge Officer",
		"Command Aide",
		"Ensign",
		"Command Cadet",
		"Bridge Attendant",
		"Command Secretary",
		"Command Intern",
	)

/datum/job/blueshield
	alt_titles = list(
		"Blueshield",
		"Command Bodyguard",
		"Corporate Protection Specialist",
		"Executive Protection Agent",
		"Blueshield In-Trial", // OCULIS EDIT ADDITION
	)

/datum/job/botanist
	alt_titles = list(
		"Botanist",
		"Botanical Researcher",
		"Florist",
		"Gardener",
		"Beekeeper",
		"Herbalist",
		"Hydroponicist",
		"Mycologist",
		"Junior Botanist",
	)

/datum/job/bouncer
	alt_titles = list(
		"Bouncer",
		"Service Guard",
		"Doorman",
		"Doorwoman", // OCULIS EDIT ADDITION
		"Service Guard Cadet", // OCULIS EDIT ADDITION
		"Civil Protection Officer",
		"Public Peacekeeper",
	)

/datum/job/corrections_officer
	alt_titles = list(
		"Corrections Officer",
		"Brig Officer",
		"Brig Guard",
		"Prison Guard",
	)

/datum/job/captain
	alt_titles = list(
		"Captain",
		"Commanding Officer",
		"Site Manager",
		"Site Supervisor",
		"Site Overseer",
		"Site Director",
		"Site Administrator",
		"Station Commander",
		"Captain In-Trial", // OCULIS EDIT ADDITION
	)

/datum/job/cargo_technician
	alt_titles = list(
		"Cargo Technician",
		"Warehouse Technician",
		"Commodities Trader",
		"Deck Worker",
		"Inventory Associate",
		"Mailman",
		"Cargo Associate",
		"Mail Carrier",
		"Receiving Clerk",
		"Shipping Associate",
		"Union Associate",
	)

/datum/job/chaplain
	alt_titles = list(
		"Chaplain",
		"High Priest",
		"High Priestess",
		"Imam",
		"Magister",
		"Monk",
		"Nun",
		"Oracle",
		"Preacher",
		"Priest",
		"Priestess",
		"Pontifex",
		"Rabbi",
		"Reverend",
		"Shrine Maiden",
		"Shrine Guardian",
		"Shaman", //OCULIS ADDITION START
		"Acolyte",
	)

/datum/job/chemist
	alt_titles = list(
		"Chemist",
		"Registered Pharmacist",
		"Clinical Pharmacist",
		"Assistant Pharmacist",
		"Chemical Engineer",
		"Pharmacist",
		"Pharmacologist",
		"Trainee Pharmacist",
	)

/datum/job/chief_engineer
	alt_titles = list(
		"Chief Engineer",
		"Engineering Foreman",
		"Engineering Supervisor",
		"Head of Engineering",
		"Chief Engineer In-Trial", // OCULIS EDIT ADDITION
	)

/datum/job/chief_medical_officer
	alt_titles = list(
		"Chief Medical Officer",
		"Chief Physician",
		"Head Physician",
		"Head of Medical",
		"Medical Supervisor",
		"Medical Director",
		"Medical Administrator",
		"Charge Nurse", // OCULIS EDIT ADDITION
		"Chief Medical Officer In-Trial", // OCULIS EDIT ADDITION
	)

/datum/job/clown
	alt_titles = list(
		"Clown",
		"Comedian",
		"Jester",
		"Joker",
		"Prankster", // OCULIS EDIT ADDITION
	)

/datum/job/cook
	alt_titles = list(
		"Cook",
		"Butcher",
		"Line Cook",
		"Chef",
		"Culinary Artist",
		"Sous-Chef",
		"Chef's Apprentice",
		"Baker",
		"Junior Chef",
	)

/datum/job/coroner
	alt_titles = list(
		"Coroner",
		"Forensic Pathologist",
		"Funeral Director",
		"Medical Examiner",
		"Mortician",
		"Undertaker", // OCULIS EDIT ADDITION
	)

/datum/job/curator
	alt_titles = list(
		"Curator",
		"Archivist",
		"Conservator",
		"Journalist",
		"Librarian",
		"Assistant Librarian", // OCULIS EDIT ADDITION
		"Scholar", // OCULIS EDIT ADDITION
		"Literary Translator", // OCULIS EDIT ADDITION
		"Interpreter", // OCULIS EDIT ADDITION
	)

/datum/job/customs_agent
	alt_titles = list(
		"Customs Agent",
		"Supply Guard",
		"Union Customs Agent", //OCULIS ADDITION
		"Supply Guard Trainee", //OCULIS ADDITION
		"Deck Defense Officer", //OCULIS ADDITION
		"Delivery Escort",
	)

/datum/job/cyborg
	alt_titles = list(
		"Cyborg",
		"Android",
		"Robot",
	)

/datum/job/detective
	alt_titles = list(
		"Detective",
		"Junior Detective",
		"Forensic Specialist",
		"Forensic Scientist",
		"Forensic Technician",
		"Forensic Investigator",
		"Private Investigator",
	)

/datum/job/doctor
	alt_titles = list(
		"Medical Doctor",
		"Medical Resident",
		"Medical Assistant",
		"Medical Student",
		"Physician",
		"Emergency Physician",
		"Theoretical Physician", //OCULIS EDIT ADDITION
		"Physician Assistant",
		"Nurse",
		"Registered Nurse",
		"Practical Nurse", //OCULIS EDIT ADDITION
		"Nursing Assistant", //OCULIS EDIT ADDITION
		"Nursing Student", // OCULIS EDIT ADDITION
		"Surgeon",
		"Surgical Assistant", //OCULIS EDIT ADDITION
		"General Practitioner",
		"Clinician",
	)

/datum/job/engineering_guard //see orderly
	alt_titles = list(
		"Engineering Guard",
		"OSHA Enforcer", //OCULIS EDIT ADDITION, alt titles
		"Engineering Guard In-Training", //OCULIS EDIT ADDITION, alt titles
		"Equipment Inspector", //OCULIS EDIT ADDITION, alt titles
		"Power Plant Guard",
		"Construction Guard",
	)

/datum/job/geneticist
	alt_titles = list(
		"Geneticist",
		"Molecular Biologist",
		"Gene Scientist",
		"Gene Analyzer",
		"Gene Tailor",
		"Mutation Researcher",
		"Genetic Engineer", // OCULIS EDIT ADDITION
	)

/datum/job/head_of_personnel
	alt_titles = list(
		"Head of Personnel",
		"Crew Supervisor",
		"Employment Officer",
		"Human Resources Officer",
		"Executive Officer",
		"First Officer", // OCULIS EDIT ADDITION
		"Senior Sophont Resources Agent", // OCULIS EDIT ADDITION
		"Head of Personnel In-Trial", // OCULIS EDIT ADDITION
	)

/datum/job/head_of_security
	alt_titles = list(
		"Head of Security",
		"Chief Constable",
		"Chief of Security",
		"Chief Security Officer", // OCULIS EDIT ADDITION
		"Security Commander",
		"Security Supervisor",
		"Security Director",
		"Sheriff",
		"Marshall", // OCULIS EDIT ADDITION
		"Head of Security In-Trial", // OCULIS EDIT ADDITION
	)

/datum/job/janitor
	alt_titles = list(
		"Janitor",
		"Concierge",
		"Custodial Technician",
		"Rat Catcher",
		"Pest Control Technician",
		"Custodian",
		"Maid",
		"Maintenance Technician",
		"Sanitation Technician",
	)

/datum/job/lawyer
	alt_titles = list(
		"Lawyer",
		"Barrister",
		"Defense Attorney",
		"Sophont Resources Agent", // OCULIS EDIT ADDITION
		// "Internal Affairs Agent", // OCULIS EDIT REMOVAL
		"Legal Clerk",
		"Prosecutor",
		"Attorney At Law",
		"General Counsel",
		"Corporate Attorney",
		"Public Defender",
		"Crew Advocate",
	)

/datum/job/mime
	alt_titles = list(
		"Mime",
		"Mummer",
		"Pantomimist",
	)

/datum/job/nanotrasen_consultant
	alt_titles = list(
		"Nanotrasen Representative",
		"Nanotrasen Consultant",
		"Nanotrasen Regulatory Advisor",
		"Nanotrasen Diplomat",
		"Corporate Adjutant",
		"Corporate Representative",
		"Corporate Advocate",
	)

/datum/job/orderly
	alt_titles = list(
		"Orderly",
		"Medical Guard",
		"Medical Guard In-Training", //OCULIS EDIT ADDITION
	) //other dept guards' alt-titles should be kept to [department] guard to avoid confusion, unless the department gets a re-do.

/datum/job/paramedic
	alt_titles = list(
		"Paramedic",
		"Senior Paramedic", //OCULIS EDIT ADDITION
		"Emergency Medical Technician",
		"Emergency Medical Responder",
		"Search and Rescue Technician",
		"Trauma Team Responder",
	)

/datum/job/prisoner
	alt_titles = list(
		"Prisoner",
		"Convict", // OCULIS EDIT ADDITION
		"Minimum Security Prisoner",
		"Medium Security Prisoner", // OCULIS EDIT ADDITION
		"Maximum Security Prisoner",
		"SuperMax Security Prisoner",
		"Protective Custody Prisoner",
		"Psychiatric Hold Prisoner",
	)

/datum/job/psychologist
	alt_titles = list(
		"Psychologist",
		"Counsellor",
		"Psychiatrist",
		"Therapist",
	)

/datum/job/quartermaster
	alt_titles = list(
		"Quartermaster",
		"Deck Chief",
		"Head of Supply",
		"Logistics Coordinator",
		"Supply Foreman",
		"Union Requisitions Officer",
		"Warehouse Supervisor",
		"Quartermaster In-Trial", // OCULIS EDIT ADDITION
	)

/datum/job/research_director
	alt_titles = list(
		"Research Director",
		"Biorobotics Director",
		"Chief Science Officer",
		"Lead Researcher",
		"Research Supervisor",
		"Silicon Administrator",
		"Research Administrator",
		"Director of Science",
		"Research Director In-Trial", // OCULIS EDIT ADDITION
	)

/datum/job/roboticist
	alt_titles = list(
		"Roboticist",
		"Apprentice Roboticist",
		"Cyberneticist",
		"Prosthetist", // OCULIS EDIT ADDITION
		"Machinist",
		"Mechatronic Engineer",
		"Biomechanical Engineer",
		"Mech Fabrication Specialist",
	)

/datum/job/science_guard //See orderly
	alt_titles = list(
		"Science Guard",
		"Research Facility Protector", //OCULIS EDIT ADDITION, alt titles
		"Science Guard Trainee", //OCULIS EDIT ADDITION, alt titles
		"Hazardous Experiment Overwatch",
		"Xenobiological Recontainment Officer",
		"Expedition Protection Agent",
	)
/datum/job/scientist
	alt_titles = list(
		"Scientist",
		"Anomalist",
		"Circuitry Designer",
		"Cytologist",
		"Graduate Student",
		"Lab Technician",
		"Ordnance Technician",
		"Plasma Researcher",
		"Resonance Researcher",
		"Theoretical Physicist",
		"Xenoarchaeologist",
		"Xenobiologist",
		"Research Assistant",
	)

/datum/job/security_officer
	alt_titles = list(
		"Security Officer",
		"Security Operative",
		"Security Cadet",
		"Security Specialist",
		"Junior Officer", // OCULIS EDIT ADDITION
		"Senior Officer", // OCULIS EDIT ADDITION
		"Deputy",
		"Constable",
		"Peace Officer", // OCULIS EDIT ADDITION
	)

/datum/job/shaft_miner
	alt_titles = list(
		"Shaft Miner",
		"Union Miner",
		"Excavator",
		"Drill Technician",
		"Prospector",
		"Ore Excavation Specialist",
		"Spelunker",
		"Apprentice Miner",
	)

/datum/job/station_engineer
	alt_titles = list(
		"Station Engineer",
		"Electrician",
		"Damage Control Technician",
		"Engine Technician",
		"EVA Technician",
		"Mechanic",
		"Architect",
		"Structural Engineer",
		"Electrical Engineer",
		"Apprentice Engineer",
	)

/datum/job/telecomms_specialist
	alt_titles = list(
		"Telecomms Specialist",
		"Wireless Operator",
		"Network Engineer",
		"Sysadmin",
		"Telecomms Technician",
		"Tram Technician",
	)

/datum/job/virologist
	alt_titles = list(
		"Virologist",
		"Epidemiologist",
		"Microbiologist",
		"Pathologist",
		"Junior Pathologist",
	)

/datum/job/warden
	alt_titles = list(
		"Warden",
		"Brig Sergeant",
		"Brig Governor",
		"Dispatch Officer",
		"Armaments Supervisor", // OCULIS EDIT ADDITION
		"Jailer",
		"Sentry", // OCULIS EDIT ADDITION
		"Armorer", // OCULIS EDIT ADDITION
	)

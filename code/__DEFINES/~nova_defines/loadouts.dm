/// Defines for what loadout slot a corresponding item belongs to.
#define LOADOUT_ITEM_BELT "belt"
#define LOADOUT_ITEM_EARS "ears"
#define LOADOUT_ITEM_GLASSES "glasses"
#define LOADOUT_ITEM_GLOVES "gloves"
#define LOADOUT_ITEM_HEAD "head"
#define LOADOUT_ITEM_MASK "mask"
#define LOADOUT_ITEM_NECK "neck"
#define LOADOUT_ITEM_SHOES "shoes"
#define LOADOUT_ITEM_SUIT "suit"
#define LOADOUT_ITEM_UNIFORM "under"
#define LOADOUT_ITEM_ACCESSORY "accessory"
#define LOADOUT_ITEM_INHAND "inhand_items"
#define LOADOUT_ITEM_MISC "pocket_items"
#define LOADOUT_ITEM_TOYS "toys"

/// Used to set custom descriptions.
#define INFO_DESCRIBED "description"

/// Max amonut of misc / backpack items that are allowed.
#define MAX_ALLOWED_MISC_ITEMS 3

/// Defines for extra info blurbs, for loadout items.
#define TOOLTIP_NO_ARMOR "Armorless"
#define TOOLTIP_NO_DAMAGE "CEREMONIAL - This item has very low force and is cosmetic."
#define TOOLTIP_RANDOM_COLOR "Random Color"
#define TOOLTIP_GREYSCALE "GREYSCALED - This item can be customized via the greyscale modification UI."
#define TOOLTIP_RENAMABLE "RENAMABLE - This item can be given a custom name."

#define LOADOUT_OVERRIDE_JOB "Delete job items"
#define LOADOUT_OVERRIDE_BACKPACK "Move job to backpack"
#define LOADOUT_OVERRIDE_CASE "Place all in case"

// NOTE TO FUTURE CODERS: If you increase this to a huge number, please restrict the overall **amount** of items players can take,
// if item count restrictions have been significantly increased. You will end up with massively bloated save sizes otherwise.
#define LOADOUT_MAX_PRESETS 24 // OCULIS EDIT: this sign can't stop me because I can't read!!! ORIGINAL: #define LOADOUT_MAX_PRESETS 12
#define LOADOUT_MAX_NAME_LENGTH 24

/// Please add jobs here. It's cleaner using these.
//Security.
#define ALL_JOBS_SEC JOB_WARDEN, JOB_DETECTIVE, JOB_SECURITY_OFFICER, JOB_HEAD_OF_SECURITY, JOB_CORRECTIONS_OFFICER, JOB_SECURITY_OFFICER_MEDICAL, JOB_SECURITY_OFFICER_ENGINEERING, JOB_SECURITY_OFFICER_SCIENCE, JOB_SECURITY_OFFICER_SUPPLY, JOB_BLUESHIELD, JOB_VETERAN_ADVISOR,
//Dept Guards.
#define ALL_JOBS_DEPTGUARD JOB_CORRECTIONS_OFFICER, JOB_ENGINEERING_GUARD, JOB_ORDERLY, JOB_SCIENCE_GUARD, JOB_CUSTOMS_AGENT, JOB_BOUNCER,
//Nanotrasen and Centcom
#define ALL_JOBS_CC JOB_NT_REP, JOB_BLUESHIELD
//Medical
#define ALL_JOBS_MED JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_CHEMIST, JOB_PARAMEDIC, JOB_ORDERLY, JOB_CORONER, JOB_VIROLOGIST, JOB_PSYCHOLOGIST,
//Science
#define ALL_JOBS_SCI JOB_SCIENTIST, JOB_ROBOTICIST, JOB_GENETICIST, JOB_RESEARCH_DIRECTOR, JOB_CHEMIST, JOB_SCIENCE_GUARD,
//Cargo
#define ALL_JOBS_CARGO JOB_QUARTERMASTER, JOB_CARGO_TECHNICIAN, JOB_CUSTOMS_AGENT, JOB_SHAFT_MINER, JOB_BITRUNNER, JOB_EXPLORER //IRIS EDIT - adds Explorer
//Engineering
#define ALL_JOBS_ENGI JOB_CHIEF_ENGINEER, JOB_STATION_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_ENGINEERING_GUARD, JOB_TELECOMMS_SPECIALIST,
//Command
#define ALL_JOBS_COM JOB_CHIEF_ENGINEER, JOB_HEAD_OF_SECURITY, JOB_RESEARCH_DIRECTOR, JOB_QUARTERMASTER, JOB_NT_REP, JOB_BLUESHIELD, JOB_CHIEF_MEDICAL_OFFICER, JOB_HEAD_OF_PERSONNEL, JOB_CAPTAIN, JOB_BRIDGE_ASSISTANT,
//Service
#define ALL_JOBS_SERV JOB_HEAD_OF_PERSONNEL, JOB_BARTENDER, JOB_CHEF, JOB_COOK, JOB_BOTANIST, JOB_CURATOR, JOB_CHAPLAIN, JOB_CLOWN, JOB_MIME, JOB_JANITOR , JOB_LAWYER, JOB_BARBER, JOB_BOUNCER, JOB_PSYCHOLOGIST,


// tab orders for loadout - tabs will show in the order that they're done ascending here. IRIS EDIT
#define LOADOUT_HEAD 1
#define LOADOUT_FACE 3
#define LOADOUT_GLASSES 2
#define LOADOUT_NECK 3
#define LOADOUT_EARS 4
#define LOADOUT_SUIT 4
#define LOADOUT_ACCESSORIES 4
#define LOADOUT_BELT 4
#define LOADOUT_UNDERSUIT 5
#define LOADOUT_GLOVES 5
#define LOADOUT_INHANDS 5
#define LOADOUT_ACCESSORIES_BACKPACK 6
#define LOADOUT_SHOES 6
#define LOADOUT_POCKET_OTHER 6
#define LOADOUT_TOYS 6
#define LOADOUT_POCKET 7
#define LOADOUT_DONATOR 8

/// For use in translating bitfield to steps required for robotic surgery. Keep in the correct order!
#define SURGERY_STATE_GUIDES_ROBOTIC(must_must_not) list(\
	"the shell [must_must_not] be unscrewed" = SURGERY_SKIN_CUT, \
	"the hatch [must_must_not] be open" = SURGERY_SKIN_OPEN, \
	"the blood vessels [must_must_not] be unclamped" = SURGERY_VESSELS_UNCLAMPED, \
	"the hatch [must_must_not] be open" = SURGERY_VESSELS_CLAMPED, \
	"the organs [must_must_not] be prepared" = SURGERY_ORGANS_CUT, \
	"the bone [must_must_not] be drilled" = SURGERY_BONE_DRILLED, \
	"the endoskeleton [must_must_not] be unwrenched" = SURGERY_BONE_SAWED, \
	"plastic [must_must_not] be applied" = SURGERY_PLASTIC_APPLIED, \
	"the prosthetic [must_must_not] be unsecured" = SURGERY_PROSTHETIC_UNSECURED, \
	"the chest cavity [must_must_not] be opened wide" = SURGERY_CAVITY_WIDENED, \
)

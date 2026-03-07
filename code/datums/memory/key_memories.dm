/**
 * Key memories — important info the player needs to reference.
 * Not interesting as stories, but occupy a critical role in conveying game-state information.
 */
/datum/memory/key
	story_value = STORY_VALUE_KEY
	memory_flags = MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS

/// Your bank account ID.
/datum/memory/key/account
	name_templates = list("The bank ID of {SUBJECT}, {ACCOUNT_ID}.")
	start_templates = list(
		"{SUBJECT} flexing their last brain cells, proudly showing their lucky numbers {ACCOUNT_ID}.",
		"{ACCOUNT_ID}. The numbers mason, what do they mean!?",
	)

/// The code to the captain's spare ID.
/datum/memory/key/captains_spare_code
	name_templates = list("The code to the golden safe on the bridge, {SAFE_CODE}.")
	start_templates = list(
		"{SUBJECT} struggling at a wall safe, until finally entering {SAFE_CODE}.",
		"{SAFE_CODE}. The numbers mason, what do they mean!?",
	)

/// The nuclear bomb code, for nuke ops.
/datum/memory/key/nuke_code
	name_templates = list("{SUBJECT} learns the detonation codes for a nuclear weapon, {NUCLEAR_CODE}.")
	start_templates = list(
		"The number {NUCLEAR_CODE} written on a sticky note with the words \"FOR SYNDICATE EYES ONLY\" scrawled next to it.",
		"A piece of paper with the number {NUCLEAR_CODE} being handed to {SUBJECT} from a figure in a blood-red MODsuit.",
	)

/// Tracks what medicines someone with the "allergies" quirk is allergic to.
/datum/memory/key/quirk_allergy
	memory_flags = MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS|MEMORY_NO_STORY
	name_templates = list("The {ALLERGY_STRING} allergy of {SUBJECT}.")
	start_templates = list("{SUBJECT} sneezing after coming into contact with {ALLERGY_STRING}.")

/// Tracks what kind of item the quirk user's heirloom is.
/datum/memory/key/quirk_heirloom
	name_templates = list("{SUBJECT}'s heirloom {HEIRLOOM_NAME}.")
	start_templates = list(
		"{SUBJECT} being bequeathed the heirloom {HEIRLOOM_NAME} by a dear relative.",
		"{SUBJECT} discovering the heirloom {HEIRLOOM_NAME} in some long-forgotten boxes.",
		"{SUBJECT} stealing the heirloom {HEIRLOOM_NAME} from an undeserving family member.",
	)

/// Tracks what brand a smoker quirk user likes.
/datum/memory/key/quirk_smoker
	memory_flags = MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS
	name_templates = list("{SUBJECT}'s addiction to {PREFERRED_BRAND} cigarettes.")
	start_templates = list(
		"{PREFERRED_BRAND} cigarettes being plundered by {SUBJECT}.",
		"{SUBJECT} buying a box of {PREFERRED_BRAND} nicotine sticks.",
		"{SUBJECT} fiending for some {PREFERRED_BRAND} ciggies.",
	)

/// Tracks what beverage an alcoholic quirk user likes.
/datum/memory/key/quirk_alcoholic
	memory_flags = MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS
	name_templates = list("{SUBJECT}'s addiction to {PREFERRED_BRANDY} alcohol.")
	start_templates = list(
		"{PREFERRED_BRANDY} being downed by {SUBJECT}.",
		"{SUBJECT} buying a box of {PREFERRED_BRANDY} bottles.",
		"{SUBJECT} fiending for some {PREFERRED_BRANDY}.",
	)

/// Where our traitor uplink is, and what its code is.
/datum/memory/key/traitor_uplink
	name_templates = list("{SUBJECT}'s equipment uplink in their {UPLINK_LOC}, opened via {UPLINK_CODE}.")
	start_templates = list(
		"{SUBJECT} punching in {UPLINK_CODE} into their {UPLINK_LOC}.",
		"{SUBJECT} writing down {UPLINK_CODE} with their {UPLINK_LOC} besides them, so as to not forget it.",
	)

/datum/memory/key/traitor_uplink/implant
	name_templates = list("{SUBJECT}'s equipment uplink implanted into their body.")
	start_templates = list(
		"{SUBJECT} being implanted by a scientist.",
		"{SUBJECT} having surgery done on them by a scientist.",
	)

/// Permabrig crimes.
/datum/memory/key/permabrig_crimes
	name_templates = list("{SUBJECT}'s crime of \"{CRIMES}\".")
	start_templates = list(
		"{SUBJECT} being arrested by security for {CRIMES}.",
		"{SUBJECT} committing the crimes of {CRIMES}.",
	)

/// Message server decryption key.
/datum/memory/key/message_server_key
	name_templates = list("The daily message server key is {DECRYPT_KEY}. Keep it a secret from the clown.")
	start_templates = list(
		"A sticky note attached to a monitor with {DECRYPT_KEY} written on it.",
		"Poly the parrot screaming \"{DECRYPT_KEY}!\" over and over again.",
		"{SUBJECT} spilling coffee over the message monitor while typing {DECRYPT_KEY}.",
	)

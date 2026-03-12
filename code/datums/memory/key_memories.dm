/**
 * I am affectionally titling these "key memories"
 *
 * These memories aren't particularly special or interesting, but occuply an important role
 * in conveying information to the user about something important they need to check semi-often
 */
/datum/memory/key
	story_value = STORY_VALUE_KEY
	memory_flags = MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS

/// Your bank account ID, can't get into it without it
/datum/memory/key/account
	var/remembered_id

/datum/memory/key/account/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	remembered_id,
)
	src.remembered_id = remembered_id
	return ..()

/// The code to the captain's spare ID, ONLY give to the real captain.
/datum/memory/key/captains_spare_code
	var/safe_code

/datum/memory/key/captains_spare_code/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	safe_code,
)
	src.safe_code = safe_code
	return ..()

/// The nuclear bomb code, for nuke ops
/datum/memory/key/nuke_code
	var/nuclear_code

/datum/memory/key/nuke_code/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	nuclear_code,
)
	src.nuclear_code = nuclear_code
	return ..()

/// Tracks what medicines someone with the "allergies" quirk is allergic to
/datum/memory/key/quirk_allergy
	memory_flags = MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS|MEMORY_NO_STORY // No story for this
	var/allergy_string

/datum/memory/key/quirk_allergy/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	allergy_string,
)
	src.allergy_string = allergy_string
	return ..()

/// Tracks what kind of item the quirk user's heirloom is
/datum/memory/key/quirk_heirloom
	var/heirloom_name

/datum/memory/key/quirk_heirloom/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	heirloom_name,
)
	src.heirloom_name = heirloom_name
	return ..()

/// Tracks what brand a smoker quirk user likes
/datum/memory/key/quirk_smoker
	memory_flags = MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS // Does not have nomood
	var/preferred_brand

/datum/memory/key/quirk_smoker/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	preferred_brand,
)
	src.preferred_brand = preferred_brand
	return ..()

/// Tracks what beverage an alcoholic quirk user likes
/datum/memory/key/quirk_alcoholic
	memory_flags = MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE|MEMORY_SKIP_UNCONSCIOUS // Does not have nomood
	var/preferred_brandy //haha, get it because brandy is a type of alcohol wow!

/datum/memory/key/quirk_alcoholic/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	preferred_brandy,
)
	src.preferred_brandy = preferred_brandy
	return ..()

/// Where our traitor uplink is, and what is its code
/datum/memory/key/traitor_uplink
	var/uplink_loc
	var/uplink_code

/datum/memory/key/traitor_uplink/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	uplink_loc,
	uplink_code,
)
	src.uplink_loc = uplink_loc
	src.uplink_code = uplink_code
	return ..()

/datum/memory/key/traitor_uplink/implant

/datum/memory/key/permabrig_crimes
	var/crimes

/datum/memory/key/permabrig_crimes/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	crimes,
)
	src.crimes = crimes
	return ..()

/datum/memory/key/message_server_key
	var/decrypt_key

/datum/memory/key/message_server_key/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	decrypt_key,
)
	src.decrypt_key = decrypt_key
	return ..()


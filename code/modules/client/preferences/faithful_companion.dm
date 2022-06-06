/datum/preference/choiced/faithful_companion
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "faithful_compaion"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/faithful_companion/init_possible_values()
	return GLOB.faithful_companion_types

/datum/preference/choiced/faithful_companion/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Faithful Companion" in preferences.all_quirks

/datum/preference/choiced/faithful_companion/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/mood_event/drunk
	mood_change = 3
	description = "Everything just feels better after a drink or two."

/datum/mood_event/drunk/add_effects(param)
	// Display blush visual
	ADD_TRAIT(owner, TRAIT_BLUSHING, "[type]")
	owner.update_body()

/datum/mood_event/drunk/remove_effects()
	// Stop displaying blush visual
	REMOVE_TRAIT(owner, TRAIT_BLUSHING, "[type]")
	owner.update_body()

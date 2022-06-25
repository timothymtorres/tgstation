/datum/mood_event
	/// The mob that is being affected by the mood event
	var/mob/owner
	/// The text description the player will see when the mood is active
	var/description
	/// A positive (good mood) or negative (bad mood) value that affects overall sanity over time
	var/mood_change = 0
	/// The length of time the mood affects the mob
	var/timeout = 0
	/// Not shown on examine
	var/hidden = FALSE
	/// If it isn't null, it will replace or add onto the mood icon with this (same file). see happiness drug for example
	var/special_screen_obj
	/// If false, it will be an overlay instead
	var/special_screen_replace = TRUE

/datum/mood_event/New(mob/M, ...)
	owner = M
	var/list/params = args.Copy(2)
	add_effects(arglist(params))

/datum/mood_event/Destroy()
	remove_effects()
	owner = null
	return ..()

/datum/mood_event/proc/add_effects(param)
	return

/datum/mood_event/proc/remove_effects()
	return

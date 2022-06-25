/** Use this type of mood event for a location a player visits
 *
 *	/area/
 *		var/mood_bonus // Bonus mood for being in this area
 *		var/mood_message // Mood message for being here, only shows up if mood_bonus != 0
 *		var/mood_trait // Does the mood bonus require a trait?
 *
 *  Do not put any /area/ types in this file location!
 **/

/datum/mood_event/area
	description = "" //Fill this out in the area
	mood_change = 0

/datum/mood_event/area/add_effects(mood_bonus, mood_message)
	description = mood_message
	mood_change = mood_bonus

/// The beauty of an area can affect our mood
/datum/mood_event/location_beauty
	description = ""
	mood_change = 0
	renewal_retrigger_effect = TRUE

/datum/mood_event/location_beauty/add_effects(mood_bonus, mood_message)
	description = mood_message
	mood_change = mood_bonus

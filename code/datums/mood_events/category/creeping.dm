/datum/mood_event/creeping
	description = "The voices have released their hooks on my mind! I feel free again!" //creeps get it when they are around their obsession
	mood_change = 18
	timeout = 3 SECONDS
	hidden = TRUE
	category = MOOD_CATEGORY_CREEPY

/datum/mood_event/notcreeping
	description = "The voices are not happy, and they painfully contort my thoughts into getting back on task."
	mood_change = -6
	timeout = 3 SECONDS
	hidden = TRUE
	category = MOOD_CATEGORY_CREEPY

/datum/mood_event/notcreepingsevere // not hidden since it's so severe
	description = "THEY NEEEEEEED OBSESSIONNNN!!"
	mood_change = -30
	timeout = 3 SECONDS
	category = MOOD_CATEGORY_CREEPY

/datum/mood_event/notcreepingsevere/add_effects(name)
	var/list/unstable = list(name)
	for(var/i in 1 to rand(3,5))
		unstable += copytext_char(name, -1)
	var/unhinged = uppertext(unstable.Join("")) // example Tinea Luxor > TINEA LUXORRRR (with randomness in how long that slur is)
	description = "THEY NEEEEEEED [unhinged]!!"

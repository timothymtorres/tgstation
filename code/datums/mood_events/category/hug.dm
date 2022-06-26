/datum/mood_event/hug
	description = "Hugs are nice."
	mood_change = 1
	timeout = 2 MINUTES
	category = MOOD_CATEGORY_HUG

/datum/mood_event/warmhug
	description = "Warm cozy hugs are the best!"
	mood_change = 1
	timeout = 2 MINUTES
	category = MOOD_CATEGORY_HUG

/datum/mood_event/betterhug
	description = "Someone was very nice to me."
	mood_change = 3
	timeout = 4 MINUTES
	category = MOOD_CATEGORY_HUG

/datum/mood_event/betterhug/add_effects(mob/friend)
	description = "[friend.name] was very nice to me."

/datum/mood_event/besthug
	description = "Someone is great to be around, they make me feel so happy!"
	mood_change = 5
	timeout = 4 MINUTES
	category = MOOD_CATEGORY_HUG

/datum/mood_event/besthug/add_effects(mob/friend)
	description = "[friend.name] is great to be around, [friend.p_they()] makes me feel so happy!"


// When you breath or smell a gas
/datum/mood_event/suffocation
	description = "CAN'T... BREATHE..."
	mood_change = -12
	timeout = 30 SECONDS
	category = MOOD_CATEGORY_SMELL

/datum/mood_event/chemical_euphoria // N20
	description = "Heh...hehehe...hehe..."
	mood_change = 4
	timeout = 30 SECONDS
	category = MOOD_CATEGORY_SMELL

/datum/mood_event/disgust/bad_smell // Miasma weak
	description = "I can smell something horribly decayed inside this room."
	mood_change = -6
	timeout = 30 SECONDS
	category = MOOD_CATEGORY_SMELL

/datum/mood_event/disgust/nauseating_stench // Miasma strong
	description = "The stench of rotting carcasses is unbearable!"
	mood_change = -12
	timeout = 30 SECONDS
	category = MOOD_CATEGORY_SMELL

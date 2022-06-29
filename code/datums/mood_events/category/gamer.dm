/datum/mood_event/arcade
	description = "I beat the arcade game!"
	mood_change = 3
	timeout = 8 MINUTES
	category = MOOD_CATEGORY_GAMER

/datum/mood_event/gamer_won
	description = "I love winning videogames!"
	mood_change = 10
	timeout = 5 MINUTES
	category = MOOD_CATEGORY_GAMER

/datum/mood_event/gaming
	description = "I'm enjoying a nice gaming session!"
	mood_change = 2
	timeout = 30 SECONDS
	category = MOOD_CATEGORY_GAMER

/datum/mood_event/gamer_withdrawal
	description = "I wish I was gaming right now..."
	mood_change = -5
	category = MOOD_CATEGORY_GAMER

/datum/mood_event/gamer_lost
	description = "If I'm not good at video games, can I truly call myself a gamer?"
	mood_change = -10
	timeout = 10 MINUTES
	category = MOOD_CATEGORY_GAMER

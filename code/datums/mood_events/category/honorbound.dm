/datum/mood_event/honorbound
	description = "Following my honorbound code is fulfilling!"
	mood_change = 4
	category = MOOD_CATEGORY_HONORBOUND

/datum/mood_event/holy_smite //punished
	description = "I have been punished by my deity!"
	mood_change = -5
	timeout = 5 MINUTES
	category = MOOD_CATEGORY_HONORBOUND

/datum/mood_event/banished //when the chaplain is sus! (and gets forcably de-holy'd)
	description = "I have been excommunicated!"
	mood_change = -10
	timeout = 10 MINUTES
	category = MOOD_CATEGORY_HONORBOUND

/datum/mood_event/high_five
	description = "I love getting high fives!"
	mood_change = 2
	timeout = 45 SECONDS
	category = MOOD_CATEGORY_HIGH_FIVE

/datum/mood_event/high_ten
	description = "AMAZING! A HIGH-TEN!"
	mood_change = 3
	timeout = 45 SECONDS
	category = MOOD_CATEGORY_HIGH_FIVE

/datum/mood_event/down_low
	description = "HA! What a rube, they never stood a chance..."
	mood_change = 4
	timeout = 90 SECONDS
	category = MOOD_CATEGORY_HIGH_FIVE

/datum/mood_event/high_five_alone
	description = "I tried getting a high-five with no one around, how embarassing!"
	mood_change = -2
	timeout = 60 SECONDS
	category = MOOD_CATEGORY_HIGH_FIVE

/datum/mood_event/high_five_full_hand
	description = "Oh god, I don't even know how to high-five correctly..."
	mood_change = -1
	timeout = 45 SECONDS
	category = MOOD_CATEGORY_HIGH_FIVE

/datum/mood_event/left_hanging
	description = "But everyone loves high fives! Maybe people just... hate me?"
	mood_change = -2
	timeout = 90 SECONDS
	category = MOOD_CATEGORY_HIGH_FIVE

/datum/mood_event/too_slow
	description = "NO! HOW COULD I BE... TOO SLOW???"
	mood_change = -2 // multiplied by how many people saw it happen, up to 8, so potentially massive. the ULTIMATE prank carries a lot of weight
	timeout = 2 MINUTES
	category = MOOD_CATEGORY_HIGH_FIVE

/datum/mood_event/too_slow/add_effects(param)
	var/people_laughing_at_you = 1 // start with 1 in case they're on the same tile or something
	for(var/mob/living/carbon/iter_carbon in oview(owner, 7))
		if(iter_carbon.stat == CONSCIOUS)
			people_laughing_at_you++
			if(people_laughing_at_you > 7)
				break

	mood_change *= people_laughing_at_you
	return ..()

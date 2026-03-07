/// A doctor successfully completed a surgery on someone.
/datum/memory/surgery
	story_value = STORY_VALUE_OKAY
	associated_mood_category = "surgery"
	associated_mood_type = /datum/mood_event/surgery/success
	name_templates = list("The {SURGERY_TYPE} of {TARGET} by {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} carefully performing {SURGERY_TYPE} on {TARGET_ADJ}",
		"{SUBJECT} wielding a bone saw over {TARGET_ADJ}",
		"{TARGET_ADJ} being operated on by {SUBJECT}",
	)

/// Planted a bomb.
/datum/memory/bomb_planted
	story_value = STORY_VALUE_MEH
	name_templates = list("The arming of {OBJECT} by {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} pressing an ominous button, causing {OBJECT} to begin beeping",
		"{SUBJECT} slapping down {OBJECT_ADJ}",
		"{OBJECT} being armed by {SUBJECT_ADJ}",
	)

/// Planted a SYNDICATE bomb.
/datum/memory/bomb_planted/syndicate
	story_value = STORY_VALUE_AMAZING

/// Planted a NUKE!
/datum/memory/bomb_planted/nuke
	story_value = STORY_VALUE_LEGENDARY

/// Got a sweet high five.
/datum/memory/high_five
	story_value = STORY_VALUE_MEH
	associated_mood_category = "high_five"
	associated_mood_type = /datum/mood_event/high_five
	name_templates = list("The {HIGH_FIVE_TYPE} between {SUBJECT} and {TARGET}.")
	start_templates = list(
		"{SUBJECT_ADJ} and {TARGET_ADJ} having a legendary {HIGH_FIVE_TYPE}",
		"{SUBJECT} giving {TARGET} a {HIGH_FIVE_TYPE}",
	)

/datum/memory/high_five/post_init()
	if(extra_data["high_ten"])
		story_value = STORY_VALUE_OKAY
		associated_mood_type = /datum/mood_event/high_ten

/// Was cyborgized.
/datum/memory/was_cyborged
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_SKIP_UNCONSCIOUS
	name_templates = list("The borging of {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} having their brain put into a robot",
		"{SUBJECT_ADJ} getting turned into a bucket of bolts",
	)

/// Witnessed someone die nearby.
/datum/memory/witnessed_death
	story_value = STORY_VALUE_MEH
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	name_templates = list("The death of {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} having perished",
		"{SUBJECT_ADJ} seizing up and falling limp, their eyes appearing dead and lifeless",
		"{SUBJECT}'s heart stopping",
		"the death of {SUBJECT_ADJ}",
	)

/// Witnessed someone get creampied nearby.
/datum/memory/witnessed_creampie
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	associated_mood_category = "creampie"
	associated_mood_type = /datum/mood_event/creampie
	name_templates = list("The creaming of {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ}'s face being covered in cream",
		"{SUBJECT_ADJ} getting cream-pied",
	)

/// Witnessed someone get splashed with squid ink.
/datum/memory/witnessed_inking
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	associated_mood_category = "inked"
	associated_mood_type = /datum/mood_event/inked
	name_templates = list("The inking of {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ}'s face being covered in squid ink",
		"{SUBJECT_ADJ} getting squid-inked",
	)

/// Got slipped by something.
/datum/memory/was_slipped
	story_value = STORY_VALUE_MEH
	associated_mood_category = "slipped"
	associated_mood_type = /datum/mood_event/slipped
	name_templates = list("The slipping of {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} not being able to keep standing when faced with {OBJECT_ADJ}",
		"{SUBJECT_ADJ} tumbling right over {OBJECT_ADJ}",
		"{OBJECT_ADJ} which took {SUBJECT} down a notch",
	)

/// Had spaghetti fall from their pockets.
/datum/memory/lost_spaghetti
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_CHECK_BLINDNESS
	name_templates = list("{SUBJECT}'s spaghetti blunder.")
	start_templates = list(
		"{SUBJECT_ADJ}'s spaghetti pouring out of their pockets",
		"{SUBJECT_ADJ}'s pockets not being able to contain their spaghetti",
	)

/// Got kissed!
/datum/memory/kissed
	story_value = STORY_VALUE_MEH
	memory_flags = MEMORY_CHECK_BLINDNESS
	associated_mood_category = "kiss"
	associated_mood_type = /datum/mood_event/kiss
	name_templates = list("The kiss blown to {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} receiving a blown kiss from {TARGET_ADJ}",
		"{TARGET_ADJ} blowing a kiss to {SUBJECT}",
	)

/// Had some good food.
/datum/memory/good_food
	story_value = STORY_VALUE_MEH
	name_templates = list("A delicious {FOOD_NAME} {SUBJECT} ate.")
	start_templates = list(
		"{FOOD_NAME} changing {SUBJECT}'s outlook on food",
		"{FOOD_NAME} leaving a long lasting impression on {SUBJECT_ADJ}",
		"{SUBJECT_ADJ} enjoying an incredibly good {FOOD_NAME}",
		"{SUBJECT_ADJ} producing a slice of life anime reaction to eating {FOOD_NAME}",
	)

/// Had a good drink.
/datum/memory/good_drink
	story_value = STORY_VALUE_MEH
	name_templates = list("A delicious {DRINK_NAME} {SUBJECT} consumed.")
	start_templates = list(
		"{DRINK_NAME} changing {SUBJECT}'s outlook on classy drinking",
		"{DRINK_NAME} leaving a long lasting impression on {SUBJECT_ADJ}",
		"{SUBJECT_ADJ} enjoying an incredibly good {DRINK_NAME}",
		"{SUBJECT_ADJ} slurping some tasty {DRINK_NAME}",
	)

/// Was set on fire and started to burn.
/datum/memory/was_burning
	story_value = STORY_VALUE_MEH
	associated_mood_category = "on_fire"
	associated_mood_type = /datum/mood_event/on_fire
	name_templates = list("The burning of {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} bursting into flames",
		"{SUBJECT_ADJ} turning into a human torch",
		"the fire that engulfed {SUBJECT_ADJ}",
	)

/// Got a limb removed by force.
/datum/memory/was_dismembered
	story_value = STORY_VALUE_AMAZING
	associated_mood_category = "dismembered"
	associated_mood_type = /datum/mood_event/dismembered
	name_templates = list("The loss of {SUBJECT}'s {LOST_LIMB}.")
	start_templates = list(
		"{SUBJECT_ADJ} becoming eligible for handicapped parking",
		"{SUBJECT_ADJ}'s {LOST_LIMB} being flung into the abyss",
		"{SUBJECT_ADJ}'s {LOST_LIMB} parting ways with them",
	)

/// Our pet died...
/datum/memory/pet_died
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	name_templates = list("The death of {TARGET}.")
	start_templates = list(
		"honoring {TARGET}, the station's beloved pet",
		"{TARGET}'s funeral, attended by a solemn group of crew members",
		"a shallow grave being dug for {TARGET}",
	)

/// The revolution was triumphant!
/datum/memory/revolution_rev_victory
	story_value = STORY_VALUE_LEGENDARY
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	name_templates = list("The revolution of {STATION} by {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} raising the flag of the revolution over the corpses of the former dictators",
		"a flag waving above a pile of corpses with {SUBJECT_ADJ} standing over it",
		"a poster that says {STATION} with a cross in it, hailing in a new era",
		"a statue of the former captain toppled over, with {SUBJECT_ADJ} next to it",
	)

/// Given to heads of staff if they lose a revolution and are alive still.
/datum/memory/revolution_heads_defeated
	story_value = STORY_VALUE_NONE
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	name_templates = list("The defeat of {SUBJECT} at the hands of the revolution.")
	start_templates = list(
		"{SUBJECT_ADJ} fleeing {STATION} in shame due to the success of the revolution",
		"{SUBJECT_ADJ} looking at a camera feed of rampaging revolutionaries",
		"a poster with {SUBJECT}'s face scratched out",
	)

/// Given to head revs for failing the revolution!
/datum/memory/revolution_rev_defeat
	story_value = STORY_VALUE_NONE
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	name_templates = list(
		"The defeat of {SUBJECT} at the hands of Nanotrasen.",
		"The end of {SUBJECT}'s glorious revolution.",
	)
	start_templates = list(
		"{SUBJECT_ADJ} fleeing {STATION} in shame due to the failure of their revolution",
	)

/// Given to heads of staff upon defeating the revolutionaries.
/datum/memory/revolution_heads_victory
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	name_templates = list("The success of {SUBJECT} and Nanotrasen over the hateful revolution.")
	start_templates = list(
		"{SUBJECT_ADJ} dusting off their hands in victory over the revolution",
		"the banner of Nanotrasen flying on the bridge of {STATION} with {SUBJECT_ADJ} proudly beside it",
	)

/// Watched someone receive a commendation medal.
/datum/memory/received_medal
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	name_templates = list("The award ceremony of {MEDAL_NAME} to {SUBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} accepting a {MEDAL_NAME} inscribed with \"{MEDAL_TEXT}\" from {TARGET}",
		"{SUBJECT_ADJ} receiving a {MEDAL_NAME} with the inscription \"{MEDAL_TEXT}\"",
		"a {MEDAL_NAME} with the inscription \"{MEDAL_TEXT}\" being awarded to {SUBJECT} by {TARGET_ADJ}",
	)

/// Killed a Megafauna.
/datum/memory/megafauna_slayer
	story_value = STORY_VALUE_LEGENDARY
	name_templates = list("The slaughter of {OBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} performing the final strike on {OBJECT}, taking it down",
		"{SUBJECT_ADJ} standing with the head of {OBJECT} in their hand",
		"the killing of {OBJECT}, the dangerous megafauna, by {SUBJECT_ADJ}",
	)

/// Got held at gunpoint by someone!
/datum/memory/held_at_gunpoint
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	associated_mood_category = "gunpoint"
	associated_mood_type = /datum/mood_event/gunpoint
	name_templates = list("{SUBJECT} being held at gunpoint.")
	start_templates = list(
		"{SUBJECT_ADJ} with {OBJECT} pressed to their skull by {TARGET_ADJ}",
		"{TARGET_ADJ} whipping out {OBJECT} and pointing it at {SUBJECT_ADJ}",
	)

/// Saw someone get gibbed.
/datum/memory/witness_gib
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	name_templates = list("{SUBJECT} exploding into bits.")
	start_templates = list(
		"{SUBJECT_ADJ} exploding into little fleshy bits",
		"{SUBJECT_ADJ} becoming flesh paste in the blink of an eye",
	)

/// Saw someone get crushed by a vending machine.
/datum/memory/witness_vendor_crush
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_SKIP_UNCONSCIOUS
	name_templates = list("{SUBJECT} being crushed by {OBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} being crushed by {OBJECT_ADJ}",
		"the {OBJECT} that crashed on top of {SUBJECT_ADJ}",
		"the fall of {OBJECT} onto {SUBJECT_ADJ}",
	)

/// Saw someone get dusted by the supermatter.
/datum/memory/witness_supermatter_dusting
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_CHECK_BLINDNESS
	name_templates = list("The dusting of {SUBJECT} by the {OBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} turning into a pile of bones after touching the {OBJECT}",
		"the {OBJECT} turning {SUBJECT_ADJ} into ash",
		"the dusting of {SUBJECT_ADJ} after they got too close to the {OBJECT}",
	)

/// Played cards with another person.
/datum/memory/playing_cards
	story_value = STORY_VALUE_MEH
	memory_flags = MEMORY_CHECK_BLINDNESS
	// NOTE: Mood is handled manually at the call site (playing_cards mood has custom add_effects logic)
	name_templates = list("The {GAME} of {SUBJECT} with {PLAYERS_LIST}.")
	start_templates = list(
		"{PLAYERS_LIST} waiting for {SUBJECT_ADJ} to start the {GAME}",
		"the {GAME} has been setup by {TARGET}",
		"{TARGET} starts shuffling the deck for the {GAME}",
	)

/// Played 52 card pickup with another person.
/datum/memory/playing_card_pickup
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	name_templates = list("{SUBJECT} tricking {TARGET} into playing 52 pickup with {OBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} tossing the {OBJECT} at {TARGET_ADJ} spilling cards all over the floor",
		"a {OBJECT} thrown by {SUBJECT_ADJ} splattering across {TARGET}'s face",
	)

/// Saw someone play Russian Roulette.
/datum/memory/witnessed_russian_roulette
	memory_flags = MEMORY_CHECK_BLINDNESS
	name_templates = list("{SUBJECT} playing a game of russian roulette.")
	start_templates = list(
		"{SUBJECT_ADJ} aiming at their {AIMED_AT} right before they pull the trigger",
		"the revolver has {ROUNDS_LOADED} rounds loaded in the chamber",
		"{SUBJECT_ADJ} gambling their life as they spin the revolver",
	)

/datum/memory/witnessed_russian_roulette/post_init()
	var/result = extra_data["result"]
	var/rounds = extra_data["rounds_loaded"]
	if(result == "won")
		story_value = max(STORY_VALUE_NONE, rounds)
	else
		story_value = STORY_VALUE_SHIT

/// When a heretic finishes their ritual of knowledge.
/datum/memory/heretic_knowledge_ritual
	story_value = STORY_VALUE_AMAZING
	name_templates = list("{SUBJECT} absorbing boundless knowledge through eldritch research.")
	start_templates = list(
		"{SUBJECT_ADJ} laying out a circle of green tar and candles",
		"multiple books around {SUBJECT_ADJ} flipping open",
		"green and purple energy surrounding {SUBJECT_ADJ}",
		"{SUBJECT_ADJ}, eyes wide open and unblinking, reading a strange book",
		"a pile of gore and viscera on a complex looking rune",
	)

/// Failed to defuse a bomb, by triggering it early.
/datum/memory/bomb_defuse_failure
	story_value = STORY_VALUE_NONE
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	name_templates = list("{SUBJECT} failing to defuse {OBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} cutting the wrong wire on {OBJECT}",
		"{SUBJECT_ADJ} sweating nervously and shielding their face as {OBJECT} makes a loud noise",
		"the clock on {OBJECT} suddenly jumping to 0 seconds",
	)

/// Succeeded in defusing a bomb!
/datum/memory/bomb_defuse_success
	story_value = STORY_VALUE_LEGENDARY
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	name_templates = list("{SUBJECT} successfully defusing {OBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} cutting the right wire on {OBJECT}",
		"{SUBJECT_ADJ} sweating nervously as {OBJECT} makes a shrill beep before going silent",
		"the clock on {OBJECT} stopping at {BOMB_TIME_LEFT}",
	)

/// Helped someone up.
/datum/memory/helped_up
	story_value = STORY_VALUE_OKAY
	name_templates = list("{SUBJECT} gentlemanly helping up {TARGET}.")
	start_templates = list(
		"{SUBJECT_ADJ} helping up {TARGET_ADJ}",
		"{TARGET_ADJ} taking the hand offered graciously by {SUBJECT} to get up",
	)

/// Catching a fish.
/datum/memory/caught_fish
	story_value = STORY_VALUE_OKAY
	associated_mood_category = "fishing"
	associated_mood_type = /datum/mood_event/fishing
	name_templates = list(
		"{SUBJECT} catching an absolute honker.",
		"{SUBJECT} caught a {TARGET}.",
	)
	start_templates = list(
		"{SUBJECT_ADJ} reels in the line",
		"{SUBJECT_ADJ}'s eye glints, and they begin reeling",
		"in a fishing trance, {SUBJECT_ADJ} catches something",
		"a whole lot of fishing going on",
	)

/// Becoming a mutant via infusion.
/datum/memory/dna_infusion
	story_value = STORY_VALUE_MEH
	name_templates = list(
		"{SUBJECT} infusing with a {TARGET}.",
		"{SUBJECT} infusing a {TARGET} into themselves.",
	)
	start_templates = list(
		"{SUBJECT_ADJ} enters a creepy DNA machine",
		"{SUBJECT_ADJ} partakes in some mad science",
		"the DNA infuser closes with {SUBJECT_ADJ} inside",
		"a {TARGET} is in the infusion slot",
	)

/// Who recruited me into the revolution.
/datum/memory/recruited_by_headrev
	name_templates = list("{SUBJECT} is converted into a revolutionary by {OBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ}'s mind sets itself on a singular, violent purpose as they're flashed by {OBJECT}: Kill the heads.",
		"{OBJECT} lifts an odd device to {SUBJECT}'s eyes and flashes them, imprinting murderous instructions.",
	)

/// Who converted me into a blood brother.
/datum/memory/recruited_by_blood_brother
	name_templates = list("{SUBJECT} is converted into a blood brother by {OBJECT}.")
	start_templates = list(
		"{OBJECT_ADJ} acts just a bit too friendly with {SUBJECT_ADJ}, moments away from converting them.",
		"{SUBJECT_ADJ} is brought into {OBJECT}'s life of crime and espionage.",
	)

/// Witnessed the wrath of a god.
/datum/memory/witnessed_gods_wrath
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_SKIP_UNCONSCIOUS
	story_value = STORY_VALUE_AMAZING
	name_templates = list("{SUBJECT} suffering the wrath of {OBJECT}.")
	start_templates = list(
		"{SUBJECT_ADJ} burns {TARGET}, and {OBJECT} turns {SUBJECT} into a fine red mist",
		"{OBJECT} explodes {SUBJECT_ADJ} into a million pieces for defiling {TARGET}",
		"{SUBJECT_ADJ} angers {OBJECT} by defiling {TARGET}, and gets obliterated",
	)

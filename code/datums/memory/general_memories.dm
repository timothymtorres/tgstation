/// A doctor successfuly completed a surgery on someone.
/datum/memory/surgery
	story_value = STORY_VALUE_OKAY
	// Protagonist - The surgeon, completing the surgery
	// Deuteragonist - The mob being operated on
	/// What type of surgery it was
	var/surgery_type

/datum/memory/surgery/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	surgery_type,
)
	src.surgery_type = surgery_type
	return ..()

/// Planted a bomb.
/datum/memory/bomb_planted
	story_value = STORY_VALUE_MEH
	// Protagonist - Whoever armed the bomb
	// Antaognist - The bomb that was armed

/// Planted a SYNDICATE bomb.
/datum/memory/bomb_planted/syndicate
	story_value = STORY_VALUE_AMAZING

/// Planted a NUKE!
/datum/memory/bomb_planted/nuke
	story_value = STORY_VALUE_LEGENDARY

/// Got a sweet high five.
/datum/memory/high_five
	story_value = STORY_VALUE_MEH
	// Protagonist - One of the high-fivers
	// Deuteragonist - The other high fiver
	/// What type of high five it was - A "high five" or a "high ten"
	var/high_five_type

/datum/memory/high_five/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	high_five_type,
	high_ten = FALSE,
)
	src.high_five_type = high_five_type
	src.story_value = high_ten ? STORY_VALUE_OKAY : STORY_VALUE_MEH
	return ..()

/// Was cyborgized.
/datum/memory/was_cyborged
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The mind of who was just cyborgized

/// Witnessed someone die nearby.
/datum/memory/witnessed_death
	story_value = STORY_VALUE_MEH // this is pretty common on this hellhole
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist - Who died

/// Witnessed someone get creampied nearby.
/datum/memory/witnessed_creampie
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The mob that got pied

/// Witnessed someone get splashed with squid ink.
/datum/memory/witnessed_inking
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The mob that got pied

/// Got slipped by something.
/datum/memory/was_slipped
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob that got slipped
	// Antagonist - The thing that did the slipping (banana peel, etc)

/datum/memory/was_slipped/build_story_character(character)
	// We can slip on turfs, so we should account for it
	if(isturf(character))
		var/turf/place = character
		return "the [prob(50) ? "perilous " : ""][pick("wet", "lubed", "slippery", "cold")] [place.name]"

	return ..()

/// Had spaghetti fall from their pockets.
/datum/memory/lost_spaghetti
	story_value = STORY_VALUE_AMAZING // This doesn't happen very often
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The mob losing their spaghet

/// Got kissed! AHHHHH!
/datum/memory/kissed
	story_value = STORY_VALUE_MEH
	// Sorry but blind people can't feel kisses...
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The mob being kissed
	// Deuteragonist - The mob doing the kissing

/// Had some good food.
/datum/memory/good_food
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob consuming the food
	/// The name of the food item being consumed
	var/food

/datum/memory/good_food/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	obj/item/food,
)
	src.food = food.name
	return ..()

/// Had a good drink.
/datum/memory/good_drink
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob consuming the drink
	/// The name of the nice drink reagent
	var/drink

/datum/memory/good_drink/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	datum/reagent/drink,
)
	src.drink = drink.name
	return ..()

/// Was set on fire and started to burn.
/datum/memory/was_burning
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob burning

/// Got a limb removed by force.
/datum/memory/was_dismembered
	story_value = STORY_VALUE_AMAZING
	// Protagonist - The mob who lost a limb
	/// The limb (in plaintext) that got lost (ends up being "left arm" or "right leg")
	var/lost_limb

/datum/memory/was_dismembered/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	obj/item/bodypart/lost_limb,
)
	src.lost_limb = lost_limb.plaintext_zone
	return ..()

/// Our pet died...
/datum/memory/pet_died
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist - The mob who saw the pet die
	// Deuteragonist - The pet which died

/// The revolution was triumphant!
/// Given to head revs and those nearby when the revs win a revolution.
/datum/memory/revolution_rev_victory
	story_value = STORY_VALUE_LEGENDARY
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist - The head revolutionary that won the revolution

/// Given to heads of staff if they lose a revolution and are alive still.
/datum/memory/revolution_heads_defeated
	story_value = STORY_VALUE_NONE
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The head of staff that lost the revolution

/// Given to head revs for failing the revolution!
/datum/memory/revolution_rev_defeat
	story_value = STORY_VALUE_NONE
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The head revolutionary that lost the revolution

/// Given to heads of staff, and those around them, upon defeating the revolutionaries.
/datum/memory/revolution_heads_victory
	story_value = STORY_VALUE_AMAZING // Not as cool as a rev victory. Everyone loves underdog stories
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The head of staff that won the revolution

/// Watched someone receive a commendation medal
/datum/memory/received_medal
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist - The person being given a medal
	// Deuteragonist - The mob awarding a medal
	/// The name of the medal being rewarded
	var/medal_type
	/// The text on the medal / the commendation / the input
	var/medal_text

/datum/memory/received_medal/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	obj/item/medal_type,
	medal_text,
)
	src.medal_type = medal_type.name
	src.medal_text = medal_text
	return ..()

/// Killed a Megafauna
/datum/memory/megafauna_slayer
	story_value = STORY_VALUE_LEGENDARY
	// Protagonist - The person who killed the megafauna
	// Antagonist - The megafauna

/// Got held at gunpoint by someone!
/datum/memory/held_at_gunpoint
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - Who was held at gunpoint
	// Deuteragonist - Who held them at gunpoint
	// Antagonist - The gun

/// Saw someone get gibbed.
/datum/memory/witness_gib
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - Who got gibbed

/// Saw someone get crushed by a vending machine.
/datum/memory/witness_vendor_crush
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - Who got crushed
	// Antagonist - The vendor that crushed them

/// Saw someone get dusted by the supermatter.
/datum/memory/witness_supermatter_dusting
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - Who got dusted
	// Antagonist - The supermatter

/// Played cards with another person.
/datum/memory/playing_cards
	story_value = STORY_VALUE_MEH
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The player
	// Deuteragonist - The game dealer (which may be a player OR in the players list)
	/// What card game is being played
	var/game
	/// The card the protagonist is holding
	var/protagonist_held_card
	/// A string (english list) of all the mobs playing the game
	var/formatted_players_list

/datum/memory/playing_cards/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	game,
	obj/item/protagonist_held_card,
	list/mob/living/other_players,
)
	src.game = game
	src.protagonist_held_card = protagonist_held_card.name

	var/list/story_players = list()
	for(var/mob/living/player as anything in other_players)
		// This will result in some strange structure sometimes -
		// "The assistant, the assistant, and the assistant playing a game",
		// but meh. Someone can improve upon it in the future
		story_players += build_story_character(player)

	src.formatted_players_list = english_list(story_players, nothing_text = "no-one")
	return ..()

/// Played 52 card pickup with another person.
/datum/memory/playing_card_pickup
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The guy who initiated the game
	// Deuteragonist - The guy who got the cards thrown in their face
	// Antagonist - The deck of cards

/// Saw someone play Russian Roulette.
/datum/memory/witnessed_russian_roulette
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist = The guy who played roulette
	// Antagonist = The revolver
	/// The bodypart the protagonist was aiming at
	var/aimed_at
	/// How many rounds were loaded in the revolver
	var/rounds_loaded
	/// The result of the game ("won"(survived) or "lost"(shot themselves))
	var/result

/datum/memory/witnessed_russian_roulette/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	aimed_at,
	rounds_loaded = 0,
	result,
)
	src.aimed_at = aimed_at
	src.rounds_loaded = rounds_loaded
	src.result = result

	if(result == "won")
		// The more bullets, the better the story.
		story_value = max(STORY_VALUE_NONE, rounds_loaded)
	else
		story_value = STORY_VALUE_SHIT

	return ..()

/// When a heretic finishes their ritual of knowledge
/datum/memory/heretic_knowledge_ritual
	story_value = STORY_VALUE_AMAZING
	// Protagonist = heretic

/// Failed to defuse a bomb, by triggering it early.
/datum/memory/bomb_defuse_failure
	story_value = STORY_VALUE_NONE // Anyone who gets this is probably dead
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist = (failed) defuser
	// Antagonist = bomb

/// Succeeded in defusing a bomb!
/datum/memory/bomb_defuse_success
	story_value = STORY_VALUE_LEGENDARY // Very sick, and can't be gotten from training bombs
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist = defuser
	// Antagonist = bomb
	/// This is the time left (in seconds) of the bomb at defusal
	var/bomb_time_left

/datum/memory/bomb_defuse_success/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	bomb_time_left = -1,
)
	src.bomb_time_left = bomb_time_left
	return ..()

/datum/memory/helped_up
	story_value = STORY_VALUE_OKAY

/// Catching a fish
/datum/memory/caught_fish
	story_value = STORY_VALUE_OKAY

/// Becoming a mutant via infusion
/datum/memory/dna_infusion
	story_value = STORY_VALUE_MEH
	///describing what they turn into, "skittish", "nomadic", etc
	var/mutantlike

/datum/memory/dna_infusion/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	mutantlike,
)
	src.mutantlike = mutantlike
	return ..()

/// Who rev'd me, so if a mindreader reads a rev, they have a clue on who to hunt down
/datum/memory/recruited_by_headrev

/// Who converted into a blood brother
/datum/memory/recruited_by_blood_brother

/// Saw someone play Russian Roulette.
/datum/memory/witnessed_gods_wrath
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_SKIP_UNCONSCIOUS
	story_value = STORY_VALUE_AMAZING

/datum/memory/witnessed_gods_wrath/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
)


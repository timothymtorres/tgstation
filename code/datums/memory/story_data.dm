/**
 * All story-generation data, formerly stored in memories.json.
 * Organized by story type (engraving, changeling_absorb, tattoo).
 */

/// Random creatures/items used in "something" flavor text
GLOBAL_LIST_INIT(story_something_pool, list(
	/mob/living/basic/bat,
	/mob/living/basic/bear,
	/mob/living/basic/butterfly,
	/mob/living/basic/carp,
	/mob/living/basic/carp/magic,
	/mob/living/basic/chick,
	/mob/living/basic/chicken,
	/mob/living/basic/cow,
	/mob/living/basic/crab,
	/mob/living/basic/goat,
	/mob/living/basic/gorilla,
	/mob/living/basic/killer_tomato,
	/mob/living/basic/lizard,
	/mob/living/basic/mining/goliath,
	/mob/living/basic/mining/watcher,
	/mob/living/basic/morph,
	/mob/living/basic/mouse,
	/mob/living/basic/mushroom,
	/mob/living/basic/parrot,
	/mob/living/basic/pet/cat,
	/mob/living/basic/pet/cat/cak,
	/mob/living/basic/pet/dog/corgi,
	/mob/living/basic/pet/dog/pug,
	/mob/living/basic/pet/fox,
	/mob/living/basic/spider/giant,
	/mob/living/basic/statue,
	/mob/living/basic/stickman,
	/obj/item/food/sausage/american,
	/obj/item/skub,
))

/// Foreword phrases per story type — the opening line of a story
GLOBAL_LIST_INIT(story_forewords, list(
	STORY_ENGRAVING = list(
		"Embedded in the wall is a story of",
		"In the engraving you can see the tale of",
		"On the wall, you see",
		"The engraving depicts",
		"This piece depicts",
	),
	STORY_CHANGELING_ABSORB = list(
		"A story of the past reveals itself, speaking of",
		"Deeply tangled in their mind is a memory of",
		"You unravel a story about",
		"Your mental spines begin unravelling a story of",
	),
	STORY_TATTOO = list(
		"Inked into the skin is a story of",
		"On the tattoo is a tale of",
		"The tattoo depicts",
		"This tattoo's story is of",
	),
))

/// Random flavor additions per story type — the "something" lines
GLOBAL_LIST_INIT(story_somethings, list(
	STORY_ENGRAVING = list(
		"{CREWMEMBER} is berating {SUBJECT} over the ordeal.",
		"{CREWMEMBER} is doing a sick ass backflip in the meantime!",
		"{CREWMEMBER} is shocked by the situation.",
		"{CREWMEMBER} is watching, crying at the situation.",
		"{CREWMEMBER} is watching, laughing at {SUBJECT}.",
		"{MEMORIZER} is also shown floating slightly above the ground.",
		"{MEMORIZER} is lying on the floor, defeated by a {SOMETHING}.",
		"{SUBJECT} also appears to be locked inside of an escape pod.",
		"{SUBJECT} can also be seen cringing at the sight of a {SOMETHING}.",
		"{SUBJECT} can also be seen secretly admiring a {SOMETHING}.",
		"{SUBJECT} has a cartoony thought bubble in the engraving.",
		"A {SOMETHING} stands in the background.",
		"A classic easter egg can be found in way of a {SOMETHING}.",
		"A crowd can be seen cheering in the background.",
		"A heavily pixelated {SOMETHING} is sitting there, ominously.",
		"A weeping statue of liberty can be seen in the corner.",
		"Also depicted is {CREWMEMBER} standing on top of a soapbox.",
		"Depicted also is {MEMORIZER}, having an intellectual talk with a {SOMETHING}.",
		"For some reason, {CREWMEMBER} is also there.",
		"In the meantime, {CREWMEMBER} is being arrested, clutching a {SOMETHING}.",
		"In the middle a {SOMETHING} is being worshipped by {MEMORIZER}.",
		"The bottom left has been signed by the author, {MEMORIZER}.",
		"The engraving has repeating text behind the foreground.",
		"The top part is dominated by a {SOMETHING}.",
		"There is a circle of dancing {SOMETHING}s.",
		"There is a tiny {SOMETHING} in the corner.",
	),
	STORY_CHANGELING_ABSORB = list(
		"You continue to peel away the story.",
		"Your mental spines dive deeper into the memory.",
	),
	STORY_TATTOO = list(
		"{CREWMEMBER} looms over the tattoo.",
		"{SOMETHING}s border around the main work.",
		"A chinese dragon swirls around the tattoo.",
		"A cobra stares out from the tattoo.",
		"A giant \"CHELP\" is in the background of the tattoo.",
		"A rainbow is at the top of the tattoo.",
		"A space kraken is holding the tattoo.",
		"A two headed space eagle soars across the tattoo.",
		"An inked anchor weighs down the tattoo.",
		"Holy shit, is that a {SOMETHING}?",
		"The tattoo has a drawing of a {SOMETHING} that says \"I LOST THE BET\".",
		"The tattoo has a giant flaming skull.",
		"The tattoo has weird philosophical quotes.",
		"The tattoo is bordered by a swirling space dragon.",
		"The tattoo says something in nekomimetic.",
	),
))

/// Art styles per story type — how the art looks
GLOBAL_LIST_INIT(story_styles, list(
	"generic" = list(
		"The {STORY_TYPE} has a generic style.",
	),
	STORY_ENGRAVING = list(
		"The engraving has a cubist style.",
		"The engraving has a minimalist style.",
		"The engraving has a surrealist style.",
	),
	STORY_TATTOO = list(
		"The tattoo is in a mad max style.",
		"The tattoo is styled to look cyberpunk.",
		"The tattoo looks cartoony.",
		"The tattoo looks like it was done by an amateur.",
		"The tattoo looks professional.",
		"This tattoo is Nanotrasen approved.",
		"This tattoo is Syndicate approved.",
	),
))

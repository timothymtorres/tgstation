/**
 * Story-generation data for engravings, tattoos, and changeling absorb.
 */

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

/// Art styles per story type
GLOBAL_LIST_INIT(story_styles, list(
	"generic" = list(
		"The {STORY_TYPE} has a simplistic style.",
		"The {STORY_TYPE} is done in a crude fashion.",
	),
	STORY_ENGRAVING = list(
		"The engraving has a cubist style.",
		"The engraving has a minimalist style.",
		"The engraving has a surrealist style.",
	),
	STORY_TATTOO = list(
		"The tattoo is styled to look cyberpunk.",
		"The tattoo looks cartoony.",
		"The tattoo looks like it was done by an amateur.",
		"The tattoo looks professional.",
	),
))

/**
 * Holds anonymized character information for a memory.
 *
 * Stores a persistence-safe name and a list of adjectives
 * captured at the time the memory was created, reflecting
 * the character's state at that moment.
 */
/datum/memory_character
	/// The anonymized name: "the assistant", "a banana peel"
	var/name = "someone"
	/// Adjectives captured at creation: list("bloody", "stumbling")
	var/list/adjectives

/**
 * Returns the character name with adjectives inserted.
 *
 * Arguments:
 * * max_adj - Maximum number of adjectives to include.
 */
/datum/memory_character/proc/describe(max_adj = 2)
	if(!length(adjectives) || max_adj <= 0)
		return name

	var/list/picked = list()
	var/list/pool = adjectives.Copy()
	for(var/i in 1 to min(max_adj, length(pool)))
		picked += pick_n_take(pool)

	var/adj_string = picked.Join(", ")

	// Insert adjectives after the article
	if(findtext(name, "the ", 1, 5))
		return "the [adj_string] [copytext(name, 5)]"
	if(findtext(name, "a ", 1, 3))
		return "a [adj_string] [copytext(name, 3)]"
	if(findtext(name, "an ", 1, 4))
		return "an [adj_string] [copytext(name, 4)]"

	return "[adj_string] [name]"

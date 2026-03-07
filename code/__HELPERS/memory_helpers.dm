/**
 * Adds a memory to all carbon mobs in a certain range of a certain atom.
 *
 * The third argument should be a typepath of a /datum/memory.
 *
 * Beyond that, can be supplied with named arguments:
 * * subject: The main character / doer of the action
 * * target: The secondary character / receiver of the action
 * * object: The tertiary element / thing involved
 * * skip_mood: If TRUE, don't fire the associated mood event
 *
 * Any other named arguments are stored in extra_data and available as {UPPERCASE_KEY} in templates.
 */
#define add_memory_in_range(source, range, arguments...) _add_memory_in_range(source, range, list(##arguments))

/// Unless you need to use this for an explicit reason, use the add_memory_in_range macro wrapper.
/proc/_add_memory_in_range(atom/source, range = 7, list/memory_args)
	for(var/mob/living/carbon/memorizer in hearers(range, source))
		memorizer.mind?._add_memory(memory_args.Copy())

/**
 * Adds a memory to the target mob.
 *
 * The first argument should be a typepath of a /datum/memory.
 * Returns the datum memory created, or null otherwise.
 */
#define add_mob_memory(arguments...) mind?._add_memory(list(##arguments))

/**
 * Adds a memory to the target mind.
 *
 * The first argument should be a typepath of a /datum/memory.
 * Returns the datum memory created, or null otherwise.
 */
#define add_memory(arguments...) _add_memory(list(##arguments))

/// Core proc for creating and registering a memory on a mind.
/datum/mind/proc/_add_memory(list/memory_args)
	RETURN_TYPE(/datum/memory)

	var/datum/memory/memory_type = memory_args[1]
	if(!ispath(memory_type))
		CRASH("add_memory called with an invalid memory type. (Got: [memory_type || "null"])")

	// Pre-creation checks based on the type's initial flags
	if(current)
		var/new_flags = initial(memory_type.memory_flags)
		if(!(new_flags & MEMORY_SKIP_UNCONSCIOUS) && current.stat >= UNCONSCIOUS)
			return
		if((new_flags & MEMORY_CHECK_BLINDNESS) && current.is_blind())
			return
		if((new_flags & MEMORY_CHECK_DEAFNESS) && HAS_TRAIT(current, TRAIT_DEAF))
			return

	// Delete existing memory of same type
	var/datum/memory/replaced = memories[memory_type]
	if(replaced)
		qdel(replaced)

	// Extract standard arguments
	var/atom/subject_atom = memory_args["subject"]
	var/atom/target_atom = memory_args["target"]
	var/atom/object_atom = memory_args["object"]
	var/skip_mood = memory_args["skip_mood"]

	// Build extra_data from remaining named args
	var/list/extra_data = list()
	for(var/key in memory_args)
		if(!istext(key))
			continue
		if(key in GLOB.memory_reserved_keys)
			continue
		extra_data[key] = memory_args[key]

	// Create the memory
	var/datum/memory/created = new memory_type(src, subject_atom, target_atom, object_atom, extra_data)
	memories[memory_type] = created

	// Fire associated mood event
	if(!skip_mood && created.associated_mood_type && current)
		var/category = created.associated_mood_category || REF(created)
		var/list/mood_call_args = list(category, created.associated_mood_type)
		if(length(created.mood_arg_keys) && length(extra_data))
			for(var/key in created.mood_arg_keys)
				if(key in extra_data)
					mood_call_args += extra_data[key]
		current.add_mood_event(arglist(mood_call_args))

	return created

/**
 * Simple / sane proc for giving a mob the option to select one of their memories
 * that do not have the flags MEMORY_FLAG_ALREADY_USED or MEMORY_NO_STORY.
 */
/datum/mind/proc/select_memory(verbage = "use")
	RETURN_TYPE(/datum/memory)
	var/list/choice_list = list()

	for(var/key in memories)
		var/datum/memory/memory_iter = memories[key]
		if(memory_iter.memory_flags & (MEMORY_FLAG_ALREADY_USED|MEMORY_NO_STORY))
			continue
		choice_list[memory_iter.name] = memory_iter

	var/choice = tgui_input_list(usr, "Select a memory to [verbage]", "Memory Selection?", choice_list)
	if(isnull(choice) || isnull(choice_list[choice]))
		return null

	return choice_list[choice]

/// Wipes all memories from this mind.
/datum/mind/proc/wipe_memory()
	QDEL_LIST_ASSOC_VAL(memories)

/// Wipes a specific memory type from this mind.
/datum/mind/proc/wipe_memory_type(memory_type)
	qdel(memories[memory_type])
	memories -= memory_type

/// Creates quick copies of all memories for another mind.
/datum/mind/proc/quick_copy_all_memories(datum/mind/new_memorizer)
	for(var/memory_path in memories)
		var/datum/memory/prime_memory = memories[memory_path]
		new_memorizer.memories[memory_path] = prime_memory.quick_copy_memory(new_memorizer)

// === CHARACTER BUILDING ===

/**
 * Builds a memory_character datum from an atom, capturing adjectives at this moment.
 */
/proc/build_memory_character(atom/source)
	if(isnull(source))
		return null

	var/datum/memory_character/char = new()
	char.name = build_character_name(source)

	if(isliving(source))
		char.adjectives = collect_mob_adjectives(source)
	else if(isturf(source))
		char.adjectives = collect_turf_adjectives(source)

	return char

/**
 * Returns an anonymized name for a character, suitable for cross-round persistence.
 */
/proc/build_character_name(source)
	if(isnull(source))
		return "someone"
	if(istext(source))
		return source

	// Mind → job title
	if(istype(source, /datum/mind))
		var/datum/mind/mind_source = source
		if(mind_source.assigned_role && !is_unassigned_job(mind_source.assigned_role))
			return "the [LOWER_TEXT(mind_source.assigned_role.title)]"
		return "the unfamiliar person"

	// Living mob → check for job, otherwise use name
	if(isliving(source))
		var/mob/living/living_source = source
		if(living_source.mind?.assigned_role && !is_unassigned_job(living_source.mind.assigned_role))
			return "the [LOWER_TEXT(living_source.mind.assigned_role.title)]"
		if(ishuman(source))
			return "the unfamiliar person"
		return "the [living_source.name]"

	// Turfs
	if(isturf(source))
		var/turf/turf_source = source
		return "the [turf_source.name]"

	// Objects and everything else
	if(isatom(source))
		return "\a [source]"

	return "something"

/**
 * Collects adjectives for a living mob based on their current traits, status effects, and state.
 */
/proc/collect_mob_adjectives(mob/living/target)
	var/list/adjectives = list()

	// Trait-based adjectives
	for(var/trait in target.status_traits)
		var/list/adj_pool = GLOB.memory_trait_adjectives[trait]
		if(length(adj_pool))
			adjectives += pick(adj_pool)

	// Status effect adjectives
	for(var/datum/status_effect/effect as anything in target.status_effects)
		for(var/effect_type in GLOB.memory_status_adjectives)
			if(istype(effect, effect_type))
				adjectives += pick(GLOB.memory_status_adjectives[effect_type])
				break

	// Human-specific adjectives
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target

		// Bloody
		if(human_target.is_bleeding())
			adjectives += "bleeding"
		if(!human_target.gloves && human_target.blood_in_hands && human_target.num_hands > 0)
			adjectives += "bloodstained"

		// Armed
		for(var/obj/item/held in human_target.held_items)
			if(held?.item_flags & NEEDS_PERMIT)
				adjectives += "armed"
				break

		// Masked/anonymous identity
		if(human_target.get_visible_name() == "Unknown")
			adjectives += pick("masked", "anonymous", "disguised")

		// ID mismatch (impersonation)
		var/face_name = human_target.get_face_name("")
		var/id_name = human_target.get_id_name("")
		if(face_name && id_name && id_name != face_name)
			adjectives += pick("deceitful", "deceptive")

		// Restrained
		if(human_target.handcuffed)
			adjectives += pick("cuffed", "restrained")

		// On fire
		if(human_target.on_fire)
			adjectives += "burning"

		// In darkness
		if(!human_target.has_light_nearby())
			adjectives += pick("shadowy", "lurking")

		// Hidden inside something
		if(!isturf(human_target.loc))
			adjectives += "hidden"

	// Deduplicate
	return unique_list(adjectives)

/**
 * Collects adjectives for a turf (used when a turf is the "object" of a memory, like slipping).
 */
/proc/collect_turf_adjectives(turf/target)
	var/list/adjectives = list()
	if(HAS_TRAIT(target, TRAIT_TURF_WET))
		adjectives += pick("wet", "slippery", "lubed")
	return adjectives

/**
 * Collects adjectives for the location/area where a memory takes place.
 */
/proc/collect_location_adjectives(turf/current_turf)
	var/list/adjectives = list()
	if(!current_turf)
		return adjectives

	var/area/location = get_area(current_turf)
	if(!location || istype(location, /area/space) || location.outdoors)
		return adjectives

	// Power state
	if(location.requires_power && !location.always_unpowered)
		if(!location.powered(AREA_USAGE_EQUIP))
			adjectives += "unpowered"

	// Lighting — check the memorizer's turf directly
	if(!location.powered(AREA_USAGE_LIGHT) || !location.lightswitch)
		adjectives += "dark"
	else if(current_turf.get_lumcount() <= LIGHTING_TILE_IS_DARK)
		adjectives += "dim"

	// Beauty
	switch(location.beauty)
		if(-INFINITY to BEAUTY_LEVEL_HORRID)
			adjectives += pick("filthy", "wretched")
		if(BEAUTY_LEVEL_HORRID to BEAUTY_LEVEL_BAD)
			adjectives += pick("dingy", "messy")
		if(BEAUTY_LEVEL_GOOD to BEAUTY_LEVEL_GREAT)
			adjectives += pick("tidy", "pleasant")
		if(BEAUTY_LEVEL_GREAT to INFINITY)
			adjectives += pick("pristine", "luxurious")

	// Atmosphere checks
	if(isopenturf(current_turf))
		var/datum/gas_mixture/air = current_turf.return_air()
		if(air)
			if(air.temperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
				adjectives += pick("frigid", "freezing")
			else if(air.temperature >= BODYTEMP_HEAT_DAMAGE_LIMIT)
				adjectives += pick("scorching", "sweltering")

	// Gravity
	if(!current_turf.has_gravity())
		adjectives += "weightless"

	return adjectives

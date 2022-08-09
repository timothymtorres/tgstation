
///Adds a memory to people that can see this happening, only use this for impactful or rare events to reduce overhead.
/proc/add_memory_in_range(atom/source, range, memory_type, extra_info, story_value, memory_flags, protagonist_memory_flags)
	var/list/memorizers = hearers(range, source)
	if(!isnull(protagonist_memory_flags))
		var/mob/living/carbon/protagonist = extra_info[DETAIL_PROTAGONIST]
		if(istype(protagonist))
			memorizers -= protagonist
			protagonist.mind?.add_memory(memory_type, extra_info, story_value, protagonist_memory_flags)
	for(var/mob/living/carbon/memorizer in memorizers)
		memorizer.mind?.add_memory(memory_type, extra_info, story_value, memory_flags)

/**
 * add_memory
 *
 * Adds a memory to a mob's mind if conditions are met, called wherever the memory takes place (memory for catching on fire in mob's fire code, for example)
 * Argument:
 * * memory_type: defined string in memory_defines.dm, shows the memories.json file which story parts to use (and generally what type it is)
 * * extra_info: the contents of the story. You're gonna want at least the protagonist for who is the main character in the story (Any non basic type will be converted to a string on insertion)
 * * story_value: the quality of the memory, make easy or roundstart memories have a low value so they don't flood persistence
 * * memory_flags: special specifications for skipping parts of the memory like moods for stories where showing moods doesn't make sense
 * Returns the datum memory created, null otherwise.
 */
/datum/mind/proc/add_memory(memory_type, extra_info, story_value, memory_flags)
	if(current)
		if(!(memory_flags & MEMORY_SKIP_UNCONSCIOUS) && current.stat >= UNCONSCIOUS)
			return
		var/is_blind = FALSE
		if(memory_flags & MEMORY_CHECK_BLINDNESS && current.is_blind())
			if(!(memory_flags & MEMORY_CHECK_DEAFNESS)) // Only check for blindness
				return
			is_blind = TRUE // Otherwise check if the mob is both blind and deaf
		if(memory_flags & MEMORY_CHECK_DEAFNESS && HAS_TRAIT(current, TRAIT_DEAF) && (!(memory_flags & MEMORY_CHECK_BLINDNESS) || is_blind))
			return

	var/story_mood = MOODLESS_MEMORY
	var/victim_mood = MOODLESS_MEMORY

	extra_info[DETAIL_PROTAGONIST] = extra_info[DETAIL_PROTAGONIST] || current //If no victim is supplied, assume it happend to the memorizer.
	var/atom/victim = extra_info[DETAIL_PROTAGONIST]
	if(!(memory_flags & MEMORY_FLAG_NOLOCATION))
		extra_info[DETAIL_WHERE] = get_area(victim)

	if(!(memory_flags & MEMORY_FLAG_NOMOOD))
		var/datum/component/mood/victim_mood_component = current.GetComponent(/datum/component/mood)
		if(victim_mood_component)
			victim_mood = victim_mood_component.mood_level

		if(victim == current)
			story_mood = victim_mood
		else
			var/datum/component/mood/memorizer_mood_component = current.GetComponent(/datum/component/mood)
			if(memorizer_mood_component)
				story_mood = memorizer_mood_component.mood_level

	extra_info[DETAIL_PROTAGONIST_MOOD] = victim_mood

	var/datum/memory/replaced_memory = memories[memory_type]
	if(replaced_memory)
		qdel(replaced_memory)

	var/extra_info_parsed = list()

	for(var/key in extra_info)
		var/detail = extra_info[key]
		extra_info_parsed[key] = build_story_detail(detail)

	memories[memory_type] = new /datum/memory(src, build_story_mob(current), memory_type, extra_info_parsed, story_mood, story_value, memory_flags)
	return memories[memory_type]




/datum/mind/proc/create_memory(mob/living/target)
	var/area/location = get_area(target)
	var/turf/current_turf = get_turf(target)

	var/list/mob_adjectives = get_mob_adjectives(target)
	var/list/mob_nouns = get_mob_nouns(target)
	var/list/location_adjectives = get_location_adjectives(current_turf)




///returns a noun for the mob
/datum/mind/proc/get_mob_nouns(mob/living/target)
	var/list/mob_nouns = list()

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/visible_name = human_target.get_visible_name()
		// make this into a trait
		// if the person is a masked "Unknown"
		if(visible_name != "Unknown")
			// species types (human, plasmamen, moth, etc.)
			if(human_target.dna && human_target.dna.species.id)
				mob_nouns += human_target.dna.species.id

			// we should probably segregate this, since actual names have different grammar rules
			mob_nouns += visible_name

		var/job_assignment = human_target.get_assignment(if_no_id = FALSE, if_no_job = FALSE, hand_first = FALSE)
		if(job_assignment)
			mob_nouns += job_assignment

		// we also want a bunch of snowflake checks for antags
		// is someone wearing wizard robes?
		// is a chanegling absorbing someone or have an arm blade?
		// is someone holding nuke ops weapons and gear?
		// then we want their noun to be - the changeling, the nuclear operative, the wizard, etc.

	return mob_nouns




///returns an adjective for the mob
/datum/mind/proc/get_mob_adjectives(mob/living/target)
	var/list/mob_adjectives = list()

	// this needs to be tested
	for(var/trait in target.status_traits)
		if(GLOB.mob_trait_adjectives[trait])
			mob_adjectives += pick(GLOB.mob_trait_adjectives[trait])

	// and this needs testing as well
	for(var/datum/status_effect/present_effect as anything in target.status_effects)
		if(GLOB.mob_status_adjectives[present_effect])
			mob_adjectives += pick(GLOB.mob_status_adjectives[present_effect])

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target

		// if hands are bloody (tbh this should be a trait)
		if(!human_target.gloves && human_target.blood_in_hands && (human_target.num_hands > 0))
			mob_adjectives += "bloody"
		else // or if clothes are covered in blood
			// pretty sure this code doesn't work and needs to be double checked
			for(var/obj/bloody_item in human_target.get_all_slots() | human_target.held_items)
				if(!QDELETED(bloody_item) && HAS_BLOOD_DNA(bloody_item))
					mob_adjectives += "bloody"
					break

		// if they're holding a gun
		for(var/obj/item/possible_weapon in list(human_target.held_items[RIGHT_HANDS], human_target.held_items[LEFT_HANDS], human_target.belt, human_target.back))
			if(possible_weapon.item_flags & NEEDS_PERMIT)
				mob_adjectives += "armed"
				break

		// also these just aren't for humans, it could be for simple mobs or silicons
		if(prob(10)) // these should be a low chance since they are common
			if(human_target.m_intent == MOVE_INTENT_WALK)
				mob_adjectives += "walking"
			else if(human_target.m_intent == MOVE_INTENT_RUN)
				mob_adjectives += "running"

			if(human_target.combat_mode)
				mob_adjectives += "adverse"
			else
				mob_adjectives += "helpful"

		// make this into a trait
		// if the person is a masked "Unknown"
		if(human_target.get_visible_name() == "Unknown")
			mob_adjectives += pick("unknown", "anonymous", "disguised", "masked", "clandestine", "covert", "suspicious")

		// make this into a trait
		// if there is a mismatch between their ID and face ie. "John Doe (as George Melons)"
		var/face_name = human_target.get_face_name("")
		var/id_name = human_target.get_id_name("")
		if(face_name && id_name && (id_name != face_name))
			mob_adjectives += pick("imitated", "fake", "deceitful", "deceptive")

		if(human_target.handcuffed)
			mob_adjectives += pick("handcuffed", "restrained", "shackled")
		if(human_target.legcuffed)
			mob_adjectives += pick("legcuffed", "restrained", "shackled")

		if(!human_target.has_light_nearby())
			mob_adjectives += pick("shadowy", "dark", "lurking", "sneaking", "creeping")

		if(!isturf(human_target.loc) || human_target.is_holding(/obj/item/kirbyplants))
			mob_adjectives += pick("hidden", "concealed")

		if(human_target.status_flags & GODMODE)
			mob_adjectives += "immortal"

		if(human_target.is_bleeding())
			mob_adjectives += "bleeding"
		if(human_target.on_fire())
			mob_adjectives += "burning"

	return mob_adjectives

///returns a list of adjectives for the location the event takes place
/datum/mind/proc/get_location_adjectives(turf/current_turf)
	var/list/location_adjectives = list()
	var/area/location = get_area(current_turf)

	// area is too big to be considered a room
	if(location.areasize > AREASIZE_TOO_BIG_FOR_ROOM)
		return location_adjectives

	// double check this logic to make sure it's valid
	if(location.requires_power && !location.always_unpowered)
		var/list/location_turfs = get_area_turfs(location)
		var/is_area_breached = FALSE
		var/lit_turfs = 0
		var/ignored_turfs = 0

		// we are going to count all the turfs in our area and see if they are lit
		for(var/turf/area_turf in location_turfs)
			if(area_turf.density || isgroundlessturf(area_turf)) // stuff like walls & openspace don't count
				ignored_turfs += 1
			else if(area_turf.get_lumcount() > LIGHTING_TILE_IS_DARK) // if turf has enough lighting then we tally it
				lit_turfs += 1

			if(isspaceturf(area_turf))
				is_area_breached = TRUE

		// may want to add a check to prevent maintanence areas from being "powered"
		// power is pretty simple to check (Hey double check what happens if we short or destroy the areas APC)
		location_adjectives += location.powered(AREA_USAGE_EQUIP) ? "powered" : "unpowered"

		// lighting descriptions
		if(location.powered(AREA_USAGE_LIGHT) && location.lightswitch)
			var/night_lighting = FALSE
			var/blinking = FALSE

			if(location.fire)
				blinking = TRUE
			for(var/obj/machinery/light/area_light in location)
				if(area_light.nightshift_enabled)
					night_lighting = TRUE
				if(area_light.low_power_mode || area_light.major_emergency || area_light.flickering)
					blinking = TRUE

			var/lit_area_percent = 0
			if(lit_turfs && (length(location_turfs) - ignored_turfs)) // we don't wanna accidentally divide by zero
				lit_area_percent = lit_turfs / (length(location_turfs) - ignored_turfs)

			if(lit_area_percent <= 0.20) // 0%-20% lighting
				location_adjectives += "dark"
			else if(lit_area_percent <= 0.60) // 20%-60% lighting
				location_adjectives += "dim"
			else // 60%-100% lighting
				location_adjectives += "lit"
				if(blinking)
					location_adjectives += pick("blinking", "flickering", "flashing")
				else if(night_lighting)
					location_adjectives += "tinted"
		else // APC light switch is off
			location_adjectives += "dark"

		if(is_area_breached)
			location_adjectives += "breached"
		else if(location.powered(AREA_USAGE_ENVIRON) && location.air_alarm)
			if(location.air_alarm.mode == AALARM_MODE_SCRUBBING)
				location_adjectives += "ventilated"
			else if(location.air_alarm.mode == AALARM_MODE_SCRUBBING || location.air_alarm.mode == AALARM_MODE_PANIC)
				location_adjectives += "siphoned"
			else if(location.air_alarm.mode == AALARM_MODE_REFILL || location.air_alarm.mode == AALARM_MODE_FLOOD)
				location_adjectives += "inflating"
		// if APC environment switch off, no air alarm present, air alarm turned off, or air alarm shorted by cut wire
		else if(!location.powered(AREA_USAGE_ENVIRON) || !location.air_alarm || location.air_alarm.mode == AALARM_MODE_OFF || location.air_alarm.shorted)
			location_adjectives += "unventilated"

	if(!istype(location, /area/space))

		if(!current_turf.has_gravity())
			location_adjectives += "zero-gravity"

		switch(location.beauty)
			if(-INFINITY to BEAUTY_LEVEL_HORRID)
				location_adjectives += pick("nasty", "filthy", "trashy", "littered")
			if(BEAUTY_LEVEL_HORRID to BEAUTY_LEVEL_BAD)
				location_adjectives += pick("untidy", "messy", "unkempt")
			if(BEAUTY_LEVEL_BAD to BEAUTY_LEVEL_DECENT)
				// plain jane room gets no description
			if(BEAUTY_LEVEL_DECENT to BEAUTY_LEVEL_GOOD)
				location_adjectives += pick("organized", "furnished", "tidy")
			if(BEAUTY_LEVEL_GOOD to BEAUTY_LEVEL_GREAT)
				location_adjectives += pick("spotless", "clean", "sanitary")
			if(BEAUTY_LEVEL_GREAT to INFINITY)
				location_adjectives += pick("luxurious", "immaculate", "elegant", "polished")

		// time to check environemental hazards
		var/datum/gas_mixture/environment = current_turf.return_air()
		if(isfloorturf(current_turf) && environment)
			var/list/env_gases = environment.gases
			var/list/gases_to_check = list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide)
			var/toxic_gases
			for(var/id in env_gases)
				if(id in gases_to_check)
					continue
				toxic_gases = TRUE
				break

			if(toxic_gases || (env_gases[/datum/gas/carbon_dioxide] && env_gases[/datum/gas/carbon_dioxide][MOLES] >= 10))
				location_adjectives += pick("polluted", "contaminated", "noxious", "nauseous")
			if(!(env_gases[/datum/gas/oxygen] && env_gases[/datum/gas/oxygen][MOLES] >= 16))
				location_adjectives += "asphyxiating"

			var/env_temperature = enviornment.temperature
			if(env_temperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
				location_adjectives += pick("frigid", "frozen", "freezing")
			else if(env_temperature >= BODYTEMP_HEAT_DAMAGE_LIMIT)
				location_adjectives += pick("searing", "scorching", "burning")

			var/env_pressure = environment.return_pressure()
			if(env_pressure <= HAZARD_LOW_PRESSURE)
				location_adjectives += pick("depressurized", "decompressed")
			else if (env_pressure >= HAZARD_HIGH_PRESSURE)
				location_adjectives += pick("overpressurized", "compressed")

	return location_adjectives

///returns the story name of a mob
/datum/mind/proc/build_story_mob(mob/living/target)
	if(isanimal(target))
		return "\the [target]"
	if(target.mind?.assigned_role)
		return  "\the [lowertext(initial(target.mind?.assigned_role.title))]"
	return target

///returns the story name of anything
/datum/mind/proc/build_story_detail(detail)
	if(!isatom(detail))
		return detail //Its either text or deserves to runtime.
	var/atom/target = detail
	if(isliving(target))
		return build_story_mob(target)
	return lowertext(initial(target.name))

///sane proc for giving a mob with a mind the option to select one of their memories, returns the memory selected (null otherwise)
/datum/mind/proc/select_memory(verbage)

	var/list/choice_list = list()

	for(var/key in memories)
		var/datum/memory/memory_iter = memories[key]
		if(memory_iter.memory_flags & MEMORY_FLAG_ALREADY_USED) //Can't use memories multiple times
			continue
		choice_list[memory_iter.name] = memory_iter

	var/choice = tgui_input_list(usr, "Select a memory to [verbage]", "Memory Selection?", choice_list)
	if(isnull(choice))
		return FALSE
	if(isnull(choice_list[choice]))
		return FALSE
	var/datum/memory/memory_choice = choice_list[choice]

	return memory_choice

///small helper to clean out memories
/datum/mind/proc/wipe_memory()
	QDEL_LIST_ASSOC_VAL(memories)

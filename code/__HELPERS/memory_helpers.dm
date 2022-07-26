
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

GLOBAL_LIST_INIT(mob_trait_adjectives, list(
	TRAIT_DEAD = list("dead", "deceased", "lifeless"),
	// appearance
	TRAIT_DWARF = list("dwarf", "small", "tiny"),
	TRAIT_GIANT = list("giant", "tall", "large"),
	TRAIT_FAT = list("fat", "chubby", "obese"),
	TRAIT_HUNGRY = list("hungry", "drooling"),
	TRAIT_STARVING = list("starving", "malnourished"),
	TRAIT_HOLY = list("divine", "holy", "devout", "heavenly"),
	TRAIT_CULT_HALO = list("sinster", "unholy", "corrupted", "hellish"),
	TRAIT_HUSKED = list("husked"),
	TRAIT_IRRADIATED = list("glowing", "radioactive", "luminous", "radiant"),
	TRAIT_XRAY_VISION = list("peering", "leering", "watchful")
	TRAIT_HULK = list("hulking", "muscular", "strong"),
	TRAIT_NEARSIGHT = list("nearsighted"),
	TRAIT_MUTE = list("silent", "mute", "quiet"),
	TRAIT_BLIND = list("blind"),
	TRAIT_DEAF = list("deaf"),
	TRAIT_CLUMSY = list("clumsy"),
	TRAIT_ILLITERATE = list("illiterate", "dumb"),
	TRAIT_DISFIGURED = list("disfigured"),
	TRAIT_SILENT_FOOTSTEPS = list("stealthy"),
	TRAIT_NO_SOUL = list("soulless", "forsaken", "tainted", "defiled", "desecrated", "undead"),
	TRAIT_BLUSHING = list("blushing"),
	TRAIT_MOVE_FLYING = list("flying"),
	TRAIT_MOVE_FLOATING = list("floating", "drifting"),
	TRAIT_FLOORED = list("crawling", "resting", "fallen"),
	TRAIT_BLOODSHOT_EYES = list("drugged", "restless", "shaky"),
	TRAIT_HARDLY_WOUNDED = list("tough"),
	TRAIT_FEARLESS = list("fearless"),
	TRAIT_KNOCKEDOUT = list("unconcious"),
	TRAIT_CRITICAL_CONDITION = list("dying"),

	TRAIT_HEADLESS = list("headless", "decapitated", "beheaded"),
	TRAIT_SMOKING = list("smoking"),
	TRAIT_DISEASED = list("sick", "infected", "diseased"),
	TRAIT_SUICIDAL = list("suicidal"),
	TRAIT_SUFFOCATING = list("suffocating", "gasping", "choking"),
	TRAIT_NAKED = list("naked", "nude", "undressed"),
	TRAIT_BUCKLED = list("buckled", "sitting"), // at some point make traits for riding vehicles (scooters, borgs, skateboard, etc.)

	// quirks
	TRAIT_PACIFISM = list("gentle", "harmless", "innocent"),
	TRAIT_DEPRESSION = list("depressed", "sad", "moody"),
	TRAIT_JOLLY = list("happy", "smiling", "cheerful"),
	TRAIT_HEAVY_SLEEPER = list("sleepy", "tired"),
	TRAIT_SPIRITUAL = list("spiritual"),
	TRAIT_VORACIOUS = list("voracious"),
	TRAIT_FREERUNNING = list("athletic", "nimble"),
	TRAIT_SKITTISH = list("skittish", "frisky", "fidgetey"),
	TRAIT_FRIENDLY = list("friendly", "compassionate", "pleasant", "tender"),
	TRAIT_SNOB = list("rude", "pretentious", "obnoxious"),
	TRAIT_BALD = list("bald"),
	TRAIT_EXTROVERT = list("extroverted", "outgoing"),
	TRAIT_INTROVERT = list("introverted", "shy"),
	TRAIT_ANXIOUS = list("anxious", "stammering", "stuttering", "nervous", "mumbling"), // put some of these into other quirks/traits
	TRAIT_EMPATH = list("empathetic", "sympathetic"),
	TRAIT_GRABWEAKNESS = list("feeble", "wimpy", "weak"),
	TRAIT_CLOWN_ENJOYER = list("goofy", "silly"),
	TRAIT_MIME_FAN = list("serious", "stern"),
	TRAIT_LIGHT_STEP = list("cautious", "careful"),
	TRAIT_SELF_AWARE = list("observant", "perceptive", "attentive"),
	TRAIT_TAGGER = list("delinquent", "mischievous", "miscreant"),
	TRAIT_BADTOUCH = list("evasive", "shunned", "alienated", "lonely"),
	TRAIT_EASILY_WOUNDED = list("fragile", "frail"),
	TRAIT_INSANITY = list("insane", "delirious", "crazy", "psychotic"),
	TRAIT_UNSTABLE = list("unstable", "erratic", "deranged", "demented"),
	TRAIT_PHOTOGRAPHER = list("photogenic"),
	TRAIT_APATHETIC = list("apathetic", "emotionless", "bored", "heartless"),
	TRAIT_HYPERSENSITIVE = list("bipolar", "hysterical"),
	TRAIT_BLOOD_DEFICIENCY = list("pale", "ailing"),
	TRAIT_BAD_BACK = list("hunched", "crooked"),
	TRAIT_FAMILY_HEIRLOOM = list("possessive"),
	TRAIT_FOREIGNER = list("exotic"),
	TRAIT_PARAPLEGIC = list("crippled"),
	TRAIT_JUNKIE = list("twitchy", "jittery", "jumpy"),
	TRAIT_ALLERGIC = list("allergic"),
	TRAIT_CLAUSTROPHOBIC = list("claustrophobic"),
	TRAIT_PHOBIA = list("fearful", "afraid"),
	TRAIT_TONGUE_TIED = list("speechless", "inarticulate", "incoherent"),
	TRAIT_GAMER = list("nerdy", "geeky"),

	//berserk is the trait source? BERSERK_TRAIT = list("harmful", "dangerious", "violent"),
	// these trait doesn't exist yet, plz don't forget to add
	//TRAIT_AFRAID = list("terrified", "panicking", "trembling"
))

///returns an adjective for a human mob
/datum/mind/proc/get_mob_adjective(mob/living/target)
	var/list/possible_descriptions = list()

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target

		// if hands are bloody
		if(!human_target.gloves && human_target.blood_in_hands && (human_target.num_hands > 0))
			possible_descriptions += "bloody"
		else // or if clothes are covered in blood
			// pretty sure this code doesn't work and needs to be double checked
			for(var/obj/bloody_item in human_target.get_all_slots() | human_target.held_items)
				if(!QDELETED(bloody_item) && HAS_BLOOD_DNA(bloody_item))
					possible_descriptions += "bloody"
					break

		// if the person is a masked "Unknown"
		if(human_target.get_visible_name() == "Unknown")
			possible_descriptions += pick("unknown", "anonymous", "disguised", "masked", "clandestine", "covert", "suspicious")

		// if there is a mismatch between their ID and face ie. "John Doe (as George Melons)"
		var/face_name = human_target.get_face_name("")
		var/id_name = human_target.get_id_name("")
		if(face_name && id_name && (id_name != face_name))
			possible_descriptions += pick("imitated", "fake", "deceitful", "deceptive")

		if(human_target.handcuffed)
			possible_descriptions += pick("handcuffed", "restrained", "shackled")
		if(human_target.legcuffed)
			possible_descriptions += pick("legcuffed", "restrained", "shackled")

		if(!human_target.has_light_nearby())
			possible_descriptions += pick("shadowy", "dark", "lurking", "sneaking", "creeping")

		if(!isturf(human_target.loc) || human_target.is_holding(/obj/item/kirbyplants))
			possible_descriptions += pick("hidden", "concealed")

		if(human_target.is_bleeding())
			possible_descriptions += "bleeding"
		if(human_target.on_fire())
			possible_descriptions += "burning"

		// status effects
		if(human_target.IsSleeping())
			possible_descriptions += "sleeping"
		if(human_target.IsStun())
			possible_descriptions += pick("stunned", "exhausted")
		if(human_target.IsImmobilized())
			possible_descriptions += "immoblized"
		if(human_target.IsParalyzed())
			possible_descriptions += "paralyzed"
		if(human_target.IsFrozen())
			possible_descriptions += "frozen"

		if(human_target.has_status_effect(/datum/status_effect/inebriated/tipsy))
			possible_descriptions += "tipsy"
		if(human_target.has_status_effect(/datum/status_effect/inebriated/drunk))
			possible_descriptions += "drunk"
		if(human_target.has_status_effect(/datum/status_effect/eldritch))
			possible_descriptions += "marked"
		if(human_target.has_status_effect(/datum/status_effect/trance))
			possible_descriptions += pick("hypnotized", "mesmerized")
		if(human_target.has_status_effect(/datum/status_effect/convulsing))
			possible_descriptions += "convulsing"
		if(human_target.has_status_effect(/datum/status_effect/stagger))
			possible_descriptions += "staggering"
		if(human_target.has_status_effect(/datum/status_effect/dizziness))
			possible_descriptions += "dizzy"
		if(human_target.has_status_effect(/datum/status_effect/jitter))
			possible_descriptions += "jittery"
		if(human_target.has_status_effect(/datum/status_effect/confusion))
			possible_descriptions += "confused"
		if(human_target.has_status_effect(/datum/status_effect/drugginess))
			possible_descriptions += "stoned"
		if(human_target.has_status_effect(/datum/status_effect/limp))
			possible_descriptions += "limping"

		// these need to be tested properly
		if(human_target.has_status_effect(/datum/status_effect/wound/blunt))
			possible_descriptions += "bruised"
		if(human_target.has_status_effect(/datum/status_effect/wound/slash))
			possible_descriptions += "slashed"
		if(human_target.has_status_effect(/datum/status_effect/wound/pierce))
			possible_descriptions += "stabbed"
		if(human_target.has_status_effect(/datum/status_effect/wound/burn))
			possible_descriptions += "burned"

		if(human_target.has_status_effect(/datum/status_effect/grouped/heldup))
			possible_descriptions += "captive"
		if(human_target.has_status_effect(/datum/status_effect/holdup))
			possible_descriptions += "threatening"
		if(human_target.has_status_effect(/datum/status_effect/grouped/surrender))
			possible_descriptions += "surrendering"

	/// location related descriptions
	var/list/location_descriptions = list()
	var/area/location = get_area(human_target)

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

		// power is pretty simple to check (Hey double check what happens if we short or destroy the areas APC)
		location_descriptions += location.powered(AREA_USAGE_EQUIP) ? "powered" : "unpowered"

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
				location_descriptions += "dark"
			else if(lit_area_percent <= 0.60) // 20%-60% lighting
				location_descriptions += "dim"
			else // 60%-100% lighting
				location_descriptions += "lit"
				if(blinking)
					location_descriptions += pick("blinking", "flickering", "flashing")
				else if(night_lighting)
					location_descriptions += "tinted"
		else // APC light switch is off
			location_descriptions += "dark"

		if(is_area_breached)
			location_descriptions += "breached"
		else if(location.powered(AREA_USAGE_ENVIRON) && location.air_alarm)
			if(location.air_alarm.mode == AALARM_MODE_SCRUBBING)
				location_descriptions += "ventilated"
			else if(location.air_alarm.mode == AALARM_MODE_SCRUBBING || location.air_alarm.mode == AALARM_MODE_PANIC)
				location_descriptions += "siphoned"
			else if(location.air_alarm.mode == AALARM_MODE_REFILL || location.air_alarm.mode == AALARM_MODE_FLOOD)
				location_descriptions += "inflating"
		// if APC environment switch off, no air alarm present, air alarm turned off, or air alarm shorted by cut wire
		else if(!location.powered(AREA_USAGE_ENVIRON) || !location.air_alarm || location.air_alarm.mode == AALARM_MODE_OFF || location.air_alarm.shorted)
			location_descriptions += "unventilated"

	var/turf/current_turf = get_turf(human_target)

	if(current_turf.has_gravity())
		location_descriptions += "zero-gravity"
	if(current_turf.)


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

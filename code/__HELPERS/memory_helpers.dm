
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
	TRAIT_DWARF = list("dwarf", "small", "tiny"),
	TRAIT_GIANT = list("giant", "huge", "large"),
	TRAIT_FAT = list("fat", "chubby", "obese"),
	TRAIT_HOLY = list("divine", "holy", "devout"),
	TRAIT_CULT_HALO = list("sinster", "unholy", "corrupted"),
	TRAIT_HUSKED = list("husked"),
	TRAIT_IRRADIATED = list("glowing", "radioactive"),
	TRAIT_HULK = list("hulking"),
	TRAIT_NEARSIGHT = list("nearsighted"),
	TRAIT_MUTE = list("silent", "mute", "quiet"),
	TRAIT_BLIND = list("blind"),
	TRAIT_DEAF = list("deaf"),
	TRAIT_CLUMSY = list("clumsy"),
	TRAIT_ILLITERATE = list("illiterate"),
	TRAIT_DISFIGURED = list("disfigured"),
	TRAIT_SILENT_FOOTSTEPS = list("stealthy"),
	TRAIT_NO_SOUL = list("soulless"),
	TRAIT_BLUSHING = list("blushing"),
	TRAIT_MOVE_FLYING = list("flying"),
	TRAIT_MOVE_FLOATING = list("floating", "drifting"),
	TRAIT_FLOORED = list("crawling", "resting", "fallen"),
	TRAIT_BLOODSHOT_EYES = list("drugged"),
	TRAIT_HARDLY_WOUNDED = list("tough"),
	TRAIT_FEARLESS = list("fearless"),
	TRAIT_KNOCKEDOUT = list("unconcious"),
	TRAIT_CRITICAL_CONDITION = list("dying"),
	TRAIT_PACIFISM = list("gentle", "harmless", "innocent"),
	TRAIT_DEPRESSION = list("depressed", "sad", "moody"),
	TRAIT_JOLLY = list("happy", "smiling", "cheerful"),
	TRAIT_HEAVY_SLEEPER = list("sleepy"),
	TRAIT_SPIRITUAL = list("spiritual"),
	TRAIT_VORACIOUS = list("voracious"),
	TRAIT_FREERUNNING = list("athletic"),
	TRAIT_SKITTISH = list("scared"),
	TRAIT_FRIENDLY = list("friendly"),
	TRAIT_SNOB = list("rude"),
	TRAIT_BALD = list("bald"),
	TRAIT_EXTROVERT = list("extrovert"),
	TRAIT_INTROVERT = list("introvert"),
	TRAIT_ANXIOUS = list("anxious"),
	TRAIT_EMPATH = list("empathetic"),
	TRAIT_GRABWEAKNESS = list("feeble"),
	TRAIT_CLOWN_ENJOYER = list("goofy", "silly"),
	TRAIT_MIME_FAN = list("serious", "stern"),
	TRAIT_LIGHT_STEP = list("careful"),
	TRAIT_SELF_AWARE = list("observant"),
	TRAIT_TAGGER = list("delinquent"),
	TRAIT_BADTOUCH = list("evasive"),
	TRAIT_EASILY_WOUNDED = list("fragile"),
	TRAIT_INSANITY = list("insane"),
	TRAIT_UNSTABLE = list("erratic"),
	TRAIT_PHOTOGRAPHER = list("photogenic"),
	//berserk is the trait source? BERSERK_TRAIT = list("harmful", "dangerious", "violent"),
	// these trait doesn't exist yet, plz don't forget to add
	//TRAIT_APATHETIC = list("apathetic"
	//TRAIT_HYPERSENSITIVE = list("bipolar"
	//TRAIT_BLOOD_DEFICIENCY = list("pale"
	//TRAIT_BAD_BACK = list("hunched"
	//TRAIT_FAMILY_HEIRLOOM = list("possessive"
	//TRAIT_FOREIGNER = list("exotic"
	//TRAIT_AFRAID = list("terrified", "panicking", "trembling"
))

///returns an adjective for a human mob
/datum/mind/proc/get_mob_adjective(mob/living/target)
	var/list/possible_descriptions = list()
	
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target

		if(human_target.stat == DEAD)
			possible_descriptions += pick("dead", "deceased", "lifeless", "slain")
			
			var/obj/item/bodypart/head/head = human_target.get_bodypart(BODY_ZONE_HEAD)
			if(!head)
				possible_descriptions += pick("headless", "decapitated", "beheaded")
			
			if(human_target.suiciding)
				possible_descriptions += "suicidal"

		if(HAS_TRAIT(human_target, TRAIT_PARALYSIS_L_LEG) && HAS_TRAIT(human_target, TRAIT_PARALYSIS_R_LEG))
			possible_descriptions += pick("crippled", "paraplegic")
		
		if(human_target.failed_last_breath)
			possible_descriptions += pick("suffocating", "gasping", "choking")
		
		switch(human_target.nutrition)
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				possible_descriptions += pick("hungry", "malnourished")
			if(0 to NUTRITION_LEVEL_STARVING)
				possible_descriptions += pick("starving", "drooling")
		
		// if hands are bloody
		if(!human_target.gloves && human_target.blood_in_hands && (human_target.num_hands > 0))
			possible_descriptions += "bloody"
		else // or if clothes are covered in blood
			// pretty sure this code doesn't work and needs to be double checked
			for(var/obj/bloody_item in human_target.get_all_slots() | human_target.held_items)
				if(!QDELETED(bloody_item) && HAS_BLOOD_DNA(bloody_item))
					possible_descriptions += "bloody"
					break

		// is our mob naked?
		if(isnull(human_target.wear_suit) && isnull(human_target.w_uniform))
			possible_descriptions += pick("naked", "nude", "undressed")
			
		if(human_target.handcuffed)
			possible_descriptions += pick("handcuffed", "restrained", "shackled")
		if(human_target.legcuffed)
			possible_descriptions += pick("legcuffed", "restrained", "shackled")

		if(human_target.buckled)
			possible_descriptions += "sitting"

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
			possible_descriptions += "stunned"
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
			possible_descriptions += "hypnotized"
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

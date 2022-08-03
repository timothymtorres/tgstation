
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
	TRAIT_NAIVE = list("naive"),
	TRAIT_BLUSHING = list("blushing"),
	TRAIT_MOVE_FLYING = list("flying"),
	TRAIT_MOVE_FLOATING = list("floating", "drifting"),
	TRAIT_FLOORED = list("crawling", "resting", "fallen"),
	TRAIT_BLOODSHOT_EYES = list("drugged", "restless", "shaky"),
	TRAIT_HARDLY_WOUNDED = list("tough"),
	TRAIT_FEARLESS = list("fearless"),
	TRAIT_KNOCKEDOUT = list("unconcious"),
	TRAIT_CRITICAL_CONDITION = list("dying"),
	TRAIT_PERMANENTLY_ONFIRE = list("melting"), // for people in lava
	TRAIT_HEADLESS = list("headless", "decapitated", "beheaded"),
	TRAIT_SMOKING = list("smoking"),
	TRAIT_DISEASED = list("sick", "infected", "diseased"),
	TRAIT_SUICIDAL = list("suicidal"),
	TRAIT_SUFFOCATING = list("suffocating", "gasping", "choking"),
	TRAIT_NAKED = list("naked", "nude", "undressed"),
	TRAIT_BUCKLED = list("buckled", "sitting"), // at some point make traits for riding vehicles (scooters, borgs, skateboard, etc.)
	TRAIT_TATTOOED = list("tattooed"),
	TRAIT_SCARRED = list("scarred", "grotesque"),
	// quirks
	TRAIT_PACIFISM = list("gentle", "harmless", "innocent"),
	TRAIT_DEPRESSION = list("depressed", "sad", "moody"),
	TRAIT_JOLLY = list("happy", "smiling", "cheerful"),
	TRAIT_HEAVY_SLEEPER = list("sleepy", "tired"),
	TRAIT_SPIRITUAL = list("spiritual"),
	TRAIT_VORACIOUS = list("voracious"),
	TRAIT_FREERUNNING = list("athletic", "nimble"),
	TRAIT_SKITTISH = list("skittish", "frisky", "fidgetey", "panicky", "jumpy"),
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
/// Emote traits (for any mob) ///
	TRAIT_EMOTE_FLIP = list("flipping"),
	TRAIT_EMOTE_SPIN = list("spinning"),
/// Emote traits (for living mobs) ///
	TRAIT_EMOTE_BLUSH = list("blushing"),
	TRAIT_EMOTE_BOW = list("bowing"),
	TRAIT_EMOTE_BURP = list("burping"),
	TRAIT_EMOTE_CHOKE = list("choking"),
	//TRAIT_EMOTE_CROSS = list(""), crossed hands?
	TRAIT_EMOTE_CHUCKLE = list("chuckling"),
	TRAIT_EMOTE_COLLAPSE = list("collapsing"),
	TRAIT_EMOTE_COUGH = list("coughing"),
	TRAIT_EMOTE_DANCE = list("dancing"),
	TRAIT_EMOTE_DEATHGASP = list("fainting"), // same as fainting
	TRAIT_EMOTE_DROOL = list("drooling"),
	TRAIT_EMOTE_FAINT = list("fainting"),
	TRAIT_EMOTE_FLAP = list("flapping"),
	TRAIT_EMOTE_AFLAP = list("flapping"), // same as flapping
	TRAIT_EMOTE_FROWN = list("frowning"),
	TRAIT_EMOTE_GAG = list("gagging"),
	TRAIT_EMOTE_GASP = list("gasping"),
	TRAIT_EMOTE_GIGGLE = list("giggling"),
	TRAIT_EMOTE_GLARE = list("glaring"),
	TRAIT_EMOTE_GRIN = list("grinning"),
	TRAIT_EMOTE_GROAN = list("groaning"),
	TRAIT_EMOTE_GRIMACE = list("grimacing"),
	TRAIT_EMOTE_JUMP = list("jumping"),
	TRAIT_EMOTE_KISS = list("kissing"),
	TRAIT_EMOTE_LAUGH = list("laughing"),
	TRAIT_EMOTE_LOOK = list("looking"),
	TRAIT_EMOTE_NOD = list("nodding"),
	TRAIT_EMOTE_POINT = list("pointing"),
	TRAIT_EMOTE_POUT = list("pouting"),
	TRAIT_EMOTE_SCREAM = list("screaming"),
	TRAIT_EMOTE_SCOWL = list("scowling"),
	TRAIT_EMOTE_SHAKE = list("shaking"),
	TRAIT_EMOTE_SHIVER = list("shivering"),
	TRAIT_EMOTE_SIGH = list("sighing"),
	TRAIT_EMOTE_SIT = list("sitting"),
	TRAIT_EMOTE_SMILE = list("smiling"),
	TRAIT_EMOTE_SNEEZE = list("sneezing"),
	TRAIT_EMOTE_SMUG = list("smugging"),
	TRAIT_EMOTE_SNIFF = list("sniffing"),
	TRAIT_EMOTE_SNORE = list("snoring"),
	TRAIT_EMOTE_STARE = list("staring"),
	TRAIT_EMOTE_STRECH = list("streching"),
	TRAIT_EMOTE_SULK = list("sulking"),
	TRAIT_EMOTE_SURRENDER = list("surrendering"),
	TRAIT_EMOTE_SWAY = list("swaying"),
	TRAIT_EMOTE_SWEAT = list("sweating"),
	TRAIT_EMOTE_TILT = list("tilting"),
	TRAIT_EMOTE_TREMBLE = list("trembling"),
	TRAIT_EMOTE_TWITCH = list("twitching"),
	TRAIT_EMOTE_TWITCH_S = list("twitching"),
	TRAIT_EMOTE_WAVE = list("waving"),
	TRAIT_EMOTE_WHIMPER = list("whimpering"),
	TRAIT_EMOTE_WSMILE = list("smiling"), // same as smile
	TRAIT_EMOTE_YAWN = list("yawning"),
	TRAIT_EMOTE_GURGLE = list("gurgling"),
	TRAIT_EMOTE_BEEP = list("beeping"),
	TRAIT_EMOTE_INHALE = list("inhaling"),
	TRAIT_EMOTE_EXHALE = list("exhaling"),
	TRAIT_EMOTE_SWEAR = list("swearing"),
/// Emote traits (for brain/MMI) ///
	TRAIT_EMOTE_ALARM = list("alarmed"),
	TRAIT_EMOTE_ALERT = list("alerted"),
	TRAIT_EMOTE_FLASH = list("flashing"),
	TRAIT_EMOTE_NOTICE = list("noticing"),
	TRAIT_EMOTE_WHISTLE = list("whistling"),
/// Emote traits (for silicons) ///
	TRAIT_EMOTE_BOOP = list("booping"),
	TRAIT_EMOTE_BUZZ = list("buzzing"),
	TRAIT_EMOTE_BUZZ2 = list("buzzing"), // same as buzzing
	TRAIT_EMOTE_CHIME = list("chiming"),
	TRAIT_EMOTE_HONK = list("honking"),
	TRAIT_EMOTE_PING = list("pinging"),
	TRAIT_EMOTE_SAD = list("sad"),
	TRAIT_EMOTE_WARN = list("warning"),
	//TRAIT_EMOTE_SLOWCLAP = list(""), // should not be clapping since borgs can't clap
/// Emote traits (for carbon mobs) ///
	//TRAIT_EMOTE_AIRGUITAR = list("airguitar"),
	TRAIT_EMOTE_BLINK = list("blinking"),
	TRAIT_EMOTE_BLINK_R = list("blinking"), // same as blinking
	TRAIT_EMOTE_CLAP = list("clapping"),
	//TRAIT_EMOTE_CRACK = list(""),
	TRAIT_EMOTE_CIRCLE = list("circling"),
	TRAIT_EMOTE_MOAN = list("moaning"),
	TRAIT_EMOTE_NOOGIE = list("nooged"),
	TRAIT_EMOTE_ROLL = list("rolling"),
	TRAIT_EMOTE_SCRATCH = list("scratching"),
	TRAIT_EMOTE_SIGN = list("signing"),
	TRAIT_EMOTE_SIGNAL = list("signaling"),
	TRAIT_EMOTE_SLAP = list("slapping"),
	//TRAIT_EMOTE_TAIL = list(""),
	TRAIT_EMOTE_WINK = list("winking"),
/// Emote traits (for alien mobs) ///
	TRAIT_EMOTE_GNARL = list("gnarling"),
	TRAIT_EMOTE_HISS = list("hissing"),
	TRAIT_EMOTE_ROAR = list("roaring"),
/// Emote traits (for human mobs) ///
	TRAIT_EMOTE_CRY = list("crying"),
	TRAIT_EMOTE_DAB = list("dabing"),
	TRAIT_EMOTE_EYEBROW = list("suspicious"),
	TRAIT_EMOTE_GRUMBLE = list("grumbling"),
	TRAIT_EMOTE_HANDSHAKE = list("greeting"),
	TRAIT_EMOTE_HUG = list("hugging"),
	TRAIT_EMOTE_MUMBLE = list("mumbling"),
	TRAIT_EMOTE_SCREAM = list("screaming"),
	TRAIT_EMOTE_SCREECH = list("screeching"),
	TRAIT_EMOTE_PALE = list("pale"),
	// TRAIT_EMOTE_RAISE = list(""),
	TRAIT_EMOTE_SALUTE = list("saluting"),
	TRAIT_EMOTE_SHRUG = list("shrugging"),
	TRAIT_EMOTE_WAG = list("wagging"),
	TRAIT_EMOTE_WING = list("flapping"), // same as flapping
/// Emote traits (for monkey mobs) ///
	TRAIT_EMOTE_ROLL = list("rolling"),
	TRAIT_EMOTE_SCRATCH = list("scratching"),
))

GLOBAL_LIST_INIT(mob_status_adjectives, list(
	/datum/status_effect/incapacitating/immobilized = list("immoblized"),
	/datum/status_effect/incapacitating/stun = list("stunned", "exhausted"),
	/datum/status_effect/incapacitating/paralyzed = list("paralyzed"),
	/datum/status_effect/incapacitating/incapacitated = list("incapacitated"),
	/datum/status_effect/incapacitating/unconscious = list("unconscious"),
	/datum/status_effect/incapacitating/sleeping = list("sleeping", "snoring"),
	/datum/status_effect/grouped/stasis = list("comatose"),
	/datum/status_effect/spasms = list("spasming"),
	/datum/status_effect/dna_melt = list("mutating"),
	/datum/status_effect/amok = list("violent", "deadly", "rabid"),
	/datum/status_effect/mayhem = list("murderous", "enranged", "wrathful"),
	/datum/status_effect/blooddrunk = list("invulnerable", "invincible"),
	/datum/status_effect/fleshmend = list("regenerating"),
	/datum/status_effect/regenerative_core = list("rejuvenating"),
	/datum/status_effect/marshal = list("regenerating", "rejuvenating", "painless"),
	/datum/status_effect/exercised = list("robust", "vigorous", "healthy"),
	/datum/status_effect/crucible_soul = list("incorporeal", "ethereal", "ghostly"),
	/datum/status_effect/ghoul = list("ghoulish", "ghastly", "fiendish"),
	/datum/status_effect/freezing_blast = list("chilled", "icy", "frozen"),
	/datum/status_effect/freon = list("chilled", "icy", "frozen"),
	/datum/status_effect/discoordinated = list("discoordinated"),
	/datum/status_effect/woozy = list("woozy"),
	/datum/status_effect/in_love = list("infatuated"),
	/datum/status_effect/grouped/heldup = list("coerced", "captive", "detained"),
	/datum/status_effect/holdup = list("threatening", "abducting", "subjugating"),
	/datum/status_effect/grouped/surrender = list("surrendering", "subdued"),
	/datum/status_effect/determined = list("determined", "persistent"),
	/datum/status_effect/stacking/saw_bleed = list("mutilated"),
	/datum/status_effect/necropolis_curse = list("cursed"),
	/datum/status_effect/speech/stutter = list("stuttering"),
	/datum/status_effect/speech/slurring = list("slurring"),
	/datum/status_effect/wish_granters_gift = list("reincarnated"),
	/datum/status_effect/good_music = list("soothed"),
	/datum/status_effect/stoned = list("stoned"),
	/datum/status_effect/inebriated/tipsy = list("tipsy"),
	/datum/status_effect/inebriated/drunk = list("drunk", "hammered"),
	/datum/status_effect/eldritch = list("marked"),
	/datum/status_effect/trance = list("hypnotized", "mesmerized"),
	/datum/status_effect/convulsing = list("convulsing"),
	/datum/status_effect/stagger = list("staggering"),
	/datum/status_effect/dizziness = list("dizzy"),
	/datum/status_effect/jitter = list("jittery"),
	/datum/status_effect/confusion = list("confused"),
	/datum/status_effect/drugginess = list("stoned"),
	/datum/status_effect/limp = list("limping"),
	// these need to be tested properly
	/datum/status_effect/wound/blunt = list("bruised"),
	/datum/status_effect/wound/slash = list("slashed"),
	/datum/status_effect/wound/pierce = list("stabbed"),
	/datum/status_effect/wound/burn = list("burned"),
))

/datum/mind/proc/create_memory(mob/living/target)
	var/area/location = get_area(human_target)
	var/turf/current_turf = get_turf(human_target)

	var/list/mob_adjectives = get_mob_adjectives(mob/living/target)
	var/list/location_adjectives = get_location_adjectives(turf/current_turf)

///returns an adjective for a human mob
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

///returns a list of adjectives for the location the event takes place
/datum/mind/proc/get_location_adjectives(turf/current_turf)
	var/list/location_descriptions = list()
	var/area/location = get_area(current_turf)

	// area is too big to be considered a room
	if(location.areasize > AREASIZE_TOO_BIG_FOR_ROOM)
		return

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

		if(!current_turf.has_gravity())
			location_descriptions += "zero-gravity"

		switch(location.beauty)
			if(-INFINITY to BEAUTY_LEVEL_HORRID)
				location_descriptions += pick("nasty", "filthy", "trashy", "littered")
			if(BEAUTY_LEVEL_HORRID to BEAUTY_LEVEL_BAD)
				location_descriptions += pick("untidy", "messy", "unkempt")
			if(BEAUTY_LEVEL_BAD to BEAUTY_LEVEL_DECENT)
				// plain jane room gets no description
			if(BEAUTY_LEVEL_DECENT to BEAUTY_LEVEL_GOOD)
				location_descriptions += pick("organized", "furnished", "tidy")
			if(BEAUTY_LEVEL_GOOD to BEAUTY_LEVEL_GREAT)
				location_descriptions += pick("spotless", "clean", "sanitary")
			if(BEAUTY_LEVEL_GREAT to INFINITY)
				location_descriptions += pick("luxurious", "immaculate", "elegant", "polished")

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
				location_descriptions += pick("polluted", "contaminated", "noxious", "nauseous")
			if(!(env_gases[/datum/gas/oxygen] && env_gases[/datum/gas/oxygen][MOLES] >= 16))
				location_descriptions += "asphyxiating"

			var/env_temperature = enviornment.temperature
			if(env_temperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
				location_descriptions += pick("frigid", "frozen", "freezing")
			else if(env_temperature >= BODYTEMP_HEAT_DAMAGE_LIMIT)
				location_descriptions += pick("searing", "scorching", "burning")

			var/env_pressure = environment.return_pressure()
			if(env_pressure <= HAZARD_LOW_PRESSURE)
				location_descriptions += pick("depressurized", "decompressed")
			else if (env_pressure >= HAZARD_HIGH_PRESSURE)
				location_descriptions += pick("overpressurized", "compressed")

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

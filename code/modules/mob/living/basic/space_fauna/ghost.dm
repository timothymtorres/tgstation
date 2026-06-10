/mob/living/basic/ghost
	name = "ghost"
	desc = "A soul of the dead, spooky."
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "ghost"
	icon_living = "ghost"
	mob_biotypes = MOB_SPIRIT | MOB_UNDEAD
	speak_emote = list("wails", "weeps")
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	combat_mode = TRUE
	basic_mob_flags = DEL_ON_DEATH
	status_flags = CANPUSH
	maxHealth = 40
	health = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "grips"
	attack_verb_simple = "grip"
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	attack_sound = 'sound/effects/hallucinations/growl1.ogg'
	death_message = "wails, disintegrating into a pile of ectoplasm!"
	gold_core_spawnable = NO_SPAWN //too spooky for science
	light_system = OVERLAY_LIGHT
	light_range = 2.5 // same glowing as visible player ghosts
	light_power = 0.6
	ai_controller = /datum/ai_controller/basic_controller/ghost
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)

	///What hairstyle will this ghost have
	var/ghost_hairstyle
	///What color will this ghost's hair be
	var/ghost_hair_color
	///The resulting hair to be displayed on the ghost
	var/mutable_appearance/ghost_hair
	///What facial hairstyle will this ghost have
	var/ghost_facial_hairstyle
	///What color will this ghost's facial hair be
	var/ghost_facial_hair_color
	///The resulting facial hair to be displayed on the ghost
	var/mutable_appearance/ghost_facial_hair
	///Will this ghost spawn with a randomly generated name and hair?
	var/random_identity = TRUE

/mob/living/basic/ghost/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, /obj/item/ectoplasm)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ai_retaliate)

	give_identity()

/**
 * Generates hair, facial hair, and a random name for ghosts if one is needed.
 *
 * Handles generating the mutable_appearance objects for a ghost's hair/facial hair,
 * as well as assigning a random name if needed. If random_identity is false, it will only create and display
 * the hair as defined by ghost_hairstyle/ghost_facial_hairstyle variables, without changing the name.
 * If random_identity is true, hair/facial/name will all be randomly generated and displayed.
 * When creating a ghost with a custom identity (for away missions, ruins, etc.) be sure random_identity is false.
 */

/mob/living/basic/ghost/proc/give_identity()
	if(random_identity)
		ghost_hairstyle = random_hairstyle() //This only gives us the hairstyle name, not the icon_state (which we need).
		ghost_hair_color = random_hair_color()

		if(prob(50)) //Only a chance at also getting facial hair
			ghost_facial_hairstyle = random_facial_hairstyle()
			ghost_facial_hair_color = ghost_hair_color

	if(!isnull(ghost_hairstyle) && ghost_hairstyle != "Bald") //Bald hairstyle and the Shaved facial hairstyle lack an associated sprite and will not properly generate hair, and just cause runtimes.
		var/datum/sprite_accessory/hair/hair_style = SSaccessories.hairstyles_list[ghost_hairstyle] //We use the hairstyle name to get the sprite accessory, which we copy the icon_state from.
		ghost_hair = mutable_appearance('icons/mob/human/human_face.dmi', "[hair_style.icon_state]", -HAIR_LAYER)
		ghost_hair.alpha = 200
		ghost_hair.color = ghost_hair_color
		ghost_hair.pixel_z = hair_style.y_offset
		add_overlay(ghost_hair)

	if(!isnull(ghost_facial_hairstyle) && ghost_facial_hairstyle != "Shaved")
		var/datum/sprite_accessory/facial_hair_style = SSaccessories.facial_hairstyles_list[ghost_facial_hairstyle]
		ghost_facial_hair = mutable_appearance('icons/mob/human/human_face.dmi', "[facial_hair_style.icon_state]", -HAIR_LAYER)
		ghost_facial_hair.alpha = 200
		ghost_facial_hair.color = ghost_facial_hair_color
		add_overlay(ghost_facial_hair)

	if(random_identity)
		switch(rand(0,1))
			if(0)
				name = "ghost of [pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
			if(1)
				name = "ghost of [pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"

/datum/ai_controller/basic_controller/ghost
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Weaker variant of ghosts. Meant to be summoned in swarms via the ectoplasmic anomaly and associated ghost portal.
/mob/living/basic/ghost/swarm
	name = "vengeful spirit"
	desc = "Back from the grave, and not happy about it."
	maxHealth = 30
	health = 30
	attack_verb_continuous = "smashes"
	attack_verb_simple = "smash"
	melee_damage_lower = 10
	melee_damage_upper = 10
	death_message = "wails as it is torn back to the realm from which it came!"
	random_identity = FALSE
















/**
 * A bookcase that hides a key inside one of its books.
 *
 * Rather than spawning a fresh blank book (which would be an obvious giveaway), this picks one
 * of the random books already loaded onto the shelf - complete with its persisted player-written
 * title, author, and contents - carves it hollow, and stashes the key inside.
 */
/obj/structure/bookcase/hidden_key
	name = "bookcase"
	icon_state = "random_bookcase"
	load_random_books = TRUE
	books_to_load = 4
	random_category = BOOK_CATEGORY_RANDOM
	/// The key type stashed inside the hollow book.
	var/hidden_key_type = /obj/item/key

/obj/structure/bookcase/hidden_key/after_random_load()
	. = ..()
	var/list/candidate_books = list()
	for(var/obj/item/book/book in contents)
		if(book.carved || book.unique) // can't carve already-carved or special books
			continue
		candidate_books += book

	if(!length(candidate_books))
		return // shelf failed to populate (e.g. no db connection) - no key this time

	var/obj/item/book/hollow = pick(candidate_books)
	hollow.carve_out()
	new hidden_key_type(hollow)

/**
 * Ghost Librarian
 *
 * A mini-boss for the forbidden library ruin. It demands silence: any mob that speaks aloud
 * (without whispering) or emits an audible emote within its hearing range gets shushed and
 * petrified into a statue. Whisper to stay safe.
 */
/mob/living/basic/ghost/librarian
	name = "ghost librarian"
	desc = "The eternal warden of the forbidden library. It demands absolute silence."
	maxHealth = 250
	health = 250
	melee_damage_lower = 20
	melee_damage_upper = 20
	speed = 5
	random_identity = FALSE
	ghost_hairstyle = "Bedhead Hair"
	ghost_hair_color = "#d8d8d8"
	death_message = "lets out a final, mournful shush as it dissolves into ectoplasm..."
	/// How long the petrification lasts.
	var/petrify_duration = 1 MINUTES
	/// Cooldown between petrifications so a single noisy room isn't an instant party wipe.
	COOLDOWN_DECLARE(petrify_cooldown)

/mob/living/basic/ghost/librarian/Initialize(mapload)
	. = ..()
	become_hearing_sensitive(ROUND_START_TRAIT)

/mob/living/basic/ghost/librarian/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	if(speaker == src)
		return
	// Whispering is the one safe way to communicate near the librarian.
	if(message_mods[WHISPER_MODE])
		return
	if(!isliving(speaker))
		return
	punish_noise(speaker)

/mob/living/basic/ghost/librarian/proc/punish_noise(mob/living/offender)
	if(QDELETED(offender) || offender == src)
		return
	if(offender.stat == DEAD)
		return
	// Already a statue? Leave them be.
	if(istype(offender.loc, /obj/structure/statue/petrified))
		return
	if(!COOLDOWN_FINISHED(src, petrify_cooldown))
		return
	COOLDOWN_START(src, petrify_cooldown, 5 SECONDS)

	say("SHHHHHHH!!!")
	playsound(src, 'sound/effects/magic/fleshtostone.ogg', 50, TRUE)
	offender.visible_message(
		span_danger("[src] glares at [offender] and lets out a deafening shush!"),
		span_userdanger("[src] silences you for daring to make noise!"),
	)
	offender.Stun(4 SECONDS)
	offender.petrify(petrify_duration)

/mob/living/basic/ghost/librarian/Initialize(mapload)
	. = ..()
	become_hearing_sensitive(ROUND_START_TRAIT)
	RegisterSignal(SSdcs, COMSIG_GLOB_LIVING_EMOTED, PROC_REF(on_global_emote))

/mob/living/basic/ghost/librarian/proc/on_global_emote(datum/source, mob/living/emoter, key, intentional)
	SIGNAL_HANDLER
	if(emoter == src || !intentional)
		return
	// Only care about audible emotes within earshot.
	if(get_dist(src, emoter) > hearing_range)
		return
	if(!can_see(src, emoter, hearing_range)) // line of sight / in view
		return
	INVOKE_ASYNC(src, PROC_REF(punish_noise), emoter)

/// Base type for forbidden library spawners.
/obj/effect/spawner/random/library
	name = "random library spawner"
	desc = "Spawns something related to a library."
	icon_state = "book"

/// Forbidden library bookcase spawner.
///
/// Draws from GLOB.forbidden_library_bookcases - a pool of ~24 weighted "bookcase slots"
/// mixing themed bookcases, a wish-granter bookcase, a key-hiding bookcase, and bookcase mimics.
/// Scatter several around a forbidden library ruin for randomized loot and danger.
/obj/effect/spawner/random/library/bookcase
	name = "random forbidden bookcase spawner"
	desc = "Spawns a random bookcase. Some of them bite."
	icon_state = "random_bookcase"
	remove_if_cant_spawn = FALSE //don't mutate the shared global loot list

/obj/effect/spawner/random/library/bookcase/Initialize(mapload)
	loot = GLOB.forbidden_library_bookcases
	return ..()

/// Loose book spawner. Mostly ordinary random books, but occasionally a book mimic.
/obj/effect/spawner/random/library/loose_book
	name = "random loose book spawner"
	desc = "Spawns a random book. Some of them bite."
	icon_state = "random_book"
	loot = list(
		/obj/item/book/random = 9,
		/mob/living/basic/mimic/copy/book = 1,
	)

/**
 * A bookcase containing a single, randomized "wish granter" tome - a rare magic book that
 * grants the reader a random magical ability. The specific tome is chosen at runtime from
 * all subtypes of /obj/item/book/granter/action/spell/wishgranter.
 */
/obj/structure/bookcase/wishgranter
	name = "ancient bookcase"
	desc = "An old, dusty bookcase. A faint and unsettling energy seems to emanate from within."
	icon_state = "random_bookcase"
	load_random_books = TRUE
	books_to_load = 3
	random_category = BOOK_CATEGORY_REFERENCE

/obj/structure/bookcase/wishgranter/after_random_load()
	. = ..()
	var/list/possible_books = subtypesof(/obj/item/book/granter/action/spell/wishgranter)
	if(length(possible_books))
		new (pick(possible_books))(src)

/**
 * A bookcase that hides a key inside one of its books.
 *
 * Loads normal books to blend in, then carves out an extra book and stashes a key inside its
 * hollow. Players have to find the right book and crack it open to retrieve the key.
 */
/obj/structure/bookcase/hidden_key
	name = "bookcase"
	icon_state = "random_bookcase"
	load_random_books = TRUE
	books_to_load = 4
	random_category = BOOK_CATEGORY_RANDOM
	/// The key type stashed inside the hollow book.
	var/hidden_key_type = /obj/item/key

/obj/structure/bookcase/hidden_key/after_random_load()
	. = ..()
	var/obj/item/book/hollow = new(src)
	hollow.gen_random_icon_state()
	hollow.carve_out()
	new hidden_key_type(hollow)

// Forbidden library bookcase loot table.
//
// Read by the spawner in code/game/objects/effects/spawners/random/library.dm,
// same pattern as the maintenance loot lists.
//
// Tuned so that out of every ~24 bookcases, roughly 1 is a wish-granter bookcase,
// 1 hides a key, and 4 are hostile bookcase mimics.
GLOBAL_LIST_INIT(forbidden_library_bookcases, list(
	/obj/structure/bookcase/random/fiction = 4,
	/obj/structure/bookcase/random/nonfiction = 4,
	/obj/structure/bookcase/random/reference = 4,
	/obj/structure/bookcase/random/religion = 3,
	/obj/structure/bookcase/random = 3,
	/obj/structure/bookcase/wishgranter = 1,
	/obj/structure/bookcase/hidden_key = 1,
	/mob/living/basic/mimic/copy/bookcase = 4,
))

// ****************************
// FORBIDDEN LIBRARY MIMICS
// ****************************

/**
 * Bookcase mimic.
 *
 * Disguises itself as a fully-stocked bookcase. When triggered, it reveals itself
 * and attacks. Built on top of /mob/living/basic/mimic/copy, generating a throwaway
 * "fake" bookcase in nullspace purely to copy its visuals/stats from.
 */
/mob/living/basic/mimic/copy/bookcase
	name = "bookcase"
	desc = "A great place for storing knowledge."
	health = 150
	maxHealth = 150
	melee_damage_lower = 12
	melee_damage_upper = 18
	mob_size = MOB_SIZE_LARGE
	gold_core_spawnable = HOSTILE_SPAWN
	knockdown_people = TRUE
	/// What we visually pretend to be when nobody's looking
	var/mimic_type = /obj/structure/bookcase

/mob/living/basic/mimic/copy/bookcase/Initialize(mapload, obj/copy, mob/living/creator, destroy_original, no_googlies = TRUE)
	if(isnull(copy))
		var/obj/structure/bookcase/fake = new mimic_type(null)
		fake.anchored = TRUE // looks like a finished, stocked bookcase
		fake.icon_state = "book-[rand(3, 5)]"
		copy = fake
		destroy_original = TRUE
	. = ..(mapload, copy, creator, destroy_original, no_googlies)
	icon_living = icon_state
	// CopyObject() recalculates health/damage off the fake bookcase - restore our intended stats
	maxHealth = initial(maxHealth)
	health = maxHealth
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)

/**
 * Book mimic.
 *
 * Disguises itself as an ordinary book. Smaller and weaker than the bookcase mimic,
 * but just as nasty up close.
 */
/mob/living/basic/mimic/copy/book
	name = "book"
	desc = "Crack it open, inhale the musk of its pages, and learn something new."
	health = 30
	maxHealth = 30
	mob_size = MOB_SIZE_SMALL
	melee_damage_lower = 4
	melee_damage_upper = 8
	gold_core_spawnable = HOSTILE_SPAWN
	/// What we visually pretend to be when nobody's looking
	var/mimic_type = /obj/item/book

/mob/living/basic/mimic/copy/book/Initialize(mapload, obj/copy, mob/living/creator, destroy_original, no_googlies = TRUE)
	if(isnull(copy))
		var/obj/item/book/fake = new mimic_type(null)
		fake.gen_random_icon_state()
		copy = fake
		destroy_original = TRUE
	. = ..(mapload, copy, creator, destroy_original, no_googlies)
	icon_living = icon_state
	// CopyObject() recalculates health/damage off the fake book - restore our intended stats
	maxHealth = initial(maxHealth)
	health = maxHealth
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)

/**
 * A bookcase containing a single, randomized "wish granter" tome - a rare magic book that
 * grants the reader a random magical ability. The specific tome is chosen at runtime from
 * all subtypes of /obj/item/book/granter/action/spell/wishgranter.
 *
 * This one is built off /obj/structure/bookcase/random so it ALSO loads a couple of normal
 * reference books to hide the wishgranter tome amongst, then injects the tome on top.
 */
/obj/structure/bookcase/wishgranter
	name = "ancient bookcase"
	desc = "An old, dusty bookcase. A faint and unsettling energy seems to emanate from within."
	icon_state = "random_bookcase"
	load_random_books = TRUE
	books_to_load = 3
	random_category = BOOK_CATEGORY_REFERENCE

/obj/structure/bookcase/wishgranter/after_random_load()
	. = ..()
	var/list/possible_books = subtypesof(/obj/item/book/granter/action/spell/wishgranter)
	if(length(possible_books))
		new (pick(possible_books))(src)


/**
 * Tomes of forbidden wishes.
 *
 * Rare magic books found in forbidden libraries. Reading one grants the reader a single
 * random magical ability before the book crumbles to dust, spent.
 *
 * To expand the random pool, just add a new concrete subtype below with a granted_action -
 * the wish granter bookcase auto-discovers them via subtypesof().
 */
/obj/item/book/granter/action/spell/wishgranter
	abstract_type = /obj/item/book/granter/action/spell/wishgranter
	name = "tome of forbidden wishes"
	desc = "A heavy tome bound in cracked, dark leather. Runes shift and crawl across its cover, \
		as if the book itself is alive."
	icon_state = "book5"
	uses = 1
	pages_to_mastery = 3
	remarks = list(
		"The pages whisper promises of forbidden power...",
		"You feel the weight of ancient knowledge pressing into your mind...",
		"Something ancient stirs within these pages...",
		"The ink seems to crawl across the page on its own...",
		"You sense this knowledge may come with a price...",
		"A chill runs down your spine as you turn the page...",
	)

/obj/item/book/granter/action/spell/wishgranter/on_reading_finished(mob/living/user)
	. = ..()
	to_chat(user, span_warning("[src] crumbles to dust in your hands, its magic spent!"))
	qdel(src)

/obj/item/book/granter/action/spell/wishgranter/smoke
	name = "tome of choking shadows"
	desc = "This tome smells faintly of sulfur. Its pages describe a means of vanishing into a cloud of smoke."
	icon_state = "booksmoke"
	granted_action = /datum/action/cooldown/spell/smoke
	action_name = "veil of smoke"

/obj/item/book/granter/action/spell/wishgranter/smoke_lesser
	name = "tome of fading mist"
	desc = "This tome is bound with faded string. The pages describe a lesser shrouding magic."
	icon_state = "booksmoke"
	granted_action = /datum/action/cooldown/spell/smoke/lesser
	action_name = "lesser veil of smoke"

/obj/item/book/granter/action/spell/wishgranter/sacred_flame
	name = "tome of the eternal pyre"
	desc = "Heat radiates faintly from this tome's cover, as if a fire burns just beneath the leather."
	icon_state = "booksacredflame"
	granted_action = /datum/action/cooldown/spell/aoe/sacred_flame
	action_name = "sacred flame"

/obj/item/book/granter/action/spell/wishgranter/summon_item
	name = "tome of the outstretched hand"
	desc = "This tome's pages are covered in sketches of objects, each circled and annotated with arcane symbols."
	icon_state = "booksummons"
	granted_action = /datum/action/cooldown/spell/summonitem
	action_name = "instant summons"

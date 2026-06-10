/// Turn pur target to stone, forever
/datum/smite/petrify
	name = "Petrify"

/datum/smite/petrify/effect(client/user, mob/living/target)
	. = ..()

	if(!ishuman(target))
		to_chat(user, span_warning("This must be used on a human subtype."), confidential = TRUE)
		return
	var/mob/living/carbon/human/human_target = target
	human_target.petrify(statue_timer = INFINITY, save_brain = FALSE)

/datum/smite/petrify/divine
	name = "Petrify (Divine)"
	smite_flags = SMITE_DIVINE|SMITE_DELAY|SMITE_STUN

#define LIBRARIAN_HUSH_COOLDOWN 3 SECONDS

/**
 * The Ghost Librarian.
 *
 * A mini-boss spirit that haunts forbidden libraries, enforcing total silence. Anyone who
 * speaks aloud (without whispering) or makes an audible emote within earshot will be
 * loudly shushed and turned to stone on the spot.
 */
/mob/living/basic/ghost/librarian
	name = "ghost librarian"
	desc = "The restless spirit of a librarian, doomed for eternity to enforce the rules of \
		silence. You get the distinct feeling that making a sound here would be a very bad idea."
	icon_state = "ghost"
	icon_living = "ghost"
	random_identity = FALSE
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 18
	speak_emote = list("shushes", "glares disapprovingly")
	attack_verb_continuous = "grips"
	attack_verb_simple = "grip"
	death_message = "wails, its eternal vigil finally over, and crumbles into ectoplasm and dust!"
	ai_controller = /datum/ai_controller/basic_controller/ghost/librarian
	/// Cooldown so the librarian doesn't try to shush every single word of a sentence.
	COOLDOWN_DECLARE(hush_cooldown)

/mob/living/basic/ghost/librarian/Initialize(mapload)
	. = ..()
	// A faint, sickly tint to set it apart from regular ghosts.
	add_atom_colour("#b8c4d6", FIXED_COLOUR_PRIORITY)

/**
 * Called for every audible message (speech or audible emote) made by a nearby mob.
 *
 * If the message wasn't a whisper, the speaker has broken the silence and earns themselves
 * a face full of marble.
 */
/mob/living/basic/ghost/librarian/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return
	if(!isliving(speaker) || speaker == src)
		return
	if(radio_freq) // ignore radio chatter - they're not disturbing the room
		return

	var/mob/living/violator = speaker
	if(violator.stat == DEAD)
		return

	// message_language is null for emotes - if it reached Hear(), it was audible.
	if(!isnull(message_language) && was_whispered(spans, message_mods))
		return

	hush(violator)

/**
 * Returns TRUE if the heard speech was whispered, and should be ignored.
 *
 * NOTE: Whisper detection varies between codebase versions. This checks the most common
 * indicators (a "whisper" flag in message_mods, or an italic span applied to whispered
 * text) - adjust this to match your fork's exact whisper implementation if needed.
 */
/mob/living/basic/ghost/librarian/proc/was_whispered(list/spans, list/message_mods)
	if(!isnull(message_mods) && (message_mods["whisper"] || message_mods[MODE_WHISPER]))
		return TRUE
	if(spans && (SPAN_ITALIC in spans))
		return TRUE
	return FALSE

/// SHHHHHes the violator, then turns them to stone.
/mob/living/basic/ghost/librarian/proc/hush(mob/living/violator)
	if(!COOLDOWN_FINISHED(src, hush_cooldown))
		return
	COOLDOWN_START(src, hush_cooldown, LIBRARIAN_HUSH_COOLDOWN)

	visible_message(span_danger("[src] rounds on [violator] with a furious, ancient glare!"))
	say("SHHHHHHHH!!!")

	if(violator.can_block_magic())
		to_chat(violator, span_warning("You feel an icy chill run through you, but you remain yourself!"))
		return

	to_chat(violator, span_userdanger("[src] fixes you with a withering stare... your blood runs cold, and your skin turns to stone!"))
	playsound(violator, 'sound/effects/magic/fleshtostone.ogg', 50, TRUE)
	violator.Stun(4 SECONDS)
	violator.petrify()

/datum/ai_controller/basic_controller/ghost/librarian
	// Inherits the base ghost's wander/retaliate/melee behavior - the librarian's real
	// threat comes from Hear()-triggered petrification, not its AI movement.

#undef LIBRARIAN_HUSH_COOLDOWN

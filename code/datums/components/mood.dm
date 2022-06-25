#define MINOR_INSANITY_PEN 5
#define MAJOR_INSANITY_PEN 10

/datum/component/mood
	/// The total combined value of all moodlets for the mob
	var/mood
	/// The total combined value of all moodlets excluding hidden moodlets
	/// This is what others can see when they try to examine you, prevents antag checking by noticing traitors are always very happy.
	var/shown_mood
	/// To track what stage of moodies they're on and used to update the mood icon (levels are from 1-9)
	var/mood_level = MOOD_LEVEL_NEUTRAL
	/// Current sanity for the mob (from 0-150)
	var/sanity = SANITY_NEUTRAL
	/// To track what stage of sanity they're on (levels are from 1-6)
	var/sanity_level = SANITY_LEVEL_NEUTRAL
	/// Modifier to allow certain mobs to be more or less affected by moodlets
	/// A modifier of 0.5 means both positive and negative mood effects results in half mood value (50%)
	/// A modifier of 2 means both positive and negative mood effects results in double mood value (200%)
	var/mood_modifier = 1
	/// A list of moodlets that are currently affecting the mob
	var/list/datum/mood_event/mood_events = list()
	/// Is the owner being punished for low mood? If so, how much?
	var/insanity_effect = 0
	/// The mood HUD that changes color and expression based on mood level (can also be clicked on)
	var/atom/movable/screen/mood/screen_obj

/datum/component/mood/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSmood, src)

	RegisterSignal(parent, COMSIG_ADD_MOOD_EVENT, .proc/add_event)
	RegisterSignal(parent, COMSIG_CLEAR_MOOD_EVENT, .proc/clear_event)
	RegisterSignal(parent, COMSIG_ENTER_AREA, .proc/check_area_mood)
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, .proc/on_revive)
	RegisterSignal(parent, COMSIG_MOB_HUD_CREATED, .proc/modify_hud)
	RegisterSignal(parent, COMSIG_JOB_RECEIVED, .proc/register_job_signals)
	RegisterSignal(parent, COMSIG_HERETIC_MASK_ACT, .proc/direct_sanity_drain)
	RegisterSignal(parent, COMSIG_ON_CARBON_SLIP, .proc/on_slip)

	var/mob/living/owner = parent
	owner.become_area_sensitive(MOOD_COMPONENT_TRAIT)
	if(owner.hud_used)
		modify_hud()
		var/datum/hud/hud = owner.hud_used
		hud.show_hud(hud.hud_version)

/datum/component/mood/Destroy()
	STOP_PROCESSING(SSmood, src)
	var/atom/movable/movable_parent = parent
	movable_parent.lose_area_sensitivity(MOOD_COMPONENT_TRAIT)
	unmodify_hud()
	return ..()

/datum/component/mood/proc/register_job_signals(datum/source, job)
	SIGNAL_HANDLER

	if(job in list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_ROBOTICIST, JOB_GENETICIST))
		RegisterSignal(parent, COMSIG_ADD_MOOD_EVENT_RND, .proc/add_event) //Mood events that are only for RnD members

/datum/component/mood/proc/print_mood(mob/user)
	var/msg = "[span_info("*---------*\n<EM>My current mental status:</EM>")]\n"
	msg += span_notice("My current sanity: ") //Long term
	switch(sanity)
		if(SANITY_GREAT to INFINITY)
			msg += "[span_boldnicegreen("My mind feels like a temple!")]\n"
		if(SANITY_NEUTRAL to SANITY_GREAT)
			msg += "[span_nicegreen("I have been feeling great lately!")]\n"
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			msg += "[span_nicegreen("I have felt quite decent lately.")]\n"
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			msg += "[span_warning("I'm feeling a little bit unhinged...")]\n"
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			msg += "[span_warning("I'm freaking out!!")]\n"
		if(SANITY_INSANE to SANITY_CRAZY)
			msg += "[span_boldwarning("AHAHAHAHAHAHAHAHAHAH!!")]\n"

	msg += span_notice("My current mood: ") //Short term
	switch(mood_level)
		if(MOOD_LEVEL_SAD4)
			msg += "[span_boldwarning("I wish I was dead!")]\n"
		if(MOOD_LEVEL_SAD3)
			msg += "[span_boldwarning("I feel terrible...")]\n"
		if(MOOD_LEVEL_SAD2)
			msg += "[span_boldwarning("I feel very upset.")]\n"
		if(MOOD_LEVEL_SAD1)
			msg += "[span_warning("I'm a bit sad.")]\n"
		if(MOOD_LEVEL_NEUTRAL)
			msg += "[span_grey("I'm alright.")]\n"
		if(MOOD_LEVEL_HAPPY1)
			msg += "[span_nicegreen("I feel pretty okay.")]\n"
		if(MOOD_LEVEL_HAPPY2)
			msg += "[span_boldnicegreen("I feel pretty good.")]\n"
		if(MOOD_LEVEL_HAPPY3)
			msg += "[span_boldnicegreen("I feel amazing!")]\n"
		if(MOOD_LEVEL_HAPPY4)
			msg += "[span_boldnicegreen("I love life!")]\n"

	msg += "[span_notice("Moodlets:")]\n"//All moodlets
	if(mood_events.len)
		for(var/datum/mood_event/moodlet in mood_events)
			switch(moodlet.mood_change)
				if(-INFINITY to MOOD_SAD2)
					msg += span_boldwarning(moodlet.description + "\n")
				if(MOOD_SAD2 to MOOD_SAD1)
					msg += span_warning(moodlet.description + "\n")
				if(MOOD_SAD1 to MOOD_HAPPY1)
					msg += span_grey(moodlet.description + "\n")
				if(MOOD_HAPPY1 to MOOD_HAPPY2)
					msg += span_nicegreen(moodlet.description + "\n")
				if(MOOD_HAPPY2 to INFINITY)
					msg += span_boldnicegreen(moodlet.description + "\n")
	else
		msg += "[span_grey("I don't have much of a reaction to anything right now.")]\n"
	to_chat(user, msg)

///Called after moodevent/s have been added/removed.
/datum/component/mood/proc/update_mood()
	mood = 0
	shown_mood = 0
	for(var/datum/mood_event/moodlet in mood_events)
		mood += moodlet.mood_change
		if(!moodlet.hidden)
			shown_mood += moodlet.mood_change
	mood *= mood_modifier
	shown_mood *= mood_modifier

	switch(mood)
		if(-INFINITY to MOOD_SAD4)
			mood_level = MOOD_LEVEL_SAD4
		if(MOOD_SAD4 to MOOD_SAD3)
			mood_level = MOOD_LEVEL_SAD3
		if(MOOD_SAD3 to MOOD_SAD2)
			mood_level = MOOD_LEVEL_SAD2
		if(MOOD_SAD2 to MOOD_SAD1)
			mood_level = MOOD_LEVEL_SAD1
		if(MOOD_SAD1 to MOOD_HAPPY1)
			mood_level = MOOD_LEVEL_NEUTRAL
		if(MOOD_HAPPY1 to MOOD_HAPPY2)
			mood_level = MOOD_LEVEL_HAPPY1
		if(MOOD_HAPPY2 to MOOD_HAPPY3)
			mood_level = MOOD_LEVEL_HAPPY2
		if(MOOD_HAPPY3 to MOOD_HAPPY4)
			mood_level = MOOD_LEVEL_HAPPY3
		if(MOOD_HAPPY4 to INFINITY)
			mood_level = MOOD_LEVEL_HAPPY4
	update_mood_icon()

/datum/component/mood/proc/update_mood_icon()
	var/mob/living/owner = parent
	if(!(owner.client || owner.hud_used))
		return
	screen_obj.cut_overlays()
	screen_obj.color = initial(screen_obj.color)
	//lets see if we have any special icons to show instead of the normal mood levels
	var/list/conflicting_moodies = list()
	var/highest_absolute_mood = 0
	for(var/datum/mood_event/moodlet in mood_events) //adds overlays and sees which special icons need to vie for which one gets the icon_state
		if(!moodlet.special_screen_obj)
			continue
		if(!moodlet.special_screen_replace)
			screen_obj.add_overlay(moodlet.special_screen_obj)
		else
			conflicting_moodies += moodlet
			var/absmood = abs(moodlet.mood_change)
			if(absmood > highest_absolute_mood)
				highest_absolute_mood = absmood

	switch(sanity_level)
		if(SANITY_LEVEL_GREAT)
			screen_obj.color = "#2eeb9a"
		if(SANITY_LEVEL_NEUTRAL)
			screen_obj.color = "#86d656"
		if(SANITY_LEVEL_DISTURBED)
			screen_obj.color = "#4b96c4"
		if(SANITY_LEVEL_UNSTABLE)
			screen_obj.color = "#dfa65b"
		if(SANITY_LEVEL_CRAZY)
			screen_obj.color = "#f38943"
		if(SANITY_LEVEL_INSANE)
			screen_obj.color = "#f15d36"

	if(!conflicting_moodies.len) //no special icons- go to the normal icon states
		screen_obj.icon_state = "mood[mood_level]"
		return

	for(var/datum/mood_event/moodlet in conflicting_moodies)
		if(abs(moodlet.mood_change) == highest_absolute_mood)
			screen_obj.icon_state = "[moodlet.special_screen_obj]"
			break

///Called on SSmood process
/datum/component/mood/process(delta_time)
	var/mob/living/moody_fellow = parent
	if(moody_fellow.stat == DEAD)
		return //updating sanity during death leads to people getting revived and being completely insane for simply being dead for a long time
	switch(mood_level)
		if(MOOD_LEVEL_SAD4)
			setSanity(sanity-0.3*delta_time, SANITY_INSANE)
		if(MOOD_LEVEL_SAD3)
			setSanity(sanity-0.15*delta_time, SANITY_INSANE)
		if(MOOD_LEVEL_SAD2)
			setSanity(sanity-0.1*delta_time, SANITY_CRAZY)
		if(MOOD_LEVEL_SAD1)
			setSanity(sanity-0.05*delta_time, SANITY_UNSTABLE)
		if(MOOD_LEVEL_NEUTRAL)
			setSanity(sanity, SANITY_UNSTABLE) //This makes sure that mood gets increased should you be below the minimum.
		if(MOOD_LEVEL_HAPPY1)
			setSanity(sanity+0.2*delta_time, SANITY_UNSTABLE)
		if(MOOD_LEVEL_HAPPY2)
			setSanity(sanity+0.3*delta_time, SANITY_UNSTABLE)
		if(MOOD_LEVEL_HAPPY3)
			setSanity(sanity+0.4*delta_time, SANITY_NEUTRAL, SANITY_MAXIMUM)
		if(MOOD_LEVEL_HAPPY4)
			setSanity(sanity+0.6*delta_time, SANITY_NEUTRAL, SANITY_MAXIMUM)
	HandleNutrition()

	// 0.416% is 15 successes / 3600 seconds. Calculated with 2 minute
	// mood runtime, so 50% average uptime across the hour.
	if(HAS_TRAIT(parent, TRAIT_DEPRESSION) && DT_PROB(0.416, delta_time))
		add_event(null, "depression_mild", /datum/mood_event/depression_mild)

	if(HAS_TRAIT(parent, TRAIT_JOLLY) && DT_PROB(0.416, delta_time))
		add_event(null, "jolly", /datum/mood_event/jolly)

///Sets sanity to the specified amount and applies effects.
/datum/component/mood/proc/setSanity(amount, minimum=SANITY_INSANE, maximum=SANITY_GREAT, override = FALSE)
	// If we're out of the acceptable minimum-maximum range move back towards it in steps of 0.7
	// If the new amount would move towards the acceptable range faster then use it instead
	if(amount < minimum)
		amount += clamp(minimum - amount, 0, 0.7)
	if((!override && HAS_TRAIT(parent, TRAIT_UNSTABLE)) || amount > maximum)
		amount = min(sanity, amount)
	if(amount == sanity) //Prevents stuff from flicking around.
		return
	sanity = amount
	var/mob/living/master = parent
	SEND_SIGNAL(master, COMSIG_CARBON_SANITY_UPDATE, amount)
	switch(sanity)
		if(SANITY_INSANE to SANITY_CRAZY)
			setInsanityEffect(MAJOR_INSANITY_PEN)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/insane)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/low_sanity)
			sanity_level = SANITY_LEVEL_INSANE
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			setInsanityEffect(MINOR_INSANITY_PEN)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/crazy)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/low_sanity)
			sanity_level = SANITY_LEVEL_CRAZY
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			setInsanityEffect(0)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/disturbed)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/low_sanity)
			sanity_level = SANITY_LEVEL_UNSTABLE
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			master.remove_actionspeed_modifier(ACTIONSPEED_ID_SANITY)
			sanity_level = SANITY_LEVEL_DISTURBED
		if(SANITY_NEUTRAL+1 to SANITY_GREAT+1) //shitty hack but +1 to prevent it from responding to super small differences
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/high_sanity)
			sanity_level = SANITY_LEVEL_NEUTRAL
		if(SANITY_GREAT+1 to INFINITY)
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			master.add_actionspeed_modifier(/datum/actionspeed_modifier/high_sanity)
			sanity_level = SANITY_LEVEL_GREAT
	update_mood_icon()

/datum/component/mood/proc/setInsanityEffect(newval)
	if(newval == insanity_effect)
		return
	var/mob/living/master = parent
	master.crit_threshold = (master.crit_threshold - insanity_effect) + newval
	insanity_effect = newval

/datum/component/mood/proc/add_event(datum/source, datum/mood_event/moodlet, ...)
	SIGNAL_HANDLER

	if(!ispath(moodlet, /datum/mood_event))
		CRASH("[moodlet] is not a valid datum/mood_event path")
		return

	// if event is currently active
	if(mood_events[moodlet])
		if(moodlet.renewal_reset_timer)
			addtimer(CALLBACK(src, .proc/clear_event, null, moodlet), moodlet.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)

		if(moodlet.renewal_retrigger_effect)
			clear_event(null, moodlet)
		else // do not have to readd the event
			return

	var/list/params = args.Copy(4)
	params.Insert(1, parent)

	// should mood_events[moodlet] need to be REF(moodlet)?
	mood_events[moodlet] = new moodlet(arglist(params))
	update_mood()

	if(moodlet.timeout)
		addtimer(CALLBACK(src, .proc/clear_event, null, moodlet), moodlet.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/component/mood/proc/clear_event(datum/source, moodlet)
	SIGNAL_HANDLER

	if(!ispath(moodlet, /datum/mood_event))
		CRASH("[moodlet] is not a valid datum/mood_event path")
		return

	mood_events -= moodlet
	qdel(moodlet)
	update_mood()

/datum/component/mood/proc/remove_temp_moods() //Removes all temp moods
	for(var/datum/mood_event/moodlet in mood_events)
		if(!moodlet || !moodlet.timeout)
			continue
		mood_events -= moodlet
		qdel(moodlet)
	update_mood()

/datum/component/mood/proc/modify_hud(datum/source)
	SIGNAL_HANDLER

	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	screen_obj = new
	screen_obj.color = "#4b96c4"
	hud.infodisplay += screen_obj
	RegisterSignal(hud, COMSIG_PARENT_QDELETING, .proc/unmodify_hud)
	RegisterSignal(screen_obj, COMSIG_CLICK, .proc/hud_click)

/datum/component/mood/proc/unmodify_hud(datum/source)
	SIGNAL_HANDLER

	if(!screen_obj)
		return
	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	if(hud?.infodisplay)
		hud.infodisplay -= screen_obj
	QDEL_NULL(screen_obj)

/datum/component/mood/proc/hud_click(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER

	if(user != parent)
		return
	print_mood(user)

/datum/component/mood/proc/HandleNutrition()
	var/mob/living/L = parent
	if(HAS_TRAIT(L, TRAIT_NOHUNGER))
		return FALSE //no mood events for nutrition
	switch(L.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			if (!HAS_TRAIT(L, TRAIT_VORACIOUS))
				add_event(null, "nutrition", /datum/mood_event/fat)
			else
				add_event(null, "nutrition", /datum/mood_event/wellfed) // round and full
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			add_event(null, "nutrition", /datum/mood_event/wellfed)
		if( NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			add_event(null, "nutrition", /datum/mood_event/fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			clear_event(null, "nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			add_event(null, "nutrition", /datum/mood_event/hungry)
		if(0 to NUTRITION_LEVEL_STARVING)
			add_event(null, "nutrition", /datum/mood_event/starving)

/datum/component/mood/proc/check_area_mood(datum/source, area/A)
	SIGNAL_HANDLER

	update_beauty(A)
	if(A.mood_bonus && (!A.mood_trait || HAS_TRAIT(source, A.mood_trait)))
		add_event(null, /datum/mood_event/area, A.mood_bonus, A.mood_message)
	else
		clear_event(null, /datum/mood_event/area)

/datum/component/mood/proc/update_beauty(area/A)
	if(A.outdoors) //if we're outside, we don't care.
		clear_event(null, "area_beauty")
		return FALSE
	if(HAS_TRAIT(parent, TRAIT_SNOB))
		switch(A.beauty)
			if(-INFINITY to BEAUTY_LEVEL_HORRID)
				add_event(null, "area_beauty", /datum/mood_event/horridroom)
				return
			if(BEAUTY_LEVEL_HORRID to BEAUTY_LEVEL_BAD)
				add_event(null, "area_beauty", /datum/mood_event/badroom)
				return
	switch(A.beauty)
		if(BEAUTY_LEVEL_BAD to BEAUTY_LEVEL_DECENT)
			clear_event(null, "area_beauty")
		if(BEAUTY_LEVEL_DECENT to BEAUTY_LEVEL_GOOD)
			add_event(null, "area_beauty", /datum/mood_event/decentroom)
		if(BEAUTY_LEVEL_GOOD to BEAUTY_LEVEL_GREAT)
			add_event(null, "area_beauty", /datum/mood_event/goodroom)
		if(BEAUTY_LEVEL_GREAT to INFINITY)
			add_event(null, "area_beauty", /datum/mood_event/greatroom)

///Called when parent is ahealed.
/datum/component/mood/proc/on_revive(datum/source, full_heal)
	SIGNAL_HANDLER

	if(!full_heal)
		return
	remove_temp_moods()
	setSanity(initial(sanity), override = TRUE)


///Causes direct drain of someone's sanity, call it with a numerical value corresponding how badly you want to hurt their sanity
/datum/component/mood/proc/direct_sanity_drain(datum/source, amount)
	SIGNAL_HANDLER
	setSanity(sanity + amount, override = TRUE)

///Called when parent slips.
/datum/component/mood/proc/on_slip(datum/source)
	SIGNAL_HANDLER

	add_event(null, "slipped", /datum/mood_event/slipped)

/datum/component/mood/proc/HandleAddictions()
	if(!iscarbon(parent))
		return

	var/mob/living/carbon/affected_carbon = parent

	if(sanity < SANITY_GREAT) ///Sanity is low, stay addicted.
		return

	for(var/addiction_type in affected_carbon.mind.addiction_points)
		var/datum/addiction/addiction_to_remove = SSaddiction.all_addictions[type]
		affected_carbon.mind.remove_addiction_points(type, addiction_to_remove.high_sanity_addiction_loss) //If true was returned, we lost the addiction!

#undef MINOR_INSANITY_PEN
#undef MAJOR_INSANITY_PEN

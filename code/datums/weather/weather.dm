/**
 * Causes weather to occur on a z level in certain area types
 *
 * The effects of weather occur across an entire z-level. For instance, lavaland has periodic ash storms that scorch most unprotected creatures.
 * Weather always occurs on different z levels at different times, regardless of weather type.
 * Can have custom durations, targets, and can automatically protect indoor areas.
 *
 */

/datum/weather
	/// name of weather
	var/name = "space wind"
	/// description of weather
	var/desc = "Heavy gusts of wind blanket the area, periodically knocking down anyone caught in the open."
	/// The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_message = span_warning("The wind begins to pick up.")
	/// How long from the beginning of the telegraph until the weather begins
	var/telegraph_duration = 30 SECONDS
	/// The sound file played to everyone on an affected z-level
	var/telegraph_sound
	/// Volume of the telegraph sound
	var/telegraph_sound_vol
	/// The overlay applied to all tiles on the z-level
	var/telegraph_overlay

	/// Displayed in chat once the weather begins in earnest
	var/weather_message = span_userdanger("The wind begins to blow ferociously!")
	/// How long the weather lasts once it begins
	var/weather_duration = 2 MINUTES
	/// See above - this is the lowest possible duration
	var/weather_duration_lower = 2 MINUTES
	/// See above - this is the highest possible duration
	var/weather_duration_upper = 2.5 MINUTES
	/// The sound played to everyone on an affected z-level when weather is occuring (does not loop)
	var/weather_sound
	/// Area overlay while the weather is occuring
	var/weather_overlay
	/// Color to apply to the area while weather is occuring
	var/weather_color = null
	/// The a list of of looping sounds for the weather
	var/looping_sounds

	/// Displayed once the weather is over
	var/end_message = span_danger("The wind relents its assault.")
	/// How long the "wind-down" graphic will appear before vanishing entirely
	var/end_duration = 30 SECONDS
	/// Sound that plays while weather is ending
	var/end_sound
	/// Volume of the sound that plays while weather is ending
	var/end_sound_vol
	/// Area overlay while weather is ending
	var/end_overlay

	/// Types of area to affect
	var/area_type = /area/space
	/// Areas to be affected by the weather, calculated when the weather begins
	var/list/impacted_areas = list()
	/// Areas affected by weather have their blend modes changed
	var/list/impacted_areas_blend_modes = list()
	/// Areas that are protected and excluded from the affected areas.
	var/list/protected_areas = list()
	/// The list of z-levels that this weather is actively affecting
	var/impacted_z_levels

	/// Since it's above everything else, this is the layer used by default.
	var/overlay_layer = AREA_LAYER
	/// Plane for the overlay
	var/overlay_plane = WEATHER_PLANE
	/// Used by mobs (or movables containing mobs, such as enviro bags) to prevent them from being affected by the weather.
	var/immunity_type
	/// If this bit of weather should also draw an overlay that's uneffected by lighting onto the area
	/// Taken from weather_glow.dmi
	var/use_glow = TRUE
	/// List of all overlays to apply to our turfs
	var/list/overlay_cache

	/// The stage of the weather, from 1-4
	var/stage = END_STAGE

	/// Weight amongst other eligible weather. If zero, will never happen randomly.
	var/probability = 0
	/// The z-level trait to affect when run randomly or when not overridden.
	var/target_trait = ZTRAIT_STATION
	/// For barometers to know when the next storm will hit
	var/next_hit_time = 0
	/// The list of turfs (only /turf/open/ subtypes) that the weather event is being applied to.
	/// If WEATHER_TURFS or WEATHER_THUNDER weather_flags are not applied this will be an empty list
	var/list/weather_turfs = list()
	/// The chance, per tick, a turf will have weather effects applied to it. This is a decimal value, 1.00 = 100%, 0.50 = 50%, etc.
	/// Recommend setting this low near 0.01 (results in 1 in 100 affected turfs having weather reagents applied per tick)
	var/turf_weather_chance = 0
	/// The chance, per tick, a turf will have a thunder strike applied to it. This is a decimal value, 1.00 = 100%, 0.50 = 50%, etc.
	/// Recommend setting this really low near 0.001 (results in 1 in 1000 affected turfs having thunder strikes applied per tick)
	var/turf_thunder_chance = THUNDER_CHANCE_AVERAGE // does nothing without the WEATHER_THUNDER weather_flag
	/// The maximum amount of turfs that can be processed in a single tick regardless of
	/// the number of turfs determined by turf_weather_chance and turf_thunder_chance
	/// increasing this too high can result in severe lag so please be careful
	var/max_turfs_per_tick = 500
	/// The calculated amount of turfs that get weather effects processed each tick (this gets calculated do not manually set this var)
	var/weather_turfs_per_tick = 0
	/// The calculated amount of turfs that get thunder effects processed each tick (this gets calculated do not manually set this var)
	var/thunder_turfs_per_tick = 0
	/// Color to apply to thunder while weather is occuring
	var/thunder_color = null

	/// List of weather bitflags that determines effects (see \code\__DEFINES\weather.dm)
	var/weather_flags = NONE

	/// List of current mobs being processed by weather
	var/list/current_mobs = list()
	/// The weather turf counter to keep track of how many turfs we have processed so far
	var/turf_iteration = 0
	/// The weather thunder counter to keep track of how much thunder we have processed so far
	var/thunder_iteration = 0
	/// The current section our weather subsystem is processing
	var/currentpart
	/// The list of allowed tasks our weather subsystem is allowed to process (determined by weather_flags)
	var/list/subsystem_tasks = list()

/datum/weather/New(z_levels, area_override, weather_flags_override, thunder_chance_override, datum/reagent/custom_reagent)
	..()
	impacted_z_levels = z_levels
	area_type = area_override || area_type
	weather_flags = weather_flags_override || weather_flags

	// turf_thunder_chance = thunder_chance_override || turf_thunder_chance
	// this breaks when thunder_chance_override is 0 (aka FALSE), so we need to null check
	turf_thunder_chance = !isnull(thunder_chance_override) ? thunder_chance_override : turf_thunder_chance

	if(IS_WEATHER_AESTHETIC(weather_flags))
		return

	if(weather_flags & (WEATHER_MOBS))
		subsystem_tasks += SSWEATHER_MOBS
	if(weather_flags & (WEATHER_TURFS))
		subsystem_tasks += SSWEATHER_TURFS
	if(weather_flags & (WEATHER_THUNDER))
		subsystem_tasks += SSWEATHER_THUNDER

	currentpart = subsystem_tasks[1]
/**
 * Telegraphs the beginning of the weather on the impacted z levels
 *
 * Sends sounds and details to mobs in the area
 * Calculates duration and hit areas, and makes a callback for the actual weather to start
 *
 */
/datum/weather/proc/telegraph()
	if(stage == STARTUP_STAGE)
		return
	stage = STARTUP_STAGE
	setup_weather_areas(impacted_areas)
	setup_weather_looping_sounds()

	if(weather_flags & (WEATHER_TURFS|WEATHER_THUNDER))
		setup_weather_turfs()

	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_TELEGRAPH(type), src)

	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	SSweather.processing |= src
	update_areas()
	if(telegraph_duration)
		send_alert(telegraph_message, telegraph_sound, telegraph_sound_vol)
	addtimer(CALLBACK(src, PROC_REF(start)), telegraph_duration)

/datum/weather/proc/setup_weather_looping_sounds()
	for(var/mob/listener in GLOB.player_list)
		listener.AddElement(/datum/element/weather_listener, src)

/datum/weather/proc/setup_weather_areas(list/selected_areas)
	if(length(selected_areas))
		return // impacted areas already been setup

	var/list/affectareas = list()
	for(var/area/selected_area as anything in get_areas(area_type))
		affectareas += selected_area
	for(var/area/protected_area as anything in protected_areas)
		affectareas -= get_areas(protected_area)
	for(var/area/affected_area as anything in affectareas)
		if(!(weather_flags & WEATHER_INDOORS) && !affected_area.outdoors)
			continue

		for(var/z in impacted_z_levels)
			if(length(affected_area.turfs_by_zlevel) >= z && length(affected_area.turfs_by_zlevel[z]))
				selected_areas |= affected_area
				continue

/datum/weather/proc/setup_weather_turfs()
	for(var/area/weather_area as anything in impacted_areas)
		for(var/z in impacted_z_levels)
			for(var/turf/valid_weather_turf as anything in weather_area.get_turfs_by_zlevel(z))
				// applying weather effects to solid walls is a waste since nothing will happen
				if(isclosedturf(valid_weather_turf))
					continue
				// same logic for space and openspace turfs which should boost performance a ton
				// note - mobs in space/openspace turfs still have weather affects applied to them if they are in a affected area
				if(is_space_or_openspace(valid_weather_turf))
					continue
				// solid windows are also worth skipping
				var/obj/structure/window/window = locate() in valid_weather_turf
				if(window?.fulltile)
					continue

				weather_turfs += valid_weather_turf

	var/total_turfs = length(weather_turfs)

	if(!total_turfs || !(weather_flags & (WEATHER_TURFS|WEATHER_THUNDER)))
		return

	if(weather_flags & (WEATHER_TURFS))
		weather_turfs_per_tick = total_turfs * turf_weather_chance
		weather_turfs_per_tick = min(weather_turfs_per_tick, max_turfs_per_tick)
	if(weather_flags & (WEATHER_THUNDER))
		thunder_turfs_per_tick = total_turfs * turf_thunder_chance
		thunder_turfs_per_tick = min(thunder_turfs_per_tick, max_turfs_per_tick)

/**
 * Starts the actual weather and effects from it
 *
 * Updates area overlays and sends sounds and messages to mobs to notify them
 * Begins dealing effects from weather to mobs in the area
 *
 */
/datum/weather/proc/start()
	if(stage >= MAIN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_START(type), src)
	stage = MAIN_STAGE
	update_areas()
	send_alert(weather_message, weather_sound)
	if(!(weather_flags & (WEATHER_ENDLESS)))
		addtimer(CALLBACK(src, PROC_REF(wind_down)), weather_duration)
	for(var/area/impacted_area as anything in impacted_areas)
		SEND_SIGNAL(impacted_area, COMSIG_WEATHER_BEGAN_IN_AREA(type), src)

/**
 * Weather enters the winding down phase, stops effects
 *
 * Updates areas to be in the winding down phase
 * Sends sounds and messages to mobs to notify them
 *
 */
/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_WINDDOWN(type), src)
	stage = WIND_DOWN_STAGE
	update_areas()
	send_alert(end_message, end_sound, end_sound_vol)
	addtimer(CALLBACK(src, PROC_REF(end)), end_duration)

/**
 * Fully ends the weather
 *
 * Effects no longer occur and area overlays are removed
 * Removes weather from processing completely
 *
 */
/datum/weather/proc/end()
	if(stage == END_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_END(type), src)
	stage = END_STAGE
	SSweather.processing -= src
	update_areas()
	for(var/area/impacted_area as anything in impacted_areas)
		SEND_SIGNAL(impacted_area, COMSIG_WEATHER_ENDED_IN_AREA(type), src)

// handles sending all alerts
/datum/weather/proc/send_alert(alert_msg, alert_sfx, alert_sfx_vol = 100)
	for(var/z_level in impacted_z_levels)
		for(var/mob/player as anything in SSmobs.clients_by_zlevel[z_level])
			if(!can_get_alert(player))
				continue
			if(alert_msg)
				to_chat(player, alert_msg)
			if(alert_sfx)
				player.stop_sound_channel(CHANNEL_WEATHER)
				SEND_SOUND(player, sound(alert_sfx, channel = CHANNEL_WEATHER, volume = alert_sfx_vol))

// the checks for if a mob should receive alerts, returns TRUE if can
/datum/weather/proc/can_get_alert(mob/player)
	var/turf/mob_turf = get_turf(player)
	return !isnull(mob_turf)

/**
 * Returns TRUE if the living mob can be affected by the weather
 */
/datum/weather/proc/can_weather_act_mob(mob/living/mob_to_check)
	var/turf/mob_turf = get_turf(mob_to_check)

	if(!mob_turf)
		return

	if(!(mob_turf.z in impacted_z_levels))
		return

	if((immunity_type && HAS_TRAIT(mob_to_check, immunity_type)) || HAS_TRAIT(mob_to_check, TRAIT_WEATHER_IMMUNE))
		return

	var/atom/loc_to_check = mob_to_check.loc
	while(loc_to_check != mob_turf)
		if((immunity_type && HAS_TRAIT(loc_to_check, immunity_type)) || HAS_TRAIT(loc_to_check, TRAIT_WEATHER_IMMUNE))
			return
		loc_to_check = loc_to_check.loc

	if(!(get_area(mob_to_check) in impacted_areas))
		return

	return TRUE

/**
 * Affects the mob with whatever the weather does
 */
/datum/weather/proc/weather_act_mob(mob/living/L)
	return

/**
 * Affects the turf with whatever the weather does
 */
/datum/weather/proc/weather_act_turf(turf/open/weather_turf)
	return

/**
 * Affects the turf with thunder
 */
/datum/weather/proc/thunder_act_turf(turf/open/weather_turf)
	var/obj/effect/temp_visual/thunderbolt/thunder = new(weather_turf)
	thunder.flash_lighting_fx(6, 2, duration = thunder.duration)

	if(thunder_color)
		thunder.color = thunder_color

	for(var/mob/living/hit_mob in weather_turf)
		to_chat(hit_mob, span_userdanger("You've been struck by lightning!"))
		hit_mob.electrocute_act(50, "thunder", flags = SHOCK_TESLA|SHOCK_NOGLOVES)

	for(var/obj/hit_thing in weather_turf)
		hit_thing.take_damage(20, BURN, ENERGY, FALSE)
	playsound(weather_turf, 'sound/effects/magic/lightningbolt.ogg', 100, extrarange = 10, falloff_distance = 10)
	weather_turf.visible_message(span_danger("A thunderbolt strikes [weather_turf]!"))
	explosion(weather_turf, light_impact_range = 1, flame_range = 1, silent = TRUE, adminlog = FALSE)

/**
 * Updates the overlays on impacted areas
 */
/datum/weather/proc/update_areas()
	var/list/new_overlay_cache = generate_overlay_cache()
	for(var/area/impacted as anything in impacted_areas)
		if(length(overlay_cache))
			impacted.overlays -= overlay_cache
			if(impacted_areas_blend_modes[impacted])
				// revert the blend mode to the old state
				impacted.blend_mode = impacted_areas_blend_modes[impacted]
				impacted_areas_blend_modes[impacted] = null
		if(length(new_overlay_cache))
			impacted.overlays += new_overlay_cache
			// only change the blend mode if it's not default or overlay
			if(impacted.blend_mode > BLEND_OVERLAY)
				// save the old blend mode state
				impacted_areas_blend_modes[impacted] = impacted.blend_mode
				impacted.blend_mode = BLEND_OVERLAY

	overlay_cache = new_overlay_cache

/// Returns a list of visual offset -> overlays to use
/datum/weather/proc/generate_overlay_cache()
	// We're ending, so no overlays at all
	if(stage == END_STAGE)
		return list()

	var/weather_state = ""
	switch(stage)
		if(STARTUP_STAGE)
			weather_state = telegraph_overlay
		if(MAIN_STAGE)
			weather_state = weather_overlay
		if(WIND_DOWN_STAGE)
			weather_state = end_overlay

	// Use all possible offsets
	// Yes this is a bit annoying, but it's too slow to calculate and store these from turfs, and it shouldn't (I hope) look weird
	var/list/gen_overlay_cache = list()
	for(var/offset in 0 to SSmapping.max_plane_offset)
		// Note: what we do here is effectively apply two overlays to each area, for every unique multiz layer they inhabit
		// One is the base, which will be masked by lighting. the other is "glowing", and provides a nice contrast
		// This method of applying one overlay per z layer has some minor downsides, in that it could lead to improperly doubled effects if some have alpha
		// I prefer it to creating 2 extra plane masters however, so it's a cost I'm willing to pay
		// LU
		if(use_glow)
			var/mutable_appearance/glow_overlay = mutable_appearance('icons/effects/glow_weather.dmi', weather_state, overlay_layer, null, WEATHER_GLOW_PLANE, 100, offset_const = offset)
			glow_overlay.color = weather_color
			gen_overlay_cache += glow_overlay

		var/mutable_appearance/new_weather_overlay = mutable_appearance('icons/effects/weather_effects.dmi', weather_state, overlay_layer, plane = overlay_plane, offset_const = offset)
		new_weather_overlay.color = weather_color
		gen_overlay_cache += new_weather_overlay

	return gen_overlay_cache

/// Updates the currentpart with the subsystem task that is next in line
/datum/weather/proc/next_subsystem_task()
	// loops back to the start of the list once it reaches the end
	var/next_part = currentpart % length(subsystem_tasks) + 1
	currentpart = subsystem_tasks[next_part]

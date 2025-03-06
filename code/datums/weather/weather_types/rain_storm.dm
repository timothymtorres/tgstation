/datum/weather/rain_storm
	name = "rain"
	desc = "Heavy thunderstorms rain down below, drenching anyone caught in it."

	telegraph_message = span_danger("Thunder rumbles far above. You hear droplets drumming against the canopy.")
	telegraph_overlay = "rain_low"
	telegraph_duration = 30 SECONDS

	weather_message = span_userdanger("<i>Rain pours down around you!</i>")
	weather_overlay = "rain_high"

	end_message = span_bolddanger("The downpour gradually slows to a light shower.")
	end_overlay = "rain_low"
	end_duration = 30 SECONDS

	weather_duration_lower = 3 MINUTES
	weather_duration_upper = 5 MINUTES

	weather_color = null
	thunder_color = null

	area_type = /area
	target_trait = ZTRAIT_RAINSTORM
	immunity_type = TRAIT_RAINSTORM_IMMUNE
	probability = 0
	turf_weather_chance = 0.01
	turf_thunder_chance = THUNDER_CHANCE_AVERAGE

	weather_flags = (WEATHER_TURFS | WEATHER_MOBS | WEATHER_THUNDER | WEATHER_BAROMETER | WEATHER_NOTIFICATION)

	/// A weighted list of possible reagents that will rain down from the sky.
	/// Only one of these will be selected to be used as the reagent
	var/list/whitelist_weather_reagents = list(/datum/reagent/water)
	/// A list of reagents that are forbidden from being selected when there is no
	/// whitelist and the reagents are randomized
	var/list/blacklist_weather_reagents = list()
	/// The selected reagent that will be rained down
	var/datum/reagent/rain_reagent

/datum/weather/rain_storm/New(z_levels, area_override, weather_flags_override, thunder_chance_override, datum/reagent/custom_reagent)
	..()

	if(IS_WEATHER_AESTHETIC(weather_flags))
		return

	var/reagent_id
	if(custom_reagent)
		reagent_id = custom_reagent
	else if(whitelist_weather_reagents)
		reagent_id = pick_weight_recursive(whitelist_weather_reagents)
	else // randomized
		reagent_id = get_random_reagent_id(blacklist_weather_reagents)

	rain_reagent = find_reagent_object_from_type(reagent_id)

	if(!rain_reagent)
		CRASH("Attempted to call rain_storm weather with no rain_reagent present!")

	weather_color = rain_reagent.color

/datum/weather/rain_storm/telegraph()
	setup_weather_areas(impacted_areas)

	GLOB.rain_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain/start
		CHECK_TICK
	return ..()

/datum/weather/rain_storm/start()
	GLOB.rain_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain/middle
		CHECK_TICK
	return ..()

/datum/weather/rain_storm/wind_down()
	GLOB.rain_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain/end
		CHECK_TICK
	return ..()

/datum/weather/rain_storm/end()
	GLOB.rain_storm_sounds.Cut()
	return ..()

/datum/weather/rain_storm/weather_act_mob(mob/living/living)
	if(istype(rain_reagent, /datum/reagent/water))
		living.wash()
	rain_reagent.expose_mob(living, TOUCH, RAIN_REAGENT_VOLUME)

	var/rain_type = LOWER_TEXT(rain_reagent.name)
	if((weather_flags & WEATHER_NOTIFICATION) && prob(5))
		var/wetmessage = pick( "You're drenched in [rain_type]!",
		"You're completely soaked by the [rain_type] rainfall!",
		"You become soaked by the heavy [rain_type] rainfall!",
		"[capitalize(rain_type)] drips off your uniform as the rain soaks your outfit!",
		"Rushing [rain_type] rolls off your face as the rain soaks you completely!",
		"Heavy [rain_type] raindrops hit your face as the rain thoroughly soaks your body!",
		"As you move through the heavy [rain_type] rain, your clothes become completely soaked!",
		)
		to_chat(living, span_warning(wetmessage))

/datum/weather/rain_storm/weather_act_turf(turf/open/weather_turf)
	for(var/obj/thing as anything in weather_turf.contents)
		if(!thing.IsObscured())
			rain_reagent.expose_obj(thing, RAIN_REAGENT_VOLUME, TOUCH)

			// Time for the sophisticated art of catching sky-booze
			if(!is_reagent_container(thing))
				continue

			var/obj/item/reagent_containers/container = thing
			if(!container.is_open_container() || container.reagents.holder_full())
				continue

if(istype(thing, /obj/machinery/hydroponics))
	var/obj/machinery/hydroponics/plant_tray = thing
	if(plant_tray.reagents.holder_full())
		continue

	var/amount_to_add = min(plant_tray.reagents.maximum_volume - plant_tray.reagents.total_volume, RAIN_REAGENT_VOLUME)
	plant_tray.reagents.add_reagent(rain_reagent.type, amount_to_add)
	continue

			var/amount_to_add = min(container.volume - container.reagents.total_volume, RAIN_REAGENT_VOLUME)
			container.reagents.add_reagent(rain_reagent.type, amount_to_add)

	if(istype(rain_reagent, /datum/reagent/water))
		weather_turf.wash(CLEAN_ALL, TRUE)

	rain_reagent.expose_turf(weather_turf, RAIN_REAGENT_VOLUME)

/datum/weather/rain_storm/blood
	whitelist_weather_reagents = list(/datum/reagent/blood)

/datum/weather/rain_storm/plasma
	whitelist_weather_reagents = list(/datum/reagent/toxin/plasma)

/datum/weather/rain_storm/acid
	name = "acid rain"
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	telegraph_duration = 40 SECONDS
	telegraph_message = span_warning("Thunder rumbles far above. You hear acidic droplets hissing against the canopy. Seek shelter!")
	telegraph_sound = 'sound/effects/siren.ogg'

	weather_message = span_userdanger("<i>Acidic rain pours down around you! Get inside!</i>")
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2 MINUTES

	end_duration = 10 SECONDS
	end_message = span_bolddanger("The downpour gradually slows to a light shower. It should be safe outside now.")

	// these are weighted by acidpwr which causes more damage the higher it is
	whitelist_weather_reagents = list(
		/datum/reagent/toxin/acid/nitracid = 3,
		/datum/reagent/toxin/acid = 2,
		/datum/reagent/toxin/acid/fluacid = 1,
	)


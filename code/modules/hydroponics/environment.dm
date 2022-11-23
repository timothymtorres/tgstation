// Plants must breath at least 0.25 kPA to trigger a gas effect
// this is about 1% of a regular rooms partial pressure using PLANT_BREATH_PERCENTAGE
#define MIN_KPA_FOR_REACTION 0.25

// Plants die under 1/10th of regular pressure (~10 kPa)
// https://biology.stackexchange.com/questions/1242/what-is-the-lowest-pressure-at-which-plants-can-survive
#define PLANT_HAZARD_LOW_PRESSURE 10

// Plants die over 7.5 GPa pressure (~750 kPa)
// https://biology.stackexchange.com/questions/37464/what-is-the-highest-pressure-at-which-plants-can-survive
#define PLANT_HAZARD_HIGH_PRESSURE 750

// Max heat before plants start dying regardless of climate
#define PLANT_HEAT_MAX T20C + 17.5 // 310.65K (99F)
// Max heat before plants start dying for tropical climates 75F
#define PLANT_HEAT_HIGH T20C + 7.5 // 300.65K (82F)
// Max heat before plants start dying for temperate climates
#define PLANT_HEAT_NORMAL T20C + 2.5 // 295.65K (72F)

// Min cold before plants start dying for temperate climates
#define PLANT_COLD_NORMAL T20C - 2.5 // 290.65K (64F)
// Min cold before plants start dying for polar climates
#define PLANT_COLD_LOW T20C - 7.5 // 285.65K (55F)
// Min cold before plants start dying regardless of climate
#define PLANT_COLD_MIN T20C - 17.5 // 275.65K (45F)

// y=a\left(x-h\right)^{2}+k  our starting forumla for prob()

/**
 * Method for gases to affect hydroponics trays.
 * Can affect plant's health, stats, or cause the plant to react in certain ways.
 * Args:
 */
/obj/machinery/hydroponics/proc/breath(/datum/gas_mixture/plant_breath, delta_time, pressure = 0)
	return


/////////////////////////////////
/// H E L P F U L   G A S E S ///
/////////////////////////////////

// H2O tastes juicy and makes plants happy
/obj/machinery/hydroponics/water_vapor/breath(/datum/gas_mixture/plant_breath, delta_time, pressure = 0)
	if(DT_PROB(plant_breath.return_ratio(/datum/gas/water_vapor), delta_time))
		adjust_waterlevel(1)

	// H2O -> oxygen
	pressure = plant_breath.gases[/datum/gas/water_vapor][MOLES]
	plant_breath.gases[/datum/gas/water_vapor][MOLES] -= pressure
	plant_breath.gases[/datum/gas/oxygen][MOLES] += pressure

// CO2 tastes healthy and makes plants robust
/obj/machinery/hydroponics/co2/breath(/datum/gas_mixture/plant_breath, delta_time, pressure = 0)
	if(DT_PROB(plant_breath.return_ratio(/datum/gas/carbon_dioxide), delta_time))
		adjust_plant_health(1)

	// CO2 -> oxygen
	pressure = plant_breath.gases[/datum/gas/carbon_dioxide][MOLES]
	plant_breath.gases[/datum/gas/carbon_dioxide][MOLES] -= pressure
	plant_breath.gases[/datum/gas/oxygen][MOLES] += pressure

// BZ tastes sweet and makes plants safe
/obj/machinery/hydroponics/bz/breath(/datum/gas_mixture/plant_breath, delta_time, pressure = 0)
	if(DT_PROB(plant_breath.return_ratio(/datum/gas/bz), delta_time))
		adjust_pestlevel(-0.25)
		adjust_weedlevel(-0.25)

	// BZ -> N2O
	pressure = plant_breath.gases[/datum/gas/bz][MOLES]
	plant_breath.gases[/datum/gas/bz][MOLES] -= pressure
	plant_breath.gases[/datum/gas/nitrous_oxide][MOLES] += pressure

// Nitrium tastes nutritious and makes plants energized
/obj/machinery/hydroponics/nitrium/breath(/datum/gas_mixture/plant_breath, delta_time, pressure = 0)
	if(DT_PROB(plant_breath.return_ratio(/datum/gas/nitrium), delta_time))
		myseed.adjust_production(-0.5)

	// Nitrium-> nitrogen
	pressure = plant_breath.gases[/datum/gas/nitrium][MOLES]
	plant_breath.gases[/datum/gas/nitrium][MOLES] -= pressure
	plant_breath.gases[/datum/gas/nitrogen][MOLES] += pressure
	
/////////////////////////////////
/// H A R M F U L   G A S E S ///
/////////////////////////////////

// Oxygen is ignored for all plants but corpse flowers
/obj/machinery/hydroponics/o2/breath(/datum/gas_mixture/plant_breath, delta_time, pressure = 0)
	// rename gas_production trait to something else
	if(!myseed.get_gene(/datum/plant_gene/trait/gas_production))
		return

	// O2 -> miasma (only by corpse flowers)
	pressure = plant_breath.gases[/datum/gas/oxygen][MOLES]
	plant_breath.gases[/datum/gas/oxygen][MOLES] -= pressure
	plant_breath.gases[/datum/gas/miasma][MOLES] += pressure
		
// Miasma tastes rotten and makes plants depressed
/obj/machinery/hydroponics/miasma/breath(/datum/gas_mixture/plant_breath, delta_time, pressure = 0)
	// rename gas_production trait to something else
	if(myseed.get_gene(/datum/plant_gene/trait/gas_production))
		return
		
	if(DT_PROB(plant_breath.return_ratio(/datum/gas/miasma), delta_time))
		adjust_pestlevel(0.25) // bugs love miasma

	// Miasma -> O2
	pressure = plant_breath.gases[/datum/gas/miasma][MOLES]
	plant_breath.gases[/datum/gas/miasma][MOLES] -= pressure
	plant_breath.gases[/datum/gas/oxygen][MOLES] += pressure

// Tritium tastes rad and makes plants wild
/obj/machinery/hydroponics/tritium/breath(/datum/gas_mixture/plant_breath, delta_time, pressure = 0)
	if(DT_PROB(plant_breath.return_ratio(/datum/gas/tritium), delta_time))
		myseed.adjust_instability(-0.5)
		
	if(DT_PROB(plant_breath.return_ratio(/datum/gas/tritium), delta_time)) // divide by 2? 3?
		mutation_roll()
		// consider adding radiation component here?

	// Tritium -> H2O
	pressure = plant_breath.gases[/datum/gas/tritium][MOLES]
	plant_breath.gases[/datum/gas/tritium][MOLES] -= pressure
	plant_breath.gases[/datum/gas/water_vapor][MOLES] += pressure


// Plasma tastes gross and makes plants angry
/obj/machinery/hydroponics/plasma/breath(/datum/gas_mixture/plant_breath, delta_time, pressure = 0)
	if(DT_PROB(plant_breath.return_ratio(/datum/gas/plasma), delta_time))
		adjust_toxic(1)
			
	// Plasma -> Nitrogen
	pressure = plant_breath.gases[/datum/gas/plasma][MOLES]
	plant_breath.gases[/datum/gas/plasma][MOLES] -= pressure
	plant_breath.gases[/datum/gas/nitrogen][MOLES] += pressure

// Zauker tastes awful and makes plants VERY angry
/obj/machinery/hydroponics/zauker/breath(/datum/gas_mixture/plant_breath, delta_time, pressure = 0)
	if(DT_PROB(plant_breath.return_ratio(/datum/gas/zauker), delta_time))
		adjust_plant_health(-5)
		adjust_toxic(5)
		adjust_pestlevel(-0.25)
		adjust_weedlevel(-0.25)
	if(DT_PROB(plant_breath.return_ratio(/datum/gas/zauker), delta_time)) // 1/8th chance?
		plantdies()

	// Zauker -> Hyper-Noblium
	pressure = plant_breath.gases[/datum/gas/zauker][MOLES]
	plant_breath.gases[/datum/gas/zauker][MOLES] -= pressure
	plant_breath.gases[/datum/gas/hypernoblium][MOLES] += pressure









/obj/machinery/hydroponics/proc/handle_environment(datum/gas_mixture/air, delta_time)
	// don't process dead or empty trays
	if(!myseed || plant_status == HYDROTRAY_PLANT_DEAD)
		return

	// plant is in a crate or wall so just ignore atmos code
	if(!isopenturf(src.loc))
		return

	// plants die quickly if exposed to space or in a hard vaccum
	if(!air)
		if(!myseed.get_gene(/datum/plant_gene/trait/space_plant))
			adjust_plant_health(-rand(1,5) / rating)
		return

	var/pressure = air.return_pressure()
	if(pressure > PLANT_HAZARD_HIGH_PRESSURE || pressure < PLANT_HAZARD_LOW_PRESSURE)
		if(!myseed.get_gene(/datum/plant_gene/trait/space_plant))
			adjust_plant_health(-rand(1,5) / rating)


	var/temperature = air.temperature
	var/climate_damage = 0
	var/climate = myseed.climate

	switch(temperature)
		// Death plant zone (+99F)
		if(PLANT_HEAT_MAX to INFINITY)
			if(climate & TROPICAL_CLIMATE)
				climate_damage = 3
			else
				climate_damage = 5
		// Tropical plant zone (82F-99F)
		if(PLANT_HEAT_HIGH to PLANT_HEAT_MAX)
			if(climate & POLAR_CLIMATE)
				climate_damage = 3
			else if(climate & TEMPERATE_CLIMATE)
				climate_damage = 1
		// Tropical/Temperate plant zone (72F-82F)
		if(PLANT_HEAT_NORMAL to PLANT_HEAT_HIGH)
			if(climate & POLAR_CLIMATE)
				climate_damage = 2
			else if(climate & TROPICAL_CLIMATE)
				climate_damage = 1
		// Temperate plant zone (64F-72F)
		if(PLANT_COLD_NORMAL to PLANT_HEAT_NORMAL)
			if(climate & POLAR_CLIMATE|TROPICAL_CLIMATE)
				climate_damage = 1
		// Polar/Temperate plant zone (55F-64F)
		if(PLANT_COLD_LOW to PLANT_COLD_NORMAL)
			if(climate & TROPICAL_CLIMATE)
				climate_damage = 2
			else if(climate & POLAR_CLIMATE)
				climate_damage = 1
		// Polar plant zone (36F-55F)
		if(PLANT_COLD_MIN to PLANT_COLD_LOW)
			if(climate & TROPICAL_CLIMATE)
				climate_damage = 3
			else if(climate & TEMPERATE_CLIMATE)
				climate_damage = 1
		// Death plant zone (-36F)
		else
			if(climate & POLAR_CLIMATE)
				climate_damage = 3
			else
				climate_damage = 5

		if(climate_damage)
			adjust_plant_health(-rand(1, climate_damage) / rating)

			if(climate_damage > 1) // more bad effects
				adjust_potency(climate_damage-1)


	var/datum/gas_mixture/plant_breath = air.remove(air.total_moles() * PLANT_BREATH_PERCENTAGE)
	var/list/plant_breath_gases = plant_breath.gases

	for(var/gas_id in GLOB.meta_gas_info)
		plant_breath.assert_gas(gas_id)

	for(var/datum/gas/plant_gas in plant_breath_gases)
		if(plant_gas[MOLES] >= MIN_KPA_FOR_REACTION)
			src.breath[plant_gas.id](plant_breath, delta_time)

	plant_breath.garbage_collect()
	air.merge(plant_breath)


/// CUT AND PASTE THE CODE BELOW


	plant_breath_gases.assert_gases(
		/datum/gas/oxygen,
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide,
		/datum/gas/tritium,
		/datum/gas/bz,
		/datum/gas/miasma,
		/datum/gas/water_vapor,
		/datum/gas/nitrogen,
		/datum/gas/zauker,
		/datum/gas/hypernoblium,
	)

	var/O2_pp = breath.get_breath_partial_pressure(plant_breath_gases[/datum/gas/oxygen][MOLES])
	var/CO2_pp = breath.get_breath_partial_pressure(plant_breath_gases[/datum/gas/carbon_dioxide][MOLES])
	var/BZ_pp = breath.get_breath_partial_pressure(plant_breath_gases[/datum/gas/bz][MOLES])
	var/H2O_pp = breath.get_breath_partial_pressure(plant_breath_gases[/datum/gas/water_vapor][MOLES])
	var/plasma_pp = breath.get_breath_partial_pressure(plant_breath_gases[/datum/gas/plasma][MOLES])
	var/miasma_pp = breath.get_breath_partial_pressure(plant_breath_gases[/datum/gas/miasma][MOLES])
	var/tritium_pp = breath.get_breath_partial_pressure(plant_breath_gases[/datum/gas/tritium][MOLES])
	var/zauker_pp = breath.get_breath_partial_pressure(plant_breath_gases[/datum/gas/zauker][MOLES])
	var/nitrium_pp = breath.get_breath_partial_pressure(plant_breath_gases[/datum/gas/nitrium][MOLES])

	// used to keep track of how much of each gas we breath
	var/gas_breathed = 0

	/////////////////////////////////
	/// H E L P F U L   G A S E S ///
	/////////////////////////////////

	// CO2 tastes healthy and makes plants robust
	if(CO2_pp > MIN_KPA_FOR_REACTION)
		var/CO2_percentage = min(CO2_pp / plant_breath_total_pressure, 10)
		if(DT_PROB(CO2_percentage, delta_time))
			adjust_plant_health(1)

	// CO2 -> oxygen
	gas_breathed = plant_breath_gases[/datum/gas/carbon_dioxide][MOLES]
	plant_breath_gases[/datum/gas/carbon_dioxide][MOLES] -= gas_breathed
	plant_breath_gases[/datum/gas/oxygen][MOLES] += gas_breathed

	// H2O tastes juicy and makes plants happy
	if(H2O_pp > MIN_KPA_FOR_REACTION)
		var/H2O_percentage = min(H2O_pp / plant_breath_total_pressure, 25)
		if(DT_PROB(H2O_percentage, delta_time))
			adjust_waterlevel(1)

	// H2O -> oxygen
	gas_breathed = plant_breath_gases[/datum/gas/water_vapor][MOLES]
	plant_breath_gases[/datum/gas/water_vapor][MOLES] -= gas_breathed
	plant_breath_gases[/datum/gas/oxygen][MOLES] += gas_breathed

	// BZ tastes sweet and makes plants safe
	if(BZ_pp > MIN_KPA_FOR_REACTION)
		var/BZ_percentage = min(BZ_pp / plant_breath_total_pressure, 10)
		if(DT_PROB(BZ_percentage, delta_time))
			adjust_pestlevel(-0.25)
			adjust_weedlevel(-0.25)

	// BZ -> nitrogen
	gas_breathed = plant_breath_gases[/datum/gas/nitrium][MOLES]
	plant_breath_gases[/datum/gas/nitrium][MOLES] -= gas_breathed
	plant_breath_gases[/datum/gas/nitrogen][MOLES] += gas_breathed

	// Nitrium tastes nutritious and makes plants energized
	if(nitrium_pp > MIN_KPA_FOR_REACTION)
		var/nitrium_percentage = min(nitrium_pp / plant_breath_total_pressure, 10)
		if(DT_PROB(nitrium_percentage, delta_time))
			myseed.adjust_production(-0.5)

	// Nitrium-> nitrogen
	gas_breathed = plant_breath_gases[/datum/gas/nitrium][MOLES]
	plant_breath_gases[/datum/gas/nitrium][MOLES] -= gas_breathed
	plant_breath_gases[/datum/gas/nitrogen][MOLES] += gas_breathed

	/////////////////////////////////
	/// H A R M F U L   G A S E S ///
	/////////////////////////////////

	// rename gas_production trait to something else
	if(myseed.get_gene(/datum/plant_gene/trait/gas_production))
		// O2 -> miasma (only by corpse flowers)
		gas_breathed = plant_breath_gases[/datum/gas/oxygen][MOLES]
		plant_breath_gases[/datum/gas/oxygen][MOLES] -= gas_breathed
		plant_breath_gases[/datum/gas/miasma][MOLES] += gas_breathed
	else
		// Miasma tastes rotten and makes plants depressed
		if(miasma_pp > MIN_KPA_FOR_REACTION)
			var/miasma_percentage = min(miasma_pp / plant_breath_total_pressure, 25)
			if(DT_PROB(miasma_percentage, delta_time))
				adjust_pestlevel(0.25) // bugs love miasma

		// Miasma -> O2
		gas_breathed = plant_breath_gases[/datum/gas/miasma][MOLES]
		plant_breath_gases[/datum/gas/miasma][MOLES] -= gas_breathed
		plant_breath_gases[/datum/gas/oxygen][MOLES] += gas_breathed

	// Tritium tastes rad and makes plants wild
	if(tritium_pp > MIN_KPA_FOR_REACTION)
		var/tritium_percentage = min(tritium_pp / plant_breath_total_pressure, 25)
		if(DT_PROB(tritium_percentage, delta_time))
			myseed.adjust_instability(-0.5)
		if(DT_PROB(tritium_percentage * 0.25, delta_time))
			mutation_roll()
		// consider adding radiation component here?

	// Tritium -> H2O
	gas_breathed = plant_breath_gases[/datum/gas/tritium][MOLES]
	plant_breath_gases[/datum/gas/tritium][MOLES] -= gas_breathed
	plant_breath_gases[/datum/gas/water_vapor][MOLES] += gas_breathed

	// Plasma tastes gross and makes plants angry
	if(plasma_pp > MIN_KPA_FOR_REACTION)
		var/plasma_percentage = min(plasma_pp / plant_breath_total_pressure, 25)
		if(DT_PROB(plasma_percentage, delta_time))
			adjust_toxic(1)

	// Plasma -> Nitrogen
	gas_breathed = plant_breath_gases[/datum/gas/plasma][MOLES]
	plant_breath_gases[/datum/gas/plasma][MOLES] -= gas_breathed
	plant_breath_gases[/datum/gas/nitrogen][MOLES] += gas_breathed

	// Zauker tastes awful and makes plants VERY angry
	if(zauker_pp > MIN_KPA_FOR_REACTION)
		var/zauker_percentage = min(zauker_pp / plant_breath_total_pressure, 25)
		if(DT_PROB(zauker_percentage * 2, delta_time))
			adjust_plant_health(-5)
			adjust_toxic(5)
			adjust_pestlevel(-0.25)
			adjust_weedlevel(-0.25)
		if(DT_PROB(zauker_percentage * 0.25, delta_time))
			plantdies()

	// Zauker -> Hyper-Noblium
	gas_breathed = plant_breath_gases[/datum/gas/zauker][MOLES]
	plant_breath_gases[/datum/gas/zauker][MOLES] -= gas_breathed
	plant_breath_gases[/datum/gas/hypernoblium][MOLES] += gas_breathed
/// CUT AND PASTE CODE ABOVE
///

#undef MIN_KPA_FOR_REACTION
#undef PLANT_HAZARD_LOW_PRESSURE
#undef PLANT_HAZARD_HIGH_PRESSURE

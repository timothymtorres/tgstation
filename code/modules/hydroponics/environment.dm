// plants must breath at least 0.25 kPA to trigger a gas effect
// this is about 1% of a regular rooms partial pressure using PLANT_BREATH_PERCENTAGE
#define MIN_KPA_FOR_REACTION 0.25

/obj/machinery/hydroponics/proc/handle_environment(datum/gas_mixture/air, delta_time)
/// THIS code needs to be inserted into the proc before handle_environment()
	if(isnull(local_turf))// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(local_turf))//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(isclosedturf(local_turf))
		var/turf/did_it_melt = local_turf.Melt()
		if(!isclosedturf(did_it_melt)) //In case some joker finds way to place these on indestructible walls
			visible_message(span_warning("[src] melts through [local_turf]!"))
		return
/// THIS code needs to be inserted into the proc before handle_environment()

	if(!air) // plants suffer if there is no air
		return

	// don't forget to check if the plant is dead before doing all these calculations

	var/datum/gas_mixture/plant_breath = air.remove(air.total_moles() * PLANT_BREATH_PERCENTAGE)
	var/plant_breath_total_pressure = plant_breath.total_moles()
	var/list/plant_breath_gases = plant_breath.gases

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
	gas_breathed = plant_breath_gases[/datum/gas/bz][MOLES]
	plant_breath_gases[/datum/gas/bz][MOLES] -= gas_breathed
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

#undef MIN_KPA_FOR_REACTION

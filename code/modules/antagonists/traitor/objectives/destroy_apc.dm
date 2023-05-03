/datum/traitor_objective/destroy_apc
	name = "Disable or destroy the %AREA%'s APC."
	description = "The %AREA% APC has made our criminal activity too exposed. It's time to cut the power."
	progression_maximum = 35 MINUTES
	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = list(1, 2)
	abstract_type = /datum/traitor_objective/destroy_apc
	/// The APC selected for sabatogue
	var/obj/machinery/power/apc/target_apc
	/// The target area that is getting it's APC sabatogued
	var/area/target_area
	/// These locations are off limits
	var/list/blacklisted_areas = typecacheof(list(
		/area/station/ai_monitored,
		/area/station/science/ordnance/bomb,
		/area/station/security/prison,
		/area/station/maintenance,
		/area/station/solars,
		/area/station/asteroid,
	))

	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(is_type_in_typecache(possible_area, blacklisted_areas) || GLOB.typecache_powerfailure_safe_areas[possible_area.type])
			possible_areas -= possible_area
			continue

		if(initial(possible_area.outdoors) || possible_area.always_unpowered || !possible_area.requires_power)
			possible_areas -= possible_area
			continue

		var/obj/machinery/power/apc/APC = possible_area.apc

		if(!istype(APC))
			possible_areas -= possible_area
			continue

		if(!APC.cell || !APC.cell.charge)
			possible_areas -= possible_area
			continue

		if(!APC.z || !is_station_level(APC.z))
			possible_areas -= possible_area
			continue

		if(!APC.operating || APC.shorted || APC.machine_stat)
			possible_areas -= possible_area
			continue

	if(!length(possible_areas))
		return FALSE

	target_area = pick(possible_areas)
	replace_in_name("%AREA%", initial(target_area.name))
	//target_apc = target_area.apc

	RegisterSignal(target_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(on_power_disable))

/// Checks if the APC target is disabled and then succeeds objective
/datum/traitor_objective/destroy_apc/proc/check_power_disabled(area/source)
	SIGNAL_HANDLER

	// if any power is on the APC is not disabled
	if(source.powered(AREA_USAGE_LIGHT) || source.powered(AREA_USAGE_EQUIP) || source.powered(AREA_USAGE_ENVIRON))
		return

	succeed_objective()

/datum/traitor_objective/destroy_apc/ungenerate_objective(area/source)
	//if(target_apc)
	//	UnregisterSignal(target_apc, COMSIG_PARENT_QDELETING)
	target_apc = null

	UnregisterSignal(target_area, COMSIG_AREA_POWER_CHANGE)
	target_area = null


	possible_items = list(
		/area/station/medical/virology,
		/area/station/command/bridge,
		/area/station/command/heads_quarters/captain,
		/area/station/command/heads_quarters/ce,
		/area/station/command/heads_quarters/cmo,
		/area/station/command/heads_quarters/hop,
		/area/station/command/heads_quarters/hos,
		/area/station/command/heads_quarters/rd,
		/area/station/command/heads_quarters/qm,
		/area/station/command/teleporter,
		/area/station/command/gateway,
		/area/station/security/office,
		/area/station/security/lockers,
		/area/station/security/brig,
		/area/station/security/prison,
		/area/station/security/interrogation,
		/area/station/security/detectives_office
		/area/station/science/xenobiology
		/area/station/security/courtroom,
		/area/station/commons/lounge,
		/area/station/service/kitchen,
		/area/station/service/bar,
		/area/station/service/library,
		/area/station/service/chapel,
		/area/station/service/lawoffice,
		/area/station/service/hydroponics,
		/area/station/service/janitor,
		/area/station/engineering/main,
		/area/station/engineering/atmos,
		/area/station/engineering/gravity_generator,
		/area/station/medical/medbay/central,
		/area/station/medical/morgue,
		/area/station/medical/chemistry,
		/area/station/medical/cryo,
		/area/station/medical/surgery/fore,
		/area/station/medical/treatment_center,
	)

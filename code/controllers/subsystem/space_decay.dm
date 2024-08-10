/// Used to cause rust on random turfs across all space z-levels over time
/// this will naturally lead to walls and tiles slowly eroding and breaking down
/// unless the rust is removed manually by welding/scraping
SUBSYSTEM_DEF(space_decay)
	name = "Space decay"
	init_order = INIT_ORDER_SPACE_DECAY // right after mapping
	flags = SS_BACKGROUND
	wait = 10 SECONDS
	runlevels = RUNLEVEL_GAME
	var/list/space_zlevels = list()

/datum/controller/subsystem/space_decay/Initialize()
	space_zlevels = SSmapping.levels_by_trait(ZTRAIT_STATION) //ZTRAIT_SPACE_RUINS)
	if(space_zlevels.len > 0)
		return SS_INIT_SUCCESS

	var/decay_skip_message = span_boldwarning("Skipping Space Decay subsystem due to lack of space Z-levels")
	to_chat(world, decay_skip_message)
	log_world(decay_skip_message)

	can_fire = FALSE
	return SS_INIT_NO_NEED


/datum/controller/subsystem/space_decay/fire()
	// process space decay
	for(var/i in 1 to 1) //10000)
		for(var/z in space_zlevels)
			var/x = rand(1, world.maxx)
			var/y = rand(1, world.maxy)
			var/turf/target = locate(x, y, z)

			if(iswallturf(target))
				var/turf/closed/wall/wall = target
				wall.space_rust()
				continue

			target.space_rust()

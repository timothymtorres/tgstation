/**
 * Adding this element to an atom will have it automatically render an overlay.
 * The overlay can be specified in new as the first paramter; if not set it defaults to rust_overlay's rust_default
 */
/datum/element/rust
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	/// The rust image itself, since the icon and icon state are only used as an argument
	//var/image/rust_overlay
	//cached_texture_filter_icon = icon('icons/turf/composite.dmi', texture_layer_icon_state)
	var/rust_overlay

/datum/element/rust/Attach(atom/target, rust_icon = 'icons/effects/rust_overlay.dmi', rust_icon_state = "rust_default")
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(!rust_overlay)
		rust_overlay = icon(rust_icon, rust_icon_state)
	ADD_TRAIT(target, TRAIT_RUSTY, ELEMENT_TRAIT(type))
	//RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_rust_overlay))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(handle_examine))
	RegisterSignal (target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_interaction))
	RegisterSignals(target, list(COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER), COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_RUSTSCRAPER)), PROC_REF(secondary_tool_act))

	if(rust_overlay)
		//target.add_filter("rust_texture_overlay", 1, alpha_mask_filter(icon = rust_icon))

		//target_appearance_with_filters.filters = filter(type="alpha",icon=white,y=-mask_offset,flags=MASK_INVERSE)


		//ADD_KEEP_TOGETHER(source, MATERIAL_SOURCE(src))
		//source.add_filter("material_texture_[name]",1,layering_filter(icon=cached_texture_filter_icon,blend_mode=BLEND_INSET_OVERLAY))

		//target.add_overlay(new_crack_overlay)
		//ADD_KEEP_TOGETHER(target, ELEMENT_TRAIT(src))
		//target.add_filter("rust_texture_overlay", 1, layering_filter(icon=rust_icon, blend_mode=BLEND_INSET_OVERLAY))
		//overlays += food_image // To be below filters applied to src


		//var/mutable_appearance/new_crack_overlay = new(pick(crack_appearances))
		//var/mutable_appearance/rust_overlay = mutable_appearance(rust_icon, rust_icon_state)
		// Now that we have our overlay, we need to give it a unique render source so we can use a filter against it
		//var/static/uuid = 0
		//uuid++
		// * so it doesn't render on its own
		//new_crack_overlay.render_target = "*cracked_overlay_[uuid]"
		//var/render_source = new_crack_overlay.render_target
		//add_filter("mask", 1, alpha_mask_filter(icon = icon(icon, "outline")))
		//var/icon/mask = icon(target.icon, target.icon_state)
		ADD_KEEP_TOGETHER(target, ELEMENT_TRAIT(src))
		target.add_filter("blahblah",1,layering_filter(icon=rust_overlay, blend_mode=BLEND_INSET_OVERLAY))


		//rust_overlay.add_filter("rust_mask", 1, alpha_mask_filter(render_source=target, flags=MASK_SWAP))
		//target.add_overlay(rust_overlay)

		//var/list/new_filter_data = alpha_mask_filter(icon=mask, flags=MASK_INVERSE)
		//applied_cracks[target] = new_crack_overlay

		// We need to add it as an overlay so the render target from the filter knows what to point at

		//target.add_filter(target, 1, new_filter_data)


		//var/config_path = get_greyscale_config_for(target.greyscale_config)
		//var/greyscale_colors = "#735b4d"
		//target.set_greyscale(greyscale_colors)

	// Unfortunately registering with parent sometimes doesn't cause an overlay update
	target.update_appearance()

/datum/element/rust/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(source, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(source, COMSIG_ATOM_ITEM_INTERACTION)
	UnregisterSignal(source, list(COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER), COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_RUSTSCRAPER)))
	REMOVE_TRAIT(source, TRAIT_RUSTY, ELEMENT_TRAIT(type))

	if(rust_overlay)
		source.remove_filter("rust_texture_overlay")
		REMOVE_KEEP_TOGETHER(source, ELEMENT_TRAIT(src))

	source.update_appearance()

/datum/element/rust/proc/handle_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_notice("[source] is very rusty, you could probably <i>burn</i> or <i>scrape</i> it off.")

/datum/element/rust/proc/apply_rust_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER


/**
/proc/getHologramIcon(icon/A, safety = TRUE, opacity = 0.5)//If safety is on, a new icon is not created.
	var/icon/flat_icon = safety ? A : new(A)//Has to be a new icon to not constantly change the same icon.
	flat_icon.ColorTone(rgb(125,180,225))//Let's make it bluish.
	flat_icon.ChangeOpacity(opacity)
	var/icon/alpha_mask = new('icons/effects/effects.dmi', "scanline")//Scanline effect.
	flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
	return flat_icon

		overlays += rust_overlay
**/



/// Because do_after sleeps we register the signal here and defer via an async call
/datum/element/rust/proc/secondary_tool_act(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(handle_tool_use), source, user, item)
	return ITEM_INTERACT_BLOCKING

/// We call this from secondary_tool_act because we sleep with do_after
/datum/element/rust/proc/handle_tool_use(atom/source, mob/user, obj/item/item)
	switch(item.tool_behaviour)
		if(TOOL_WELDER)
			if(!item.tool_start_check(user, amount=1))
				return

			user.balloon_alert(user, "burning off rust...")

			if(!item.use_tool(source, user, 5 SECONDS))
				return
			user.balloon_alert(user, "burned off rust")
			Detach(source)
			return


		if(TOOL_RUSTSCRAPER)
			if(!item.tool_start_check(user))
				return
			user.balloon_alert(user, "scraping off rust...")
			if(!item.use_tool(source, user, 2 SECONDS))
				return
			user.balloon_alert(user, "scraped off rust")
			Detach(source)
			return

/// Prevents placing floor tiles on rusted turf
/datum/element/rust/proc/on_interaction(datum/source, mob/user, obj/item/tool, modifiers)
	SIGNAL_HANDLER
	if(istype(tool, /obj/item/stack/tile) || istype(tool, /obj/item/stack/rods))
		user.balloon_alert(user, "floor too rusted!")
		return ITEM_INTERACT_BLOCKING

/// For rust applied by heretics
/datum/element/rust/heretic

/datum/element/rust/heretic/Attach(atom/target, rust_icon, rust_icon_state)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE)
		return .
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/datum/element/rust/heretic/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_ENTERED)
	UnregisterSignal(source, COMSIG_ATOM_EXITED)
	for(var/obj/effect/glowing_rune/rune_to_remove in source)
		qdel(rune_to_remove)
	for(var/mob/living/victim in source)
		victim.remove_status_effect(/datum/status_effect/rust_corruption)

/datum/element/rust/heretic/proc/on_entered(turf/source, atom/movable/entered, ...)
	SIGNAL_HANDLER

	if(!isliving(entered))
		return
	var/mob/living/victim = entered
	if(IS_HERETIC(victim))
		return
	if(victim.can_block_magic(MAGIC_RESISTANCE))
		return
	victim.apply_status_effect(/datum/status_effect/rust_corruption)

/datum/element/rust/heretic/proc/on_exited(turf/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(!isliving(gone))
		return
	var/mob/living/leaver = gone
	leaver.remove_status_effect(/datum/status_effect/rust_corruption)

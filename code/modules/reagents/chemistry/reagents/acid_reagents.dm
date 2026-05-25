//////////////////////////Acids///////////////////////

/// Trait source for the temporary ageusia (loss of taste) inflicted by drinking acid.
#define ACID_TONGUE_AGEUSIA_TRAIT "acid_tongue_melt"

/datum/reagent/acid
	name = "Sulfuric Acid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	color = "#00FF32"
	taste_description = "acid"
	taste_mult = 1.2
	self_consuming = TRUE
	ph = 2.75
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS
	/// The amount of burn damage this will cause when metabolized.
	var/acid_damage = 1
	/// the amount of protection removed from the armour
	var/acidpwr = 10

/datum/reagent/acid/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(acid_damage && affected_mob.adjust_fire_loss(METABOLIZE_FREE_CONSTANT(0.5) * acid_damage * normalise_creation_purity() * metabolization_ratio * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype))
		return UPDATE_MOB_HEALTH

// ...Why? I mean, clearly someone had to have done this and thought, well,
// acid doesn't hurt plants, but what brought us here, to this point?
/datum/reagent/acid/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume))
	mytray.adjust_toxic(round(volume * 1.5))
	mytray.adjust_weedlevel(-rand(1,2))

/datum/reagent/acid/expose_mob(mob/living/carbon/exposed_carbon, methods=TOUCH, reac_volume)
	. = ..()
	if(!istype(exposed_carbon))
		return
	var/obj/item/organ/liver/liver = exposed_carbon.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && HAS_TRAIT(liver, TRAIT_HUMAN_AI_METABOLISM))
		return
	reac_volume = round(reac_volume,0.1)
	if(methods & INGEST)
		try_melt_tongue(exposed_carbon, reac_volume)
	if(methods & (INGEST|INHALE))
		exposed_carbon.adjust_fire_loss(min(6*acid_damage, reac_volume * acid_damage), required_bodytype = affected_bodytype)
		return
	if(methods & INJECT)
		exposed_carbon.adjust_fire_loss(1.5 * min(6*acid_damage, reac_volume * acid_damage), required_bodytype = affected_bodytype)
		return
	exposed_carbon.acid_act(acidpwr, reac_volume)

/**
 * Tries to melt the tongue off a mob that just drank or ate this acid.
 *
 * Only ever called on the initial ingestion (see expose_mob), never while the acid sits in the
 * stomach, so spiking someone's drink at the bar can leave an assassination target unable to
 * speak or scream once enough acid has passed their lips. Stronger acids and larger mouthfuls
 * slur speech, kill the sense of taste for longer, and melt the tongue faster - once it's fully
 * eaten through it dissolves entirely, leaving the victim mute.
 *
 * Arguments:
 * * victim - the carbon mob who just swallowed some of us
 * * reac_volume - how much of us was swallowed this gulp
 */
/datum/reagent/acid/proc/try_melt_tongue(mob/living/carbon/victim, reac_volume)
	if(acid_damage <= 0)
		return // harmless acids (e.g. neutralised bio-acid) don't melt anything

	var/obj/item/organ/tongue/melting_tongue = victim.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(isnull(melting_tongue))
		return // no tongue, nothing to melt

	// only flesh-and-blood tongues melt. robotic voiceboxes and mineral golem "tongues" shrug
	// the acid off entirely, which is what lets rock golems and IPCs drink acid safely.
	if(!IS_ORGANIC_ORGAN(melting_tongue))
		return

	// stronger acids and bigger mouthfuls chew through the tongue (and the senses it provides) faster
	var/melt_power = acid_damage * reac_volume
	var/effect_duration = melt_power SECONDS

	// a scorched tongue makes for slurred speech...
	victim.adjust_slurring(effect_duration)
	// ...and a deadened sense of taste for a while, scaling with how badly it got burned
	ADD_TRAIT(victim, TRAIT_AGEUSIA, ACID_TONGUE_AGEUSIA_TRAIT)
	addtimer(TRAIT_CALLBACK_REMOVE(victim, TRAIT_AGEUSIA, ACID_TONGUE_AGEUSIA_TRAIT), effect_duration, TIMER_UNIQUE|TIMER_OVERRIDE)

	melting_tongue.apply_organ_damage(melt_power)

	// drinking acid HURTS - scream regardless of whether the tongue survives this particular gulp
	victim.emote("scream")
	playsound(victim, SFX_SEAR, 50, TRUE)

	// not fully melted yet - just a horrible burn and a warning
	if(melting_tongue.damage < melting_tongue.maxHealth)
		to_chat(victim, span_userdanger("Your [melting_tongue.name] burns horribly as you swallow [name]!"))
		return

	// fully melted - dissolve the tongue entirely, leaving the victim mute
	victim.visible_message(
		span_warning("[victim]'s [melting_tongue.name] sizzles and dissolves into a puff of acrid smoke!"),
		span_userdanger("Your [melting_tongue.name] dissolves into nothing as [name] sears straight through it!"),
	)
	melting_tongue.Remove(victim)
	qdel(melting_tongue)

/datum/reagent/acid/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	if(ismob(exposed_obj.loc)) //handled in human acid_act()
		return
	reac_volume = round(reac_volume,0.1)
	exposed_obj.acid_act(acidpwr, reac_volume)

/datum/reagent/acid/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if (!istype(exposed_turf))
		return
	reac_volume = round(reac_volume,0.1)
	exposed_turf.acid_act(acidpwr, reac_volume)

/datum/reagent/acid/fluacid
	name = "Fluorosulfuric Acid"
	description = "An extremely corrosive chemical substance."
	color = "#5050FF"
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	acid_damage = 2
	acidpwr = 42.0
	ph = 0.0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS

// SERIOUSLY
/datum/reagent/acid/fluacid/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume * 2))
	mytray.adjust_toxic(round(volume * 3))
	mytray.adjust_weedlevel(-rand(1,4))

/datum/reagent/acid/fluacid/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(affected_mob.adjust_fire_loss(0.5 * ((current_cycle-1)/15) * metabolization_ratio * normalise_creation_purity() * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype))
		return UPDATE_MOB_HEALTH

/datum/reagent/acid/nitracid
	name = "Nitric Acid"
	description = "An extremely corrosive chemical substance that violently reacts with living organic tissue."
	color = "#5050FF"
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	acid_damage = 3
	acidpwr = 5.0
	ph = 1.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS

/datum/reagent/acid/nitracid/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(affected_mob.adjust_fire_loss(0.5 * (volume/10) * metabolization_ratio * normalise_creation_purity() * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)) //here you go nervar
		return UPDATE_MOB_HEALTH

#define CRITICAL_CAPACITY 45

/datum/reagent/acid/industrial_waste
	name = "Industrial Waste"
	description = "Industrial Waste produced as a side effect of efficient boulder refining. Highly toxic, corrosive, and hard to get rid of."
	color = "#1eff00"
	penetrates_skin = TOUCH|VAPOR
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	acid_damage = 2
	acidpwr = 30.0
	ph = 0.0

/datum/reagent/acid/industrial_waste/on_new(data)
	. = ..()
	if(istype(holder.my_atom, /obj/machinery/plumbing/disposer))
		RegisterSignal(holder, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(pre_disposal))

/datum/reagent/acid/industrial_waste/on_merge(list/mix_data, amount)
	. = ..()
	var/merged_total = amount + volume
	if(merged_total >= CRITICAL_CAPACITY)
		spew_waste(round(volume / WASTE_REACTION_THRESHOLD * 2)) //Sure as HELL can't store it.
		var/atom/container = holder.my_atom
		var/damage_mult = 1
		if(ismachinery(container))
			damage_mult = 2
		container.take_damage(round(merged_total * damage_mult / WASTE_REACTION_THRESHOLD), BURN, BIO) //It's an unusual combination of damage type and flags, but we need to intentionally bypass beakers acid immunity.

/datum/reagent/acid/industrial_waste/burn(datum/reagents/holder)
	. = ..()
	spew_waste(2) //Can't burn it...

/datum/reagent/acid/industrial_waste/on_spark_act(power_charge, spark_flags)
	if((spark_flags & SPARK_ACT_ENCLOSED) && !ismob(holder.my_atom))
		return
	spew_waste(2) //Can't electrify it...

/datum/reagent/acid/industrial_waste/expose_obj(obj/exposed_obj, reac_volume)
	if(reac_volume < WASTE_REACTION_THRESHOLD)
		return // There's too little waste to do anything.
	if(istype(exposed_obj, /obj/effect/decal/cleanable/greenglow/waste))
		var/obj/effect/decal/cleanable/greenglow/waste/goo = exposed_obj
		goo.visible_message(span_warning("The new waste reactivates [goo]!"))
		goo.pre_dissolve(FALSE)
	return ..()

/datum/reagent/acid/industrial_waste/expose_turf(turf/exposed_turf, reac_volume)
	var/obj/effect/decal/cleanable/greenglow/waste/goo = exposed_turf.spawn_unique_cleanable(/obj/effect/decal/cleanable/greenglow/waste) //Following similar logic to how ants spawn their cleanables.
	if(QDELETED(goo))
		return

	goo.decal_reagent = type
	var/rounded_volume = round(reac_volume, 1)
	goo.reagent_amount = rounded_volume

	if(goo.lazy_init_reagents())
		goo.reagents.maximum_volume = min(goo.reagents.maximum_volume + rounded_volume, 300)
		goo.reagents.add_reagent(type, rounded_volume)
	if(goo.reagents.has_reagent(type, WASTE_REACTION_THRESHOLD))
		goo.pre_dissolve()
		return // Otherwise there's too little waste to do anything.
	return ..()

/datum/reagent/acid/industrial_waste/proc/pre_disposal()
	SIGNAL_HANDLER
	var/atom/disaster_zone = holder?.my_atom
	if(!disaster_zone)
		return
	if(prob(10))
		disaster_zone.balloon_alert_to_viewers("hissssssss!")
	spew_waste(5) //You can't just dump the industrial waste down the kitchen sink. High range to disincentivize using the chem disposaler.

/**
 * Pick a random turf in the spew range and split our total amount of waste there.
 */
/datum/reagent/acid/industrial_waste/proc/spew_waste(spew_range = 1)
	if(!spew_range)
		return

	var/atom/atom_holder = holder.my_atom
	var/turf/dropturf = get_turf(atom_holder)
	if(!dropturf)
		return //Check for at least an inital turf to start
	var/obj/effect/particle_effect/fluid/smoke/quick/greenboy = new(dropturf)
	greenboy.color = "#00ff00"
	var/list/turf/turfs = list()
	for(var/turf/open/floors in oview(spew_range, dropturf))
		if(isgroundlessturf(floors))
			continue
		turfs += floors

	if(!length(turfs))
		return
	dropturf = pick(turfs)

	expose_turf(dropturf, volume/2)
	volume = round(volume/2, 0.01)

#undef CRITICAL_CAPACITY
#undef ACID_TONGUE_AGEUSIA_TRAIT

/datum/reagent/acid
	name = "Sulfuric Acid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	color = "#00FF32"
	taste_description = "acid"
	self_consuming = TRUE
	ph = 2.75
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	penetrates_skin = NONE // Acid needs to be directly injected/ingested to metabolize (vapor/foam effects are deadly enough)
	var/burn_dmg = 1 // the damage mobs take when ingested or injected
	var/acid_pwr = 10 // the amount of protection removed from the armour

/datum/reagent/acid/on_mob_life(mob/living/carbon/victim, delta_time, times_fired)
	victim.adjustFireLoss(burn_dmg * REM * normalise_creation_purity() * delta_time)

	if(DT_PROB(burn_dmg*5, delta_time))
		to_chat(victim, span_warning("You feel something inside you melting!"))

	if(DT_PROB(16, delta_time))
		victim.adjustOrganLoss(ORGAN_SLOT_STOMACH, burn_dmg * REM * normalise_creation_purity() * delta_time)
		victim.emote("gurgle")
	else if(DT_PROB(16, delta_time))
		victim.adjustOrganLoss(ORGAN_SLOT_LIVER, burn_dmg * REM *  normalise_creation_purity() * delta_time)
		victim.emote("grimace")

	. = TRUE
	..()

// ...Why? I mean, clearly someone had to have done this and thought, well, acid doesn't hurt plants, but what brought us here, to this point?
/datum/reagent/acid/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(type, 1))
		mytray.adjust_plant_health(-round(chems.get_reagent_amount(type) * burn_dmg))
		mytray.adjust_toxic(round(chems.get_reagent_amount(type) * burn_dmg))
		mytray.adjust_weedlevel(-rand(1, 1 + burn_dmg))
		mytray.adjust_pestlevel(-rand(1, 1 + burn_dmg)) // RIP spiderlings

/datum/reagent/acid/expose_mob(mob/living/carbon/exposed_carbon, methods=TOUCH, reac_volume)
	. = ..()
	if(!istype(exposed_carbon))
		return
	reac_volume = round(reac_volume, 0.1)
	if(methods & INGEST)
		exposed_carbon.adjustFireLoss(min(6*burn_dmg, reac_volume * burn_dmg))
		return
	if(methods & INJECT)
		exposed_carbon.adjustFireLoss(1.5 * min(6*burn_dmg, reac_volume * burn_dmg))
		return
	exposed_carbon.acid_act(acid_pwr, reac_volume)

/datum/reagent/acid/expose_obj(obj/exposed_obj, reac_volume)
	. = ..()
	if(ismob(exposed_obj.loc)) //handled in human acid_act()
		return
	reac_volume = round(reac_volume, 0.1)
	exposed_obj.acid_act(acid_pwr, reac_volume)

/datum/reagent/acid/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	reac_volume = round(reac_volume, 0.1)
	exposed_turf.acid_act(acid_pwr, reac_volume)

/datum/reagent/acid/fluacid
	name = "Fluorosulfuric Acid"
	description = "Fluorosulfuric acid is an extremely corrosive chemical substance."
	color = "#5050FF"
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	ph = 0.0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	burn_dmg = 2
	acid_pwr = 42.0

/datum/reagent/acid/fluacid/on_mob_life(mob/living/carbon/victim, delta_time, times_fired)
	victim.adjustFireLoss((current_cycle/15) * REM * normalise_creation_purity() * delta_time, 0)
	. = TRUE
	..()

/datum/reagent/acid/nitracid
	name = "Nitric Acid"
	description = "Nitric acid is an extremely corrosive chemical substance that violently reacts with living organic tissue."
	color = "#5050FF"
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	ph = 1.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	burn_dmg = 3
	acid_pwr = 5.0

/datum/reagent/acid/nitracid/on_mob_life(mob/living/carbon/victim, delta_time, times_fired)
	victim.adjustFireLoss((volume/10) * REM * normalise_creation_purity() * delta_time, FALSE) //here you go nervar
	. = TRUE
	..()

/datum/reagent/acid/nitracid/expose_mob(mob/living/carbon/victim, methods=TOUCH, reac_volume)
	. = ..()
	if(!istype(victim))
		return

	reac_volume = round(reac_volume, 0.1)
	if(methods & INGEST && prob(reac_volume*3))
		var/obj/item/organ/internal/tongue/tongue = victim.getorganslot(ORGAN_SLOT_TONGUE)
		if(!tongue)
			return

		victim.emote("gurgle")
		to_chat(victim, span_warning("You feel your tongue painfully melt away!"))
		tongue.Remove(victim)
		qdel(tongue)
		return

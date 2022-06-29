/datum/mood_event/table
	description = "Someone threw me on a table!"
	mood_change = -2
	timeout = 2 MINUTES
	category = MOOD_CATEGORY_TABLE_SMASH

/datum/mood_event/table/add_effects()
	if(isfelinid(owner)) //Holy snowflake batman!
		var/mob/living/carbon/human/H = owner
		SEND_SIGNAL(H, COMSIG_ORGAN_WAG_TAIL, TRUE, 3 SECONDS)
		description = "They want to play on the table!"
		mood_change = 2

/datum/mood_event/table_limbsmash
	description = "That fucking table, man that hurts..."
	mood_change = -3
	timeout = 3 MINUTES
	category = MOOD_CATEGORY_TABLE_SMASH

/datum/mood_event/table_limbsmash/add_effects(obj/item/bodypart/banged_limb)
	if(banged_limb)
		description = "My fucking [banged_limb.name], man that hurts..."

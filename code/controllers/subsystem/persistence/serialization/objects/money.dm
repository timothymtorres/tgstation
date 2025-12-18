/obj/item/holochip/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, credits)

/obj/item/stack/spacecash/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, amount)
	. += NAMEOF(src, value)

/obj/item/stack/spacecash/PersistentInitialize()
	. = ..()
	update_appearance()

ADMIN_VERB(map_export, R_DEBUG, "Map Export", "Select a part of the map by coordinates and download it.", ADMIN_CATEGORY_DEBUG)
	var/user_x = user.mob.x
	var/user_y = user.mob.y
	var/user_z = user.mob.z
	var/z_level = tgui_input_number(user, "Export Which Z-Level?", "Map Exporter", user_z || 2)
	var/start_x = tgui_input_number(user, "Start X?", "Map Exporter", user_x || 1, world.maxx, 1)
	var/start_y = tgui_input_number(user, "Start Y?", "Map Exporter", user_y || 1, world.maxy, 1)
	var/end_x = tgui_input_number(user, "End X?", "Map Exporter", user_x || 1, world.maxx, 1)
	var/end_y = tgui_input_number(user, "End Y?", "Map Exporter", user_y || 1, world.maxy, 1)
	var/date = time2text(world.timeofday, "YYYY-MM-DD_hh-mm-ss")
	var/file_name = sanitize_filename(tgui_input_text(user, "Filename?", "Map Exporter", "exported_map_[date]"))
	var/confirm = tgui_alert(user, "Are you sure you want to do this? This will cause extreme lag!", "Map Exporter", list("Yes", "No"))

	if(confirm != "Yes")
		return

	var/map_text = write_map(start_x, start_y, z_level, end_x, end_y, z_level)
	log_admin("Build Mode: [key_name(user)] is exporting the map area from ([start_x], [start_y], [z_level]) through ([end_x], [end_y], [z_level])")
	send_exported_map(user, file_name, map_text)

ADMIN_VERB(df_map_export, R_DEBUG, "Dwarf Fortress Map Export", "Upload a dwarf fortress ascii map and convert it to dmm.", ADMIN_CATEGORY_DEBUG)
	var/df_ascii_map = input(user, "Choose a dwarf fortress ascii map to convert","Convert df map") as null|file
	if(!df_ascii_map)
		return

	var/max_z = tgui_input_number(user, "Max Z", "Map Exporter", 66)
	var/max_x = tgui_input_number(user, "Max X", "Map Exporter", 255)
	var/max_y = tgui_input_number(user, "Max Y", "Map Exporter", 255)

	var/date = time2text(world.timeofday, "YYYY-MM-DD_hh-mm-ss")
	var/file_name = sanitize_filename(tgui_input_text(user, "Filename?", "Map Exporter", "exported_map_[date]"))
	var/confirm = tgui_alert(user, "Are you sure you want to do this? This will cause extreme lag!", "Dwarf Fortress Map Export", list("Yes", "No"))

	if(confirm != "Yes")
		return

	var/map_text = convert_df_map_to_dmi(df_ascii_map, max_x, max_y, max_z) // hardcode this shit for now
	log_admin("Exporting dwarf fortress map now")
	send_exported_map(user, file_name, map_text)

/**
 * A procedure for saving DMM text to a file and then sending it to the user.
 * Arguments:
 * * user - a user which get map
 * * name - name of file + .dmm
 * * map - text with DMM format
 */
/proc/send_exported_map(user, name, map)
	var/file_path = "data/[name].dmm"
	rustg_file_write(map, file_path)
	DIRECT_OUTPUT(user, ftp(file_path, "[name].dmm"))
	var/file_to_delete = file(file_path)
	fdel(file_to_delete)

/proc/sanitize_filename(text)
	return hashtag_newlines_and_tabs(text, list("\n"="", "\t"="", "/"="", "\\"="", "?"="", "%"="", "*"="", ":"="", "|"="", "\""="", "<"="", ">"=""))

/proc/hashtag_newlines_and_tabs(text, list/repl_chars = list("\n"="#","\t"="#"))
	for(var/char in repl_chars)
		var/index = findtext(text, char)
		while(index)
			text = copytext(text, 1, index) + repl_chars[char] + copytext(text, index + length(char))
			index = findtext(text, char, index + length(char))
	return text

/**
 * A procedure for saving non-standard properties of an object.
 * For example, saving ore into a silo, and further spavn by coordinates of metal stacks objects
 */
/obj/proc/on_object_saved()
	return null

// Save resources in silo
/obj/machinery/ore_silo/on_object_saved()
	var/data
	var/datum/component/material_container/material_holder = GetComponent(/datum/component/material_container)
	for(var/each in material_holder.materials)
		var/amount = material_holder.materials[each] / 100
		var/datum/material/material_datum = each
		while(amount > 0)
			var/amount_in_stack = max(1, min(50, amount))
			amount -= amount_in_stack
			data += "[data ? ",\n" : ""][material_datum.sheet_type]{\n\tamount = [amount_in_stack]\n\t}"
	return data

/**Map exporter
* Inputting a list of turfs into convert_map_to_tgm() will output a string
* with the turfs and their objects / areas on said turf into the TGM mapping format
* for .dmm files. This file can then be opened in the map editor or imported
* back into the game.
* ============================
* This has been made semi-modular so you should be able to use these functions
* elsewhere in code if you ever need to get a file in the .dmm format
**/

/atom/proc/get_save_vars()
	return list(
		NAMEOF(src, color),
		NAMEOF(src, dir),
		NAMEOF(src, icon),
		NAMEOF(src, icon_state),
		NAMEOF(src, name),
		NAMEOF(src, pixel_x),
		NAMEOF(src, pixel_y),
	)

/obj/get_save_vars()
	return ..() + list(NAMEOF(src, req_access), NAMEOF(src, id_tag))

/obj/item/stack/get_save_vars()
	return ..() + NAMEOF(src, amount)

/obj/docking_port/get_save_vars()
	return ..() + list(
		NAMEOF(src, dheight),
		NAMEOF(src, dwidth),
		NAMEOF(src, height),
		NAMEOF(src, shuttle_id),
		NAMEOF(src, width),
	)
/obj/docking_port/stationary/get_save_vars()
	return ..() + NAMEOF(src, roundstart_template)

/obj/machinery/atmospherics/get_save_vars()
	return ..() + list(
		NAMEOF(src, piping_layer),
		NAMEOF(src, pipe_color),
	)

/obj/item/pipe/get_save_vars()
	return ..() + list(
		NAMEOF(src, piping_layer),
		NAMEOF(src, pipe_color),
	)

GLOBAL_LIST_INIT(save_file_chars, list(
	"a","b","c","d","e",
	"f","g","h","i","j",
	"k","l","m","n","o",
	"p","q","r","s","t",
	"u","v","w","x","y",
	"z","A","B","C","D",
	"E","F","G","H","I",
	"J","K","L","M","N",
	"O","P","Q","R","S",
	"T","U","V","W","X",
	"Y","Z",
))

/proc/to_list_string(list/build_from)
	var/list/build_into = list()
	build_into += "list("
	var/first_entry = TRUE
	for(var/item in build_from)
		CHECK_TICK
		if(!first_entry)
			build_into += ", "
		if(isnum(item) || !build_from[item])
			build_into += "[tgm_encode(item)]"
		else
			build_into += "[tgm_encode(item)] = [tgm_encode(build_from[item])]"
		first_entry = FALSE
	build_into += ")"
	return build_into.Join("")

/// Takes a constant, encodes it into a TGM valid string
/proc/tgm_encode(value)
	if(istext(value))
		//Prevent symbols from being because otherwise you can name something
		// [";},/obj/item/gun/energy/laser/instakill{name="da epic gun] and spawn yourself an instakill gun.
		return "\"[hashtag_newlines_and_tabs("[value]", list("{"="", "}"="", "\""="", ";"="", ","=""))]\""
	if(isnum(value) || ispath(value))
		return "[value]"
	if(islist(value))
		return to_list_string(value)
	if(isnull(value))
		return "null"
	if(isicon(value) || isfile(value))
		return "'[value]'"
	// not handled:
	// - pops: /obj{name="foo"}
	// - new(), newlist(), icon(), matrix(), sound()

	// fallback: string
	return tgm_encode("[value]")

/**
 *Procedure for converting a coordinate-selected part of the map into text for the .dmi format
 */
/proc/write_map(
	minx,
	miny,
	minz,
	maxx,
	maxy,
	maxz,
	save_flag = ALL,
	shuttle_area_flag = SAVE_SHUTTLEAREA_DONTCARE,
	list/obj_blacklist = list(),
)
	var/width = maxx - minx
	var/height = maxy - miny
	var/depth = maxz - minz

	//Step 0: Calculate the amount of letters we need (26 ^ n > turf count)
	var/turfs_needed = width * height
	var/layers = FLOOR(log(GLOB.save_file_chars.len, turfs_needed) + 0.999,1)

	//Step 1: Run through the area and generate file data
	var/list/header_data = list() //holds the data of a header -> to its key
	var/list/header = list() //The actual header in text
	var/list/contents = list() //The contents in text (bit at the end)
	var/key_index = 1 // How many keys we've generated so far
	for(var/z in 0 to depth)
		for(var/x in 0 to width)
			contents += "\n([x + 1],1,[z + 1]) = {\"\n"
			for(var/y in height to 0 step -1)
				CHECK_TICK
				//====Get turfs Data====
				var/turf/place
				var/area/location
				var/turf/pull_from = locate((minx + x), (miny + y), (minz + z))
				//If there is nothing there, save as a noop (For odd shapes)
				if(isnull(pull_from))
					place = /turf/template_noop
					location = /area/template_noop
				//Ignore things in space, must be a space turf
				else if(istype(pull_from, /turf/open/space) && !(save_flag & SAVE_SPACE))
					place = /turf/template_noop
					location = /area/template_noop
					pull_from = null
				//Stuff to add
				else
					var/area/place_area = get_area(pull_from)
					location = place_area.type
					place = pull_from.type

				//====Saving shuttles only / non shuttles only====
				var/is_shuttle_area = ispath(location, /area/shuttle)
				if((is_shuttle_area && shuttle_area_flag == SAVE_SHUTTLEAREA_IGNORE) || (!is_shuttle_area && shuttle_area_flag == SAVE_SHUTTLEAREA_ONLY))
					place = /turf/template_noop
					location = /area/template_noop
					pull_from = null
				//====For toggling not saving areas and turfs====
				if(!(save_flag & SAVE_AREAS))
					location = /area/template_noop
				if(!(save_flag & SAVE_TURFS))
					place = /turf/template_noop
				//====Generate Header Character====
				// Info that describes this turf and all its contents
				// Unique, will be checked for existing later
				var/list/current_header = list()
				current_header += "(\n"
				//Add objects to the header file
				var/empty = TRUE
				//====SAVING OBJECTS====
				if(save_flag & SAVE_OBJECTS)
					for(var/obj/thing in pull_from)
						CHECK_TICK
						if(obj_blacklist[thing.type])
							continue
						var/metadata = generate_tgm_metadata(thing)
						current_header += "[empty ? "" : ",\n"][thing.type][metadata]"
						empty = FALSE
						//====SAVING SPECIAL DATA====
						//This is what causes lockers and machines to save stuff inside of them
						if(save_flag & SAVE_OBJECT_PROPERTIES)
							var/custom_data = thing.on_object_saved()
							current_header += "[custom_data ? ",\n[custom_data]" : ""]"
				//====SAVING MOBS====
				if(save_flag & SAVE_MOBS)
					for(var/mob/living/thing in pull_from)
						CHECK_TICK
						if(istype(thing, /mob/living/carbon)) //Ignore people, but not animals
							continue
						var/metadata = generate_tgm_metadata(thing)
						current_header += "[empty ? "" : ",\n"][thing.type][metadata]"
						empty = FALSE
				current_header += "[empty ? "" : ",\n"][place],\n[location])\n"
				//====Fill the contents file====
				var/textiftied_header = current_header.Join()
				// If we already know this header just use its key, otherwise we gotta make a new one
				var/key = header_data[textiftied_header]
				if(!key)
					key = calculate_tgm_header_index(key_index, layers)
					key_index++
					header += "\"[key]\" = [textiftied_header]"
					header_data[textiftied_header] = key
				contents += "[key]\n"
			contents += "\"}"
	return "//[DMM2TGM_MESSAGE]\n[header.Join()][contents.Join()]"

/// list of turfs to spawn from matching df ascii
GLOBAL_LIST_INIT(df_chars_to_turf, list(
	"X" = /turf/open/indestructible/boss/air,
	"#" = /turf/closed/mineral/random/volcanic, // random for now but later we need to import all the different ore veins and types directly
	"=" = /turf/closed/mineral/asteroid/porous, // red clay rock (needs to be adjusted to be easier to mine later)
	"M" = /turf/open/lava/smooth,
	"~" = /turf/open/water,
	"'" = /turf/open/misc/grass,
	"\"" = /turf/open/misc/grass,
	"^" = /turf/open/floor/iron/stairs,
	"T" = /turf/open/misc/grass,
	"B" = /turf/open/misc/grass,
	"." = /turf/open/misc/asteroid/basalt,
	"," = /turf/open/misc/dirt,
	" " = /turf/open/openspace,
	":" = /turf/open/misc/asteroid/basalt,
))

/// list of objects to spawn on top of turf from matching df ascii
GLOBAL_LIST_INIT(df_chars_to_objs, list(
	"'" = /obj/effect/spawner/random/decoration/flora,
	"\"" = /obj/effect/spawner/random/decoration/plant,
	"T" = /obj/effect/spawner/random/decoration/tree,
	"B" = /obj/effect/spawner/random/decoration/rocks,
	":" = /obj/effect/spawner/random/decoration/mushroom,
))

/**
 *Procedure for converting a coordinate-selected part of the map into text for the .dmi format
 */
/proc/convert_df_map_to_dmi(df_map_ascii, width, height, depth)
	//Step 0: Calculate the amount of letters we need (26 ^ n > turf count)
	var/turfs_needed = width * height
	var/layers = FLOOR(log(GLOB.save_file_chars.len, turfs_needed) + 0.999, 1)

	var/df_map_string = file2text(df_map_ascii)
	var/amount = lentext(df_map_string)

	//Step 1: Run through the area and generate file data
	var/list/header_data = list() //holds the data of a header -> to its key
	var/list/header = list() //The actual header in text
	var/list/contents = list() //The contents in text (bit at the end)
	var/key_index = 1 // How many keys we've generated so far
	for(var/z in 0 to depth)
		for(var/x in 0 to width)
			contents += "\n([x + 1],1,[z + 1]) = {\"\n"
			for(var/y in height to 0 step -1)
				//====Get turfs Data====
				var/pos = (x+1) + ((y) * width) + ((z)*width*height)
				var/tile_char = df_map_string[pos]
				var/turf/df_turf = GLOB.df_chars_to_turf[tile_char]
				var/area/df_area = /area/template_noop


				//====Generate Header Character====
				// Info that describes this turf and all its contents
				// Unique, will be checked for existing later
				var/list/current_header = list()
				current_header += "(\n"
				//Add objects to the header file
				var/empty = TRUE

				var/obj/df_object = GLOB.df_chars_to_objs[tile_char]
				//====SAVING OBJECTS====
				if(df_object)
					//var/metadata = generate_tgm_metadata(df_object)
					current_header += "[empty ? "" : ",\n"][df_object.type]"
					empty = FALSE

				current_header += "[empty ? "" : ",\n"][df_turf],\n[df_area])\n"
				//====Fill the contents file====
				var/textiftied_header = current_header.Join()
				// If we already know this header just use its key, otherwise we gotta make a new one
				var/key = header_data[textiftied_header]
				if(!key)
					key = calculate_tgm_header_index(key_index, layers)
					key_index++
					header += "\"[key]\" = [textiftied_header]"
					header_data[textiftied_header] = key
				contents += "[key]\n"
			contents += "\"}"
	return "//[DMM2TGM_MESSAGE]\n[header.Join()][contents.Join()]"


/proc/generate_tgm_metadata(atom/object)
	var/list/data_to_add = list()

	var/list/vars_to_save = object.get_save_vars()
	for(var/variable in vars_to_save)
		CHECK_TICK
		var/value = object.vars[variable]
		if(value == initial(object.vars[variable]) || !issaved(object.vars[variable]))
			continue
		if(variable == "icon_state" && object.smoothing_flags)
			continue

		var/text_value = tgm_encode(value)
		if(!text_value)
			continue
		data_to_add += "[variable] = [text_value]"

	if(!length(data_to_add))
		return
	return "{\n\t[data_to_add.Join(";\n\t")]\n\t}"

// Could be inlined, not a massive cost tho so it's fine
/// Generates a key matching our index
/proc/calculate_tgm_header_index(index, key_length)
	var/list/output = list()
	// We want to stick the first one last, so we walk backwards
	var/list/pull_from = GLOB.save_file_chars
	var/length = length(pull_from)
	for(var/i in key_length to 1 step -1)
		var/calculated = FLOOR((index-1) / (length ** (i - 1)), 1)
		calculated = (calculated % length) + 1
		output += pull_from[calculated]
	return output.Join()

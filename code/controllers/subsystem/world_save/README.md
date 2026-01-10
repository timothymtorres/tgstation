# World Saving System

This document explains how the world saving system works for contributors who want to add serialization support for new objects.

## Table of Contents

1. [Overview](#overview)
2. [Understanding the DMM Map Format](#understanding-the-dmm-map-format)
3. [Serialization API](#serialization-api)
4. [Adding Serialization to Objects](#adding-serialization-to-objects)
5. [Type Path Substitutions](#type-path-substitutions)
6. [Saving Objects Inside Containers](#saving-objects-inside-containers)
7. [Best Practices](#best-practices)

---

## Overview

The World saving system serializes the game world state into `.dmm` map files that can be reloaded later. This allows the server to save and restore the state of objects, turfs, and areas between rounds or during autosaves.

The system is built around several key concepts:

- **TGM Format**: The map file format used by BYOND/DreamMaker
- **Variable Serialization**: Saving object variables that differ from their initial values
- **Type Path Substitution**: Compressing save data by using specialized subtypes instead of base types with many variables
- **Container Linking**: A system for preserving parent-child relationships for objects stored inside other objects

---

## Understanding the DMM Map Format

DMM (DreamMaker Map) files use the TGM (Tile Game Map) format. Understanding this format is essential for working with the world save system.

### Basic Structure

A `.dmm` file has two sections:

1. **Header Section**: Defines unique tile compositions with letter keys
2. **Coordinate Section**: Maps coordinates to header keys

### Example: A 3x3 Grid

Consider a simple 3x3 map with some basic objects:

```dm
//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS ALARM
"a" = (
/turf/open/floor/plating,
/area/station/maintenance
)
"b" = (
/obj/structure/table,
/turf/open/floor/iron,
/area/station/commons
)
"c" = (
/obj/item/wrench{
	pixel_x = 5
	},
/obj/structure/table,
/turf/open/floor/iron,
/area/station/commons
)
"d" = (
/turf/open/floor/iron,
/area/station/commons
)

(1,1,1) = {"
aaa
dbd
dcd
"}
```

### How This Maps to a Grid

The coordinate section `(1,1,1)` represents starting at X=1, Y=1, Z=1. The grid reads **bottom-to-top** for Y coordinates:

```
Visual Grid (Y increases upward):
┌───┬───┬───┐
│ a │ a │ a │  Y=3 (top row in file = "aaa")
├───┼───┼───┤
│ d │ b │ d │  Y=2 (middle row = "dbd")
├───┼───┼───┤
│ d │ c │ d │  Y=1 (bottom row = "dcd")
└───┴───┴───┘
  X=1 X=2 X=3
```

### Tile Composition Order

Each tile definition lists atoms from **top to bottom** in this order:

1. Objects (`/obj/...`) - saved first, multiple allowed
2. Mobs (`/mob/...`) - optional
3. Turf (`/turf/...`) - exactly one required
4. Area (`/area/...`) - exactly one required

```dm
"c" = (
/obj/item/wrench{pixel_x = 5},  // Object with modified variable
/obj/structure/table,            // Another object (table under the wrench)
/turf/open/floor/iron,           // The floor turf
/area/station/commons            // The area
)
```

### Variable Serialization in TGM

When an object has variables that differ from their initial (compiled) values, they're serialized inline:

```dm
// Object with default values - no braces needed
/obj/structure/table,

// Object with modified variables - uses braces
/obj/item/wrench{
	pixel_x = 5;
	pixel_y = -3
	},

// Object with complex data
/obj/machinery/conveyor_switch{
	id = "my_conveyor";
	position = -1;
	oneway = 1
	},
```

### Why Keys Matter

The header system compresses map data by reusing definitions. If 100 tiles have identical contents, they all share one key instead of repeating the full definition 100 times.

```dm
// Instead of writing this 100 times in coordinates:
/turf/open/floor/iron,
/area/station/hallway

// We define it once:
"a" = (
/turf/open/floor/iron,
/area/station/hallway
)

// And reference "a" 100 times in the coordinate grid
```

---

## Serialization API

The world save system provides several procs that objects can override to control their serialization:

### Core Procs

|
Proc
|
Purpose
|
Returns
|
|

---

## |

## |

|
|
`get_save_vars()`
|
List of variable names to save
|
`list("var1", "var2", ...)`
|
|
`get_custom_save_vars()`
|
Variables with custom/calculated values
|
`list("var1" = value1, ...)`
|
|
`on_object_saved()`
|
Save additional data (contents, helpers)
|
`void`
|
|
`substitute_with_typepath()`
|
Replace with a more compact type
|
`typepath`
or
`FALSE`
|
|
`is_saveable()`
|
Whether object should be saved at all
|
`TRUE`
or
`FALSE`
|
|
`PersistentInitialize()`
|
Post-load initialization
|
`void`
|

### Call Order During Save

```
1. is_saveable()          - Can we save this object?
2. substitute_with_typepath() - Should we use a different type?
3. on_object_saved()      - Save any extra data (mapping helpers, contents)
4. get_save_vars()        - Get list of variables to check
5. get_custom_save_vars() - Get any custom variable values
6. generate_tgm_metadata() - Convert to TGM format string
```

---

## Adding Serialization to Objects

### Step 1: Identify What Needs Saving

Ask yourself:

- What variables change during gameplay that should persist?
- What variables are already part of the type path (don't need saving)?
- Are there any objects inside this object that need saving?

### Step 2: Override `get_save_vars()`

Return a list of variable names to save. Always call the parent and use `NAMEOF()`:

```dm
/obj/machinery/conveyor_switch/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, conveyor_speed)
	. += NAMEOF(src, position)
	. += NAMEOF(src, oneway)
```

**Why use `NAMEOF()`?** It provides compile-time checking. If you rename a variable, the compiler will catch the error instead of silently breaking saves.

Here's another example showing how to exclude variables from the parent:

```dm
/obj/structure/cable/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, cable_color)
	. += NAMEOF(src, cable_layer)

	. -= NAMEOF(src, color)  // Remove 'color' since cable_color handles this
	return .
```

### Step 3: Override `get_custom_save_vars()` (If Needed)

Use this when you need to:

- Save a calculated value
- Transform data before saving
- Save object references as IDs or type paths

```dm
/obj/machinery/power/apc/get_custom_save_vars(save_flags=ALL)
	. = ..()
	// Save charge as percentage instead of raw cell values
	if(cell_type)
		.[NAMEOF(src, start_charge)] = round((cell.charge / cell.maxcharge) * 100)
	return .
```

Another example saving reagents from a container:

```dm
/obj/item/reagent_containers/get_custom_save_vars(save_flags=ALL)
	. = ..()
	var/has_identical_reagents = TRUE
	var/list/cached_reagents = reagents.reagent_list
	var/list/reagents_to_save
	for(var/datum/reagent/reagent as anything in cached_reagents)
		var/amount = floor(reagent.volume)
		if(amount <= 0)
			continue

		LAZYSET(reagents_to_save, reagent.type, amount)

		// Check if reagent & amount are identical to initial
		if(LAZYACCESS(list_reagents, reagent.type) == amount)
			continue
		has_identical_reagents = FALSE

	if(length(reagents_to_save) != length(list_reagents))
		has_identical_reagents = FALSE

	if(!has_identical_reagents)
		.[NAMEOF(src, list_reagents)] = reagents_to_save

	return .
```

### Step 4: Override `PersistentInitialize()` (If Needed)

Called after the object loads from a save. Use for post-load setup:

```dm
/obj/machinery/camera/PersistentInitialize()
	. = ..()
	// Restore camera upgrades based on saved bitflags
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_XRAY)
		upgradeXRay()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_EMP_PROOF)
		upgradeEmpProof()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_MOTION)
		upgradeMotion()
```

Another example restoring machine state:

```dm
/obj/machinery/power/port_gen/pacman/PersistentInitialize()
	. = ..()
	if(active)
		active = FALSE  // Reset so TogglePower() works correctly
		TogglePower()
	return .
```

---

## Type Path Substitutions

Type path substitution is an optimization that replaces verbose variable serialization with compact type paths.

### The Problem

Consider atmospheric pipes. A pipe might save like this:

```dm
/obj/machinery/atmospherics/pipe/smart{
	pipe_color = "#FF0000";
	hide = 1;
	piping_layer = 4
	}
```

Multiply this by thousands of pipes and save files become huge.

### The Solution

Instead, we substitute with a specialized subtype:

```dm
/obj/machinery/atmospherics/pipe/smart/manifold4w/scrubbers/hidden/layer4
```

The type path itself encodes all the information - no variables needed!

### Implementing Substitution

```dm
/obj/machinery/atmospherics/pipe/smart/substitute_with_typepath(map_string)
	var/base_type = /obj/machinery/atmospherics/pipe/smart/manifold4w
	var/cache_key = "[base_type]-[pipe_color]-[hide]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/color_path = ""
		switch(pipe_color)
			if(COLOR_RED)
				color_path = "/scrubbers"
			if(COLOR_BLUE)
				color_path = "/supply"
			else
				color_path = "/general"

		var/visible_path = hide ? "/hidden" : "/visible"

		var/layer_path = ""
		if(piping_layer != 3)
			layer_path = "/layer[piping_layer]"

		var/full_path = "[base_type][color_path][visible_path][layer_path]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert pipe to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(cached_typepath)
		// All relevant variables are encoded in the typepath string
		TGM_MAP_BLOCK(map_string, typepath, null)

	return cached_typepath
```

### When to Use Substitution

✅ **Good candidates:**

- Objects with many subtype variants (pipes, vents, wires)
- Common objects that appear thousands of times
- Objects where variables map directly to subtypes

❌ **Poor candidates:**

- Unique objects with complex state
- Objects with few instances
- Objects where subtypes don't exist for all combinations

### Substitution with Remaining Variables

Sometimes you can substitute the type but still need to save some variables:

```dm
/obj/machinery/atmospherics/components/unary/vent_scrubber/substitute_with_typepath(map_string)
	var/base_type = /obj/machinery/atmospherics/components/unary/vent_scrubber
	var/cache_key = "[base_type]-[on]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/on_path = on ? "/on" : ""

		var/layer_path = ""
		if(piping_layer != 3)
			layer_path = "/layer[piping_layer]"

		var/full_path = "[base_type][on_path][layer_path]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert vent scrubber to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(cached_typepath)
		var/obj/machinery/atmospherics/components/unary/vent_scrubber/typepath = cached_typepath
		// These variables can't be encoded in the typepath, so save them separately
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, dir, dir)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, welded, welded)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, scrubbing, scrubbing)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, filter_types, filter_types)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, widenet, widenet)

		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	return cached_typepath
```

---

## Saving Objects Inside Containers

Many objects contain other objects (safes, bags, machines with parts). The world save system uses ID linking to preserve these relationships.

### How Container Linking Works

1. **During Save**: Parent gets a unique ID, children reference that ID
2. **During Load**: Children look up parents by ID and move inside

```dm
// Saved format example - a secure safe containing items:
/obj/structure/secure_safe{
	save_container_parent_id = "xK9mP2";
	stored_lock_code = "5173"
	},
/obj/item/documents/syndicate{
	save_container_child_id = "xK9mP2"
	},
/obj/item/stack/spacecash/c1000{
	save_container_child_id = "xK9mP2"
	},
```

### Using `save_stored_contents()`

The helper proc handles most cases automatically:

```dm
/obj/structure/secure_safe/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)
```

### Saving Non-Contents Objects

Some objects store references outside of `contents`:

```dm
/obj/machinery/defibrillator_mount/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	var/list/defib_mount_contents = list()

	// 'defib' is a var reference, not in contents
	if(defib)
		defib_mount_contents += defib

	if(defib_mount_contents.len)
		save_stored_contents(map_string, current_loc, obj_blacklist, defib_mount_contents)
```

### Restoring Container Contents

In `PersistentInitialize()`, find and restore references:

```dm
/obj/machinery/defibrillator_mount/PersistentInitialize()
	. = ..()

	// After load, children are in contents - find and assign to our var
	var/obj/item/defibrillator/defib_unit = locate(/obj/item/defibrillator) in contents
	defib = defib_unit

	if(is_operational && defib)
		begin_processing()

	update_appearance()
```

### The `include_ids` Parameter

Some containers (closets, lockers) handle insertion automatically during `Initialize()`. For these, skip ID generation:

```dm
/obj/structure/closet/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	// include_ids=FALSE because closets auto-insert nearby contents during init
	save_stored_contents(map_string, current_loc, obj_blacklist, include_ids=FALSE)
```

---

## Best Practices

### DO ✅

```dm
// Use NAMEOF for compile-time safety
. += NAMEOF(src, my_variable)

// Call parent procs
/obj/machinery/power/solar/get_save_vars(save_flags=ALL)
	. = ..()  // Always call parent first!
	. += NAMEOF(src, material_type)
	. += NAMEOF(src, power_tier)

// Check for meaningful changes in get_custom_save_vars()
/obj/machinery/power/smes/get_custom_save_vars(save_flags=ALL)
	. = ..()
	.[NAMEOF(src, charge)] = total_charge()  // Calculated value
	return .

// Update appearance after loading
/obj/machinery/biogenerator/PersistentInitialize()
	. = ..()
	update_appearance()
```

### DON'T ❌

```dm
// Don't use string literals for variable names
. += "my_variable"  // Won't catch typos or renames!

// Don't forget to call parent
/obj/machinery/example/get_save_vars(save_flags=ALL)
	return list(NAMEOF(src, foo))  // Missing parent vars!

// Don't save default values (system handles this automatically)
.[NAMEOF(src, dir)] = dir  // Wasteful if dir hasn't changed

// Don't save references directly (they won't survive reload)
.[NAMEOF(src, linked_machine)] = linked_machine  // Will be garbage after load!
```

### Blacklisting Objects

For objects that should **never** be saved, add them to the global blacklist in `save_object_blacklist.dm`. Always include a comment explaining why the object is blacklisted:

```dm
GLOBAL_LIST_INIT(save_object_blacklist, typecacheof(list(
	/obj/effect, // most effects are transient visual feedback
	/obj/projectile, // bullets shouldn't be stuck mid-air
	/mob/living/carbon, // carbon mobs are too complex to serialize reliably
	/obj/structure/closet/supplypod, // very spammy and runtimes during initialize
	/obj/item/paper/fluff/jobs/cargo/manifest, // spammed by cargo orders every round
)))
```

For conditional exclusion, override `is_saveable()`:

```dm
/obj/machinery/atmospherics/components/unary/is_saveable(turf/current_loc, list/obj_blacklist)
	// Don't save if we're under a cryo cell (it spawns us automatically)
	if(locate(/obj/machinery/cryo_cell) in loc)
		return FALSE

	return ..()
```

Another example with multiple conditions:

```dm
/obj/item/paper/is_saveable(turf/current_loc, list/obj_blacklist)
	// Don't save blank papers
	if(is_empty())
		return FALSE

	// Only save papers in specific containers to reduce spam
	if(!is_type_in_typecache(loc, GLOB.saveable_paper_container_whitelist))
		return FALSE

	return ..()
```

### Performance Considerations

1. **Cache type path lookups** - Use `GLOB.map_export_typepath_cache`
2. **Avoid saving spam objects** - Seeds, grown food, mail items
3. **Use substitution for common objects** - Pipes, vents, wires
4. **Limit objects per tile** - System caps mobs/objects per tile automatically

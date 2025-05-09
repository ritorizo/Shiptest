/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/loaded = 0 // Times loaded this round
	var/datum/parsed_map/cached_map
	var/keep_cached_map = FALSE

	/// Defaults to TRUE.
	/// If TRUE, the baseturfs of the new turfs (ignoring baseturf_bottom and space) are added
	/// to the top of the pre-existing baseturf lists, in accordance with the behavior of PlaceOnTop.
	/// If FALSE, the old turfs are replaced entirely, including their baseturfs.
	/// Note that FALSE-case behavior is altered from the original implementation, which ignored baseturfs entirely; it was intended for holodecks, which have been removed.
	var/should_place_on_top = TRUE

	///if true, creates a list of all atoms created by this template loading, defaults to FALSE
	var/returns_created_atoms = FALSE

	///the list of atoms created by this template being loaded, only populated if returns_created_atoms is TRUE
	var/list/created_atoms = list()
	//make sure this list is accounted for/cleared if you request it from ssatoms!

/datum/map_template/New(path = null, rename = null, cache = FALSE)
	if(path)
		mappath = path
	if(mappath)
		preload_size(mappath, cache)
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path, cache = FALSE)
	var/datum/parsed_map/parsed = new(file(path))
	var/bounds = parsed?.bounds
	if(bounds)
		width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
		height = bounds[MAP_MAXY]
		if(cache)
			cached_map = parsed
	return bounds

/datum/map_template/proc/initTemplateBounds(list/bounds, init_atmos = TRUE)
	if (!bounds) //something went wrong
		stack_trace("[name] template failed to initialize correctly!")
		return

	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/atoms = list()
	var/list/area/areas = list()

	var/list/turfs = block(
		locate(
			bounds[MAP_MINX],
			bounds[MAP_MINY],
			bounds[MAP_MINZ]
			),
		locate(
			bounds[MAP_MAXX],
			bounds[MAP_MAXY],
			bounds[MAP_MAXZ]
			)
		)
	for(var/L in turfs)
		var/turf/B = L
		areas |= B.loc
		for(var/A in B)
			atoms += A
			if(istype(A, /obj/structure/cable))
				cables += A
				continue
			if(istype(A, /obj/machinery/atmospherics))
				atmos_machines += A

	SSmapping.reg_in_areas_in_z(areas)
	if(SSatoms.initialized == INITIALIZATION_INSSATOMS)
		return

	SSatoms.InitializeAtoms(areas + turfs + atoms, returns_created_atoms ? created_atoms : null)
	// NOTE, now that Initialize and LateInitialize run correctly, do we really
	// need these two below?
	SSmachines.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)

	if(!init_atmos)
		return

	//calculate all turfs inside the border
	var/list/template_and_bordering_turfs = block(
		locate(
			max(bounds[MAP_MINX]-2, 1),
			max(bounds[MAP_MINY]-2, 1),
			bounds[MAP_MINZ]
			),
		locate(
			min(bounds[MAP_MAXX]+2, world.maxx),
			min(bounds[MAP_MAXY]+2, world.maxy),
			bounds[MAP_MAXZ]
			)
		)
	for(var/turf/affected_turf as anything in template_and_bordering_turfs)
		affected_turf.blocks_air = initial(affected_turf.blocks_air)
		affected_turf.air_update_turf(TRUE)
		affected_turf.levelupdate()
		// placing ruins in after planet generation was causing mis-smooths. maybe there's a better fix? not sure
		QUEUE_SMOOTH(affected_turf)

/datum/map_template/proc/load_new_z()
	var/x = round((world.maxx - width) * 0.5) + 1
	var/y = round((world.maxy - height) * 0.5) + 1

	/// Map templates which reach the boundaries of the world dont get reservation margin.
	var/reservation_margin = 1
	if(world.maxx == width && world.maxy == height)
		reservation_margin = 0

	var/r_width = width + reservation_margin
	var/r_height = height + reservation_margin

	var/datum/map_zone/mapzone = SSmapping.create_map_zone(name)
	var/datum/virtual_level/vlevel = SSmapping.create_virtual_level(name, list(), mapzone, r_width, r_height, ALLOCATION_FREE)

	if(reservation_margin)
		vlevel.reserve_margin(reservation_margin)

	var/datum/parsed_map/parsed = load_map(file(mappath), vlevel.low_x + reservation_margin + x, vlevel.low_y + reservation_margin + y, vlevel.z_value, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=should_place_on_top)
	var/list/bounds = parsed.bounds
	if(!bounds)
		return FALSE

	repopulate_sorted_areas()

	//initialize things that are normally initialized after map load
	initTemplateBounds(bounds)
	smooth_zlevel(world.maxz)
	log_game("Z-level [name] loaded at [x],[y],[world.maxz]")

	return mapzone

/datum/map_template/proc/load(turf/T, centered = FALSE, init_atmos = TRUE, show_oob_error = TRUE, timeout)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		return
	if(T.x+width-1 > world.maxx)
		if(show_oob_error)
			message_admins("<span class='adminnotice'>[src] has failed to load as it's width will be more than the world's x limit ([world.maxx])!</span>")
			stack_trace("<span class='adminnotice'>[src] has failed to load as it's width will be more than the world's x limit ([world.maxx])!/span>")
		return
	if(T.y+height-1 > world.maxy)
		if(show_oob_error)
			message_admins("<span class='adminnotice'>[src] has failed to load as it's height will be more than the world's Y limit ([world.maxy])!</span>")
			stack_trace("<span class='adminnotice'>[src] has failed to load as it's height will be more than the world's Y limit ([world.maxy])!/span>")
		return

	var/list/border = block(locate(max(T.x-1, 1),			max(T.y-1, 1),			 T.z),
							locate(min(T.x+width+1, world.maxx),	min(T.y+height+1, world.maxy), T.z))

	for(var/turf/turf_to_disable as anything in border)
		turf_to_disable.blocks_air = TRUE
		turf_to_disable.air_update_turf(TRUE)

	// Accept cached maps, but don't save them automatically - we don't want
	// ruins clogging up memory for the whole round.
	var/datum/parsed_map/parsed = cached_map || new(file(mappath))
	cached_map = keep_cached_map ? parsed : null

	var/list/turf_blacklist = list()
	update_blacklist(T, turf_blacklist)

	UNSETEMPTY(turf_blacklist)
	parsed.turf_blacklist = turf_blacklist
	if(!parsed.load(T.x, T.y, T.z, cropMap=TRUE, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=should_place_on_top, timeout = timeout))
		return
	var/list/bounds = parsed.bounds
	if(!bounds)
		return

	if(!SSmapping.loading_ruins) //Will be done manually during mapping ss init
		repopulate_sorted_areas()

	//initialize things that are normally initialized after map load
	initTemplateBounds(bounds, init_atmos)

	log_game("[name] loaded at [T.x],[T.y],[T.z]")
	return bounds

/datum/map_template/proc/post_load()
	return

/datum/map_template/proc/update_blacklist(turf/T, list/input_blacklist)
	return

/datum/map_template/proc/get_affected_turfs(turf/T, centered = FALSE)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(width/2), placement.y - round(height/2), placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x+width-1, placement.y+height-1, placement.z))


//for your ever biggening badminnery kevinz000
//❤ - Cyberboss
/proc/load_new_z_level(file, name)
	var/datum/map_template/template = new(file, name)
	template.load_new_z()

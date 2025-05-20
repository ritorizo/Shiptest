SUBSYSTEM_DEF(access)
	name = "Access"
	flags = SS_NO_INIT | SS_NO_FIRE
	init_order = INIT_ORDER_ACCESS

	var/list/access_namespaces = list()
	var/list/flags_names = list(
		"Captain" = ACCESS_SHIP_CAPTAIN,
		"Command" = ACCESS_SHIP_COMMAND,
		"Office" = ACCESS_SHIP_OFFICE,
		"Security" = ACCESS_SHIP_SECURITY,
		"Engineering" = ACCESS_SHIP_ENGINEERING,
		"Medical" = ACCESS_SHIP_MEDICAL,
		"Cargo" = ACCESS_SHIP_CARGO,
		"Service" = ACCESS_SHIP_SERVICE,
		"Science" = ACCESS_SHIP_SCIENCE
	)

/datum/controller/subsystem/access/proc/new_namespace(name, datum/faction/namespace_faction)
	access_namespaces.len++
	access_namespaces[access_namespaces.len] = list(name, namespace_faction)
	return access_namespaces.len

/// Take : category flags, Returns a list of string or empty list
/datum/controller/subsystem/access/proc/flags_to_names(access_flags)
	. = list()
	for(var/flag in flags_names)
		if(flags_names[flag] & access_flags)
			. += flag

/obj/proc/get_access_namespace()
	return new_access[1]

/obj/proc/get_access_flags()
	return new_access[2]

/obj/proc/set_access_namespace(namespace_id)
	new_access[1] = namespace_id

/obj/proc/set_access_flags(access_flag)
	new_access[2] = access_flag

/// Check if A can access B, A and B can be null, returns a boolean.
/proc/access_match(list/A, list/B)
	if (!B)
		return TRUE // We should probably do a stacktrace in this case
	if (!A)
		return B[1] == NAMESPACE_PUBLIC

	// Either the namspace match or A is ROOT or B is PUBLIC
	if((A[1] != B[1]) && !(A[1] == NAMESPACE_ROOT || B[1] == NAMESPACE_PUBLIC))
		return FALSE
	if(B[2] == 0) // If our access flag is 0, we don't need a flag and can accept
		return TRUE
	if(A[2] & B[2] != B[2]) // Check that A has all the flags of B
		return FALSE
	return TRUE // If everything matches, accept

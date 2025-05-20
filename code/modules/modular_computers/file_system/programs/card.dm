/datum/computer_file/program/card_mod
	filename = "plexagonidwriter"
	filedesc = "Plexagon Access Management"
	program_icon_state = "id"
	extended_desc = "Program for programming standarized ID cards to access doors across the sector."
	transfer_access = ACCESS_HEADS
	requires_ntnet = 0
	size = 8
	tgui_id = "NtosCard"
	program_icon = "id-card"

	/// The access pair of the currently logged in officer.
	var/authenticated = null

	// Can only get defined on stationary console altough you can carry it away if you yoink the hard drive or copy the file
	var/datum/overmap/ship/controlled/ship

	COOLDOWN_DECLARE(silicon_access_print_cooldown)

/datum/computer_file/program/card_mod/run_program(mob/living/user)
	. = ..()
	if (!.)
		return 0
	if (computer.req_ship_access && !ship)
		ship = SSshuttle.get_ship(computer) // get it once and never again
	return 1

/datum/computer_file/program/card_mod/clone()
	var/datum/computer_file/program/card_mod/temp = ..()
	temp.ship = ship
	return temp

/datum/computer_file/program/card_mod/New(obj/item/modular_computer/comp)
	. = ..()

/datum/computer_file/program/card_mod/proc/authenticate(mob/user, obj/item/card/id/id_card)
	if(!id_card)
		return

	if(access_match(id_card.new_access, list(NAMESPACE_PUBLIC, ACCESS_SHIP_COMMAND)))
		authenticated = id_card.new_access.Copy()
		return TRUE

	return FALSE

/datum/computer_file/program/card_mod/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/obj/item/computer_hardware/card_slot/card_slot
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		card_slot = computer.all_components[MC_CARD]
		printer = computer.all_components[MC_PRINT]
		if(!card_slot)
			return

	var/mob/user = usr
	var/obj/item/card/id/user_id_card = user.get_idcard(FALSE)

	var/obj/item/card/id/id_card = card_slot.stored_card

	switch(action)
		if("PRG_authenticate")
			if(!computer || !user_id_card)
				playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
				return
			if(authenticate(user, user_id_card))
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
				return TRUE
		if("PRG_logout")
			authenticated = null
			playsound(computer, 'sound/machines/terminal_off.ogg', 50, FALSE)
			return TRUE
		if("PRG_print")
			if(!computer || !printer)
				return
			if(!authenticated)
				return
			var/contents = {"<h4>Access Report</h4>
						<u>Prepared By:</u> [user_id_card && user_id_card.registered_name ? user_id_card.registered_name : "Unknown"]<br>
						<u>For:</u> [id_card.registered_name ? id_card.registered_name : "Unregistered"]<br>
						<hr>
						<u>Assignment:</u> [id_card.assignment]<br>
						<u>Access:</u><br>
						"}

			for(var/A in SSaccess.flags_to_names(id_card.get_access_flags()))
				contents += "  [A]"

			if(!printer.print_text(contents,"access report"))
				to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
				return
			else
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
				computer.visible_message(span_notice("\The [computer] prints out a paper."))
			return TRUE
		if("PRG_eject")
			if(!computer || !card_slot)
				return
			if(id_card)
				card_slot.try_eject(TRUE, user)
			else
				var/obj/item/I = user.get_active_held_item()
				if(istype(I, /obj/item/card/id))
					if(!user.transferItemToLoc(I, computer))
						return
					card_slot.stored_card = I
			playsound(computer, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
			return TRUE
		if("PRG_terminate")
			if(!computer || !authenticated)
				return

			id_card.set_access_flags(0)
			id_card.set_access_namespace(NAMESPACE_PUBLIC)
			id_card.assignment = "Unassigned"
			SEND_SIGNAL(id_card, COSMIG_ACCESS_UPDATED)
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE
		if("PRG_edit")
			if(!computer || !authenticated || !id_card)
				return
			var/new_name = reject_bad_name(params["name"]) // if reject bad name fails, the edit will just not go through instead of discarding all input, as new_name would be blank.
			if(!new_name)
				return
			id_card.registered_name = new_name
			id_card.update_label()
			id_card.update_appearance()
			SEND_SIGNAL(id_card, COSMIG_ACCESS_UPDATED)
			playsound(computer, "terminal_type", 50, FALSE)
			return TRUE
		if("PRG_assign")
			if(!computer || !authenticated || !id_card)
				return
			var/target = params["assign_target"]
			if(!target)
				return

			var/datum/job/new_job = null
			if(target == "Custom")
				var/custom_name = reject_bad_name(params["custom_name"]) // if reject bad name fails, the edit will just not go through, as custom_name would be empty
				if(custom_name)
					id_card.assignment = custom_name
					id_card.update_label()
			else
				if(ship)
					for (var/datum/job/J in ship.job_slots)
						if(J.name == target)
							new_job = J
							break
				else
					for(var/jobtype in subtypesof(/datum/job))
						var/datum/job/J = new jobtype
						if(J.name == target)
							new_job = J
							break
					if(!new_job)
						to_chat(user, span_warning("No class exists for this job: [target]"))
						return

			id_card.set_access_flags(new_job.access_flags)
			id_card.set_access_namespace(authenticated[1])
			id_card.assignment = target
			id_card.update_label()
			SEND_SIGNAL(id_card, COSMIG_ACCESS_UPDATED)
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_access")
			if(!computer || !authenticated)
				return
			var/access_flag = text2num(params["access_target"])
			id_card.set_access_flags(id_card.get_access_flags() ^ access_flag)
			return TRUE
		if ( "PRG_grantship" )
			if(!computer || !authenticated)
				return
			id_card.set_access_namespace(authenticated[1])
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if ( "PRG_denyship" )
			if(!computer || !authenticated)
				return
			if (id_card.get_access_namespace() != authenticated[1])
				return
			id_card.set_access_namespace(NAMESPACE_PUBLIC)
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE
		if ( "PRG_enableuniqueaccess" )
			if(!computer || !authenticated || !ship)
				return
			ship.unique_ship_access = TRUE
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if ( "PRG_disableuniqueaccess" )
			if(!computer || !authenticated || !ship)
				return
			ship.unique_ship_access = FALSE
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE
		if ( "PRG_printsiliconaccess" )
			if(!computer || !authenticated)
				return
			if(!COOLDOWN_FINISHED(src, silicon_access_print_cooldown))
				computer.say("Printer unavailable. Please allow a short time before attempting to print.")
				return
			if (ship)
				var/obj/item/borg/upgrade/ship_access_chip/chip = new(get_turf(computer))
				chip.ship = ship
				COOLDOWN_START(src, silicon_access_print_cooldown, 10 SECONDS)
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_grantall")
			if(!computer || !authenticated)
				return
			id_card.set_access_flags(ACCESS_SHIP_ALL)
			id_card.set_access_namespace(authenticated[1])
			SEND_SIGNAL(src, COSMIG_ACCESS_UPDATED)
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_denyall")
			if(!computer || !authenticated)
				return
			id_card.set_access_flags(0)
			SEND_SIGNAL(src, COSMIG_ACCESS_UPDATED)
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE


/datum/computer_file/program/card_mod/ui_static_data(mob/user)
	var/list/data = list()
	data["station_name"] = station_name()

	var/jobs = list()
	if(ship)
		for (var/datum/job/job in ship.job_slots)
			jobs += job.name
	data["jobs"] = jobs

	var/list/accesses = list()
	for(var/access in SSaccess.flags_names)
		accesses += list(list(
			"desc" = replacetext(access, "&nbsp", " "),
			"ref" = SSaccess.flags_names[access],
		))
	data["accesses"] = accesses

	return data

/datum/computer_file/program/card_mod/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/card_slot/card_slot
	var/obj/item/computer_hardware/printer/printer

	if(computer)
		card_slot = computer.all_components[MC_CARD]
		printer = computer.all_components[MC_PRINT]

	data["station_name"] = station_name()

	if(computer)
		data["have_id_slot"] = !!card_slot
		data["have_printer"] = !!printer
	else
		data["have_id_slot"] = FALSE
		data["have_printer"] = FALSE

	data["authenticated"] = !!authenticated

	if(computer && card_slot)
		var/obj/item/card/id/id_card = card_slot.stored_card
		data["has_id"] = !!id_card
		data["id_name"] = id_card ? id_card.name : "-----"
		if(id_card)
			data["id_rank"] = id_card.assignment ? id_card.assignment : "Unassigned"
			data["id_owner"] = id_card.registered_name ? id_card.registered_name : "-----"
			data["current_access"] = id_card.get_access_flags()

		if (id_card)
			data[ "id_has_ship_access" ] = id_card.has_ship_access(ship)
		if (ship)
			data[ "has_ship" ] = 1
			data[ "ship_has_unique_access" ] = ship.unique_ship_access

	return data

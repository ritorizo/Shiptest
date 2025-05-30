/client/proc/reestablish_db_connection()
	set category = "Server"
	set name = "Reestablish DB Connection"
	if (!CONFIG_GET(flag/sql_enabled))
		to_chat(usr, span_adminnotice("The Database is not enabled!"), confidential = TRUE)
		return

	if (SSdbcore.IsConnected())
		if (!check_rights(R_DEBUG,0))
			alert("The database is already connected! (Only those with +debug can force a reconnection)", "The database is already connected!")
			return

		var/reconnect = alert("The database is already connected! If you *KNOW* that this is incorrect, you can force a reconnection", "The database is already connected!", "Force Reconnect", "Cancel")
		if (reconnect != "Force Reconnect")
			return

		SSdbcore.Disconnect()
		log_admin("[key_name(usr)] has forced the database to disconnect")
		message_admins("[key_name_admin(usr)] has <b>forced</b> the database to disconnect!")
		BLACKBOX_LOG_ADMIN_VERB("Force Reestablished Database Connection")

	log_admin("[key_name(usr)] is attempting to re-establish the DB Connection")
	message_admins("[key_name_admin(usr)] is attempting to re-establish the DB Connection")
	BLACKBOX_LOG_ADMIN_VERB("Reestablished Database Connection")

	SSdbcore.failed_connections = 0
	if(!SSdbcore.Connect())
		message_admins("Database connection failed: " + SSdbcore.ErrorMsg())
	else
		message_admins("Database connection re-established")

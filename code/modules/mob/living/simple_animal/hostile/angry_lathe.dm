/mob/living/simple_animal/hostile/autolathe
	name = "revolted autolathe"
	desc = "It produces items using metal and glass and maybe other materials, can take design disks."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "autolathe"
	icon_living = "autolathe"
	icon_dead = "autolathe_t"
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	health = 200
	maxHealth = 200 //same as a lathe gl nerd.
	healable = 0
	melee_damage_lower = 2
	melee_damage_upper = 3
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	projectilesound = 'sound/weapons/gun/pistol/shot.ogg'
	projectiletype = /obj/projectile/hivebotbullet
	faction = list("communist")
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	minbodytemp = 0
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"
	speech_span = SPAN_ROBOT
	del_on_death = 1
	loot = list()

	var/obj/machinery/autolathe/autolathe = null

	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/hostile/autolathe/death(gibbed)
	var/turf/T = get_turf(src)
	do_sparks(3, TRUE, src)
	if(!autolathe)
		autolathe = new /obj/machinery/autolathe
	autolathe.forceMove(T)
	autolathe.deconstruct()
	..()

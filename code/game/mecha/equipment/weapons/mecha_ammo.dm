/obj/item/mecha_ammo
	name = "generic ammo box"
	desc = "A box of ammo for an unknown weapon."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/mecha/mecha_ammo.dmi'
	icon_state = "empty"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	var/rounds = 0
	var/round_term = "round"
	var/direct_load //For weapons where we re-load the weapon itself rather than adding to the ammo storage.
	var/load_audio = 'sound/weapons/gun/general/mag_bullet_insert.ogg'
	var/ammo_type

/obj/item/mecha_ammo/proc/update_ammo_name()
	if(!rounds)
		name = "empty ammo box"
		desc = "An exosuit ammuniton box that has since been emptied. Please recycle."
		icon_state = "empty"

/obj/item/mecha_ammo/attack_self(mob/user)
	..()
	if(rounds)
		to_chat(user, span_warning("You cannot flatten the ammo box until it's empty!"))
		return

	to_chat(user, span_notice("You fold [src] flat."))
	var/I = new /obj/item/stack/sheet/metal(user.loc)
	qdel(src)
	user.put_in_hands(I)

/obj/item/mecha_ammo/examine(mob/user)
	. = ..()
	if(rounds)
		. += "There [rounds > 1?"are":"is"] [rounds] [round_term][rounds > 1?"s":""] left."

/obj/item/mecha_ammo/incendiary
	name = "incendiary ammo"
	desc = "A box of incendiary ammunition for use with exosuit weapons."
	icon_state = "incendiary"
	rounds = 24
	ammo_type = "incendiary"

/obj/item/mecha_ammo/scattershot
	name = "scattershot ammo"
	desc = "A box of scaled-up buckshot, for use in exosuit shotguns."
	icon_state = "scattershot"
	rounds = 24
	ammo_type = "scattershot"

/obj/item/mecha_ammo/lmg
	name = "machine gun ammo"
	desc = "A box of linked ammunition, designed for the UMG-2 exosuit weapon."
	icon_state = "lmg"
	rounds = 200
	ammo_type = "lmg"

/obj/item/mecha_ammo/railgun_ammo
	name = "Railgun rods"
	desc = "A box of iron-tungsten rods, designed for the PR-05 exosuit weapon."
	icon_state = "railgun"
	rounds = 30
	ammo_type = "railgun"

/obj/item/mecha_ammo/lmg/tank
	name = "HMG ammo"
	desc = "A box of linked ammunition, designed for the mounted machine guns."
	rounds = 100

/obj/item/mecha_ammo/missiles_br
	name = "breaching missiles"
	desc = "A box of large missiles, ready for loading into a BRM-6 exosuit missile rack."
	icon_state = "missile_br"
	rounds = 6
	round_term = "missile"
	direct_load = TRUE
	load_audio = 'sound/weapons/gun/general/mag_bullet_insert.ogg'
	ammo_type = "missiles_br"

/obj/item/mecha_ammo/missiles_he
	name = "anti-armor missiles"
	desc = "A box of large missiles, ready for loading into an SRM-8 exosuit missile rack."
	icon_state = "missile_he"
	rounds = 8
	round_term = "missile"
	direct_load = TRUE
	load_audio = 'sound/weapons/gun/general/mag_bullet_insert.ogg'
	ammo_type = "missiles_he"

/obj/item/mecha_ammo/tank_shell
	name = "anti-armor missile"
	desc = "A large missle, intended to be loaded into a Type 207."
	icon = 'icons/obj/ammunition/ammo_bullets.dmi'
	icon_state = "srm-8"
	rounds = 1
	throw_range = 0
	round_term = "missile"
	direct_load = TRUE
	load_audio = 'sound/weapons/gun/general/load_shell.ogg'
	ammo_type = "missiles_he"

/obj/item/mecha_ammo/tank_shell/update_ammo_name() // i hate the fact that i think this is the only way to do this, what the fuck
	if(!rounds)
		qdel(src)

/obj/item/mecha_ammo/tank_shell/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/mecha_ammo/flashbang
	name = "launchable flashbangs"
	desc = "A box of smooth flashbangs, for use with a large exosuit launcher. Cannot be primed by hand."
	icon_state = "flashbang"
	rounds = 6
	round_term = "grenade"
	ammo_type = "flashbang"

/obj/item/mecha_ammo/clusterbang
	name = "launchable flashbang clusters"
	desc = "A box of clustered flashbangs, for use with a specialized exosuit cluster launcher. Cannot be primed by hand."
	icon_state = "clusterbang"
	rounds = 3
	round_term = "cluster"
	direct_load = TRUE
	ammo_type = "clusterbang"

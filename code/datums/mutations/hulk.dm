//Hulk turns your skin green, and allows you to punch through walls.
/datum/mutation/human/hulk
	name = "Hulk"
	desc = "A poorly understood genome that causes the holder's muscles to expand, inhibit speech and gives the person a bad skin condition."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = span_notice("Your muscles hurt!")
	species_allowed = list(SPECIES_HUMAN) //no skeleton/lizard hulk
	health_req = 25
	instability = 40
	var/scream_delay = 50
	var/last_scream = 0


/datum/mutation/human/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, GENETIC_MUTATION)
	ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, GENETIC_MUTATION)
	ADD_TRAIT(owner, TRAIT_CHUNKYFINGERS, GENETIC_MUTATION)
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, GENETIC_MUTATION)
	ADD_TRAIT(owner, TRAIT_HULK, GENETIC_MUTATION)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)
	RegisterSignal(owner, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(on_attack_hand))
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/human/hulk/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity)
	SIGNAL_HANDLER

	if(!proximity)
		return
	if(source.a_intent != INTENT_HARM)
		return
	if(target.attack_hulk(owner))
		if(world.time > (last_scream + scream_delay))
			last_scream = world.time
			INVOKE_ASYNC(src, PROC_REF(scream_attack), source)
		log_combat(source, target, "punched", "hulk powers")
		source.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		source.changeNext_move(CLICK_CD_MELEE)
		return COMPONENT_NO_ATTACK_HAND

/datum/mutation/human/hulk/proc/scream_attack(mob/living/carbon/human/source)
	source.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced="hulk")

/datum/mutation/human/hulk/on_life()
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, span_danger("You suddenly feel very weak."))

/datum/mutation/human/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_CHUNKYFINGERS, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_HULK, GENETIC_MUTATION)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "hulk")
	UnregisterSignal(owner, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/human/hulk/proc/handle_speech(original_message, wrapped_message)
	SIGNAL_HANDLER

	var/message = wrapped_message[1]
	if(message)
		message = "[replacetext(message, ".", "!")]!!"
	wrapped_message[1] = message
	return COMPONENT_UPPERCASE_SPEECH

/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = TRUE
	anchored = TRUE

/obj/structure/dresser/attack_hand(mob/user as mob)
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user) && anchored)
		var/mob/living/carbon/human/H = user

		var/choice = tgui_input_list(user, "Underwear, Undershirt, or Socks?", "Changing", list("Underwear","Undershirt","Socks"))

		if(!Adjacent(user))
			return
		switch(choice)
			if("Underwear")
				var/list/valid_underwear = list()
				for(var/underwear in GLOB.underwear_list)
					var/datum/sprite_accessory/S = GLOB.underwear_list[underwear]
					if(!(H.dna.species.name in S.species_allowed))
						continue
					valid_underwear[underwear] = GLOB.underwear_list[underwear]
				if(!LAZYLEN(valid_underwear))
					to_chat(user, "There are no underwear for [H.dna.species.name].")
					return
				var/new_underwear = tgui_input_list(user, "Choose your underwear:", "Changing", valid_underwear)
				if(new_underwear)
					var/datum/sprite_accessory/underwear/uwear = GLOB.underwear_list[new_underwear]
					if(uwear.allow_change_color)
						var/new_underwear_color = tgui_input_color(user, "Choose your underwear color, else color will be white:", "Changing", "#ffffff")
						H.color_underwear = isnull(new_underwear_color) ? "#ffffff" : new_underwear_color
					H.underwear = new_underwear

			if("Undershirt")
				var/list/valid_undershirts = list()
				for(var/undershirt in GLOB.undershirt_list)
					var/datum/sprite_accessory/S = GLOB.undershirt_list[undershirt]
					if(!(H.dna.species.name in S.species_allowed))
						continue
					valid_undershirts[undershirt] = GLOB.undershirt_list[undershirt]
				if(!LAZYLEN(valid_undershirts))
					to_chat(user, "There are no undershirts for [H.dna.species.name].")
					return
				var/new_undershirt = tgui_input_list(user, "Choose your undershirt:", "Changing", valid_undershirts)
				if(new_undershirt)
					var/datum/sprite_accessory/undershirt/ushirt = GLOB.undershirt_list[new_undershirt]
					if(ushirt.allow_change_color)
						var/new_undershirt_color = tgui_input_color(user, "Choose your undershirt color, else color will be white:", "Changing", "#ffffff")
						H.color_undershirt = isnull(new_undershirt_color) ? "#ffffff" : new_undershirt_color
					H.undershirt = new_undershirt

			if("Socks")
				var/list/valid_sockstyles = list()
				for(var/sockstyle in GLOB.socks_list)
					var/datum/sprite_accessory/S = GLOB.socks_list[sockstyle]
					if(!(H.dna.species.name in S.species_allowed))
						continue
					valid_sockstyles[sockstyle] = GLOB.socks_list[sockstyle]
				if(!LAZYLEN(valid_sockstyles))
					to_chat(user, "There are no socks for [H.dna.species.name].")
					return
				var/new_socks = tgui_input_list(user, "Choose your socks:", "Changing", valid_sockstyles)
				if(new_socks)
					H.socks = new_socks

		add_fingerprint(H)
		H.update_body()


/obj/structure/dresser/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/dresser/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 20)

/obj/structure/dresser/deconstruct(disassembled = FALSE)
	var/mat_drop = 15
	if(disassembled)
		mat_drop = 30
	new /obj/item/stack/sheet/wood(drop_location(), mat_drop)
	..()

/mob/living/human/gib()
	if (client)
		client.movement_busy = FALSE
	ghostize() // preserve our body's icon before it explodes

	for (var/obj/item/organ/I in internal_organs)
		I.removed()
		if (istype(loc,/turf))
			I.throw_at(get_edge_target_turf(src,pick(alldirs)),rand(1,3),30)

	for (var/obj/item/organ/external/E in organs)
		E.droplimb(0,DROPLIMB_EDGE,1)

	sleep(1)

	for (var/obj/item/I in src)
		drop_from_inventory(I)
		I.throw_at(get_edge_target_turf(src,pick(alldirs)), rand(1,3), round(30/I.w_class))

	..(species.gibbed_anim)
	gibs(loc, null, species.flesh_color, species.blood_color)
	for(var/mob/living/human/NB in view(6,src))
		if (!NB.orc)
			NB.mood -= 15
			NB.ptsd += 3
/mob/living/human/crush()

	sleep(1)

	for (var/obj/item/I in contents)
		if (!istype(I, /obj/item/organ))
			drop_from_inventory(I)
	if (client)
		client.movement_busy = FALSE
	..(species.gibbed_anim)
	gibs(loc, null, species.flesh_color, species.blood_color)

/mob/living/human/maim()
	next_emote["vocal"] = world.time + 50
	..()
	next_emote["vocal"] = world.time - 1
	emote("painscream")

/mob/living/human/death(gibbed = FALSE)

	if (stat == DEAD) return
	if (map && map.ID == MAP_GLADIATORS && client)
		var/obj/map_metadata/gladiators/GD = map
		for (var/i = 1, i <= GD.gladiator_stats.len, i++)
			if (GD.gladiator_stats[i][1] == client.ckey && GD.gladiator_stats[i][2] == name)
				GD.gladiator_stats[i][4] = 1
				GD.save_gladiators()
		src << "<big><b>[name]'s life fades away into history...</b></big>"
	else if (map && map.ID == MAP_GULAG13 && client)
		var/obj/map_metadata/gulag13/GD = map
		if (original_job && istype(original_job, /datum/job/civilian/prisoner))
			var/mob/living/human/H = src
			for(var/i in GD.points)
				if (i[1]==H.nationality)
					i[3]-=50
	else if (map && map.ID == MAP_ABASHIRI && client)
		var/obj/map_metadata/abashiri/GD = map
		if (original_job && istype(original_job, /datum/job/civilian/abashiri))
			var/mob/living/human/H = client
			for(var/i in GD.points)
				if (i[1]==H.nationality)
					i[3]-=50
	else if (map && map.ID == MAP_ALLEYWAY)
		if (civilization && civilization in map.scores)
			if (civilization == "Yamaguchi-Gumi")
				if (original_job && original_job.title == "Yama Wakagashira")
					map.scores["Ichiwa-Kai"] += 10
					world << "<font color='red' size=3>The <b>Yamaguchi-Gumi</b> underboss has been killed!</font>"
				else
					map.scores["Ichiwa-Kai"] += 1
			else
				if (original_job && original_job.title == "Ichi Wakagashira")
					map.scores["Yamaguchi-Gumi"] += 10
					world << "<font color='red' size=3>The <b>Ichiwa-Kai</b> underboss has been killed!</font>"
				else
					map.scores["Yamaguchi-Gumi"] += 1

	else if (map && map.ID == MAP_YELTSIN)
		if (civilization && civilization in map.scores)
			if (civilization == "Soviet Army")
				if (original_job && original_job.title == "Soviet Army Sergeant")
					map.scores["Militia"] += 5
					world << "<font color='red' size=3>The <b>Soviet Army</b> Sergeant has been killed!</font>"
				else if (original_job && original_job.title == "Soviet Army Lieutenant")
					map.scores["Militia"] += 10
					world << "<font color='red' size=3>The <b>Soviet Army</b> Lieutenant has been killed!</font>"
				else
					map.scores["Militia"] += 1
			else
				map.scores["Soviet Army"] += 1

	else if (map && map.ID == MAP_CAPITOL_HILL)
		if (civilization && civilization in map.scores)
			if (civilization == "National Guard")
				map.scores["Militia"] += 1
			else
				map.scores["National Guard"] += 1

	else if (map && map.ID == MAP_SEKIGAHARA)
		if (civilization && civilization in map.scores)
			if (civilization == "Eastern Army")
				if (original_job && original_job.title == "Azuma no Daimyo")
					map.scores["Western Army"] += 10
					world << "<font color='red' size=3>The <b>Eastern Army</b> daimyo has been killed!</font>"
				else if (original_job && original_job.title == "Tobu no Samurai")
					map.scores["Western Army"] += 5
				else
					map.scores["Western Army"] += 1
			else
				if (original_job && original_job.title == "Sei no Daimyo")
					map.scores["Eastern Army"] += 10
					world << "<font color='red' size=3>The <b>Western Army</b> daimyo has been killed!</font>"
				else if (original_job && original_job.title == "Sei no Samurai")
					map.scores["Eastern Army"] += 5
				else
					map.scores["Eastern Army"] += 1

	else if (map && map.ID == MAP_THE_ART_OF_THE_DEAL)
		if (civilization && civilization in map.scores)
			if (civilization == "Paramedics")
				map.scores[civilization] -= 500
			if (civilization == "Police")
				map.scores[civilization] -= 250
				if (ishuman(last_harmed))
					map.scores[last_harmed.civilization] -= 100
					global_broadcast(FREQP,"<big>10-9: Officer down! All available units proceed to [get_coded_loc()] ([x],[y])!</big>")
					var/warrant = last_harmed.civilization
					spawn(rand(300,500))
						if (warrant != "Police")
							var/obj/item/weapon/paper_bin/police/PAR = null
							for(var/obj/item/weapon/paper_bin/police/PAR2 in world)
								PAR = PAR2
								break
							if (PAR)
								var/obj/item/weapon/paper/police/searchwarrant/SW = new /obj/item/weapon/paper/police/searchwarrant(PAR.loc)
								SW.cmp = warrant
								SW.spawntimer = 18000
							global_broadcast(FREQP,"<big>Attention, warrant issued for <b>[warrant] HQ</b>, please search the premises as soon as possible.</big>")
							map.warrants += warrant
							spawn(30)
								for(var/mob/living/human/HMN in player_list)
									if (HMN.civilization == warrant)
										HMN.gun_permit = FALSE
			else
				map.scores[civilization] -= 200
	else if (map && map.ID == MAP_OCCUPATION && client)
		var/obj/map_metadata/occupation/GD = map
		var/mob/living/human/H = src
		if (original_job && istype(original_job, /datum/job/civilian/occupation))
			for(var/i in GD.points)
				if (i[1]==H.nationality)
					i[3]-=50
		if (civilization)
			if (H.civilization == "SS")
				for(var/i in GD.points)
					if (H.faction_text == GERMAN && H.original_job.is_squad_leader == TRUE)
						if (i[1]=="UPA")
							i[2]+= 15
					else if (H.faction_text == GERMAN && H.original_job.is_officer == TRUE)
						if (i[1]=="UPA")
							i[2]+= 50
					else if (H.faction_text == GERMAN)
						if (i[1]=="UPA")
							i[2]+=  5
					else
						if (i[1]=="UPA")
							i[2]-= 50
			else
				for(var/i in GD.points)
					if (H.civilization == "UPA" && H.original_job.is_squad_leader == TRUE)
						if (i[1]=="SS")
							i[2]+= 20
					else if (H.civilization == "UPA" && H.original_job.is_officer == TRUE)
						if (i[1]=="SS")
							i[2]+= 50
					else if (H.civilization == "UPA")
						if (i[1]=="SS")
							i[2]+= 5
					else if (H.civilization == "Killer")
						if (i[1]=="SS")
							i[2]+= 5
						if (i[1]=="UPA")
							i[2]+= 5
					else if (H.faction_text == GERMAN && H.original_job.is_squad_leader == TRUE)
						if (i[1]=="UPA")
							i[2]+= 15
					else if (H.faction_text == GERMAN && H.original_job.is_officer == TRUE)
						if (i[1]=="UPA")
							i[2]+= 50
					else if (H.faction_text == GERMAN)
						if (i[1]=="UPA")
							i[2]+=  5
					else
						if (i[1]=="UPA")
							i[2]-= 50

		for(var/i in GD.points)
			if (H.nationality == "Polish")
				if (i[1]=="UPA")
					i[2]+= 5
			else if (H.original_job == "Auxillary Police")
				if (i[1]=="UPA")
					i[2]+= 5
				if (i[1]=="SS")
					i[2]-= 1
/*			else
				if (i[1]=="SS")
					i[2]-= 10
				if (i[1]=="UPA")
					i[2]-= 10*/

	handle_piss()
	handle_shit()
	if (squad > 0 && original_job && original_job.uses_squads)
		if (faction_text == map.faction1)
			map.faction1_squads[squad] -= src
			if (map.faction1_squad_leaders[squad] == src)
				map.faction1_squad_leaders[squad] = null
				for(var/mob/living/human/HSM in map.faction1_squads[squad])
					if (HSM != src)
						HSM << "<big><b><font color='red'>Your squad leader has been killed!</font></b></big>"
						if (HSM.original_job.is_squad_leader && (!map.faction1_squad_leaders[squad] || map.faction1_squad_leaders[squad] == src))
							HSM << "<big><b><font color='green'>You are the new squad leader!</font></b></big>"
							map.faction1_squad_leaders[squad] = HSM
							for(var/mob/living/human/HSM2 in map.faction2_squads[squad])
								if (HSM2 != HSM)
									HSM2 << "<big><b>[HSM] is your new squad leader.</b></big>"
		else if (faction_text == map.faction2)
			map.faction2_squads[squad] -= src
			if (map.faction2_squad_leaders[squad] == src)
				map.faction2_squad_leaders[squad] = null
				for(var/mob/living/human/HSM in map.faction2_squads[squad])
					if (HSM != src)
						HSM << "<big><b><font color='red'>Your squad leader has been killed!</font></b></big>"
						if (HSM.original_job.is_squad_leader && (!map.faction2_squad_leaders[squad] || map.faction2_squad_leaders[squad] == src))
							HSM << "<big><b><font color='green'>You are the new squad leader!</font></b></big>"
							map.faction2_squad_leaders[squad] = HSM
							for(var/mob/living/human/HSM2 in map.faction2_squads[squad])
								if (HSM2 != HSM)
									HSM2 << "<big><b>[HSM] is your new squad leader.</b></big>"
	handle_hud_list()
	var/list/poss_list = list()
	if (map)
		for(var/cmp in map.custom_company_nr)
			if (find_company_member(src,cmp))
				poss_list += cmp
		if (!isemptylist(poss_list))
			for(var/stocky in poss_list)
				for(var/list/lx in map.custom_company[stocky])
					if (lx[1] == src)
						map.sales_registry += list(list(stocky,lx[2],map.custom_company_value[stocky]*(lx[2]/100)*2,null,1))
				for(var/l=1, l <= map.custom_company[stocky].len, l++)
					if (map.custom_company[stocky][l][1] == src)
						map.custom_company[stocky][l][1] = null
	src << browse(null, "window=memory")

	if (client)
		client.movement_busy = FALSE

	//Handle species-specific deaths.
	species.handle_death(src)


	callHook("death", list(src, gibbed))

	if (l_hand) unEquip(l_hand)
	if (r_hand) unEquip(r_hand)
/*
	if (ticker && ticker.mode)

		ticker.mode.check_win()*/

	if (client)
		if (map.gamemode == "Hardcore")
			client.next_normal_respawn = world.realtime+999999
		else
			client.next_normal_respawn = world.realtime + (map ? map.respawn_delay : 3000)
			client << RESPAWN_MESSAGE


	. = ..(gibbed)//,species.death_message)
	if (!gibbed)
		handle_organs()
		if (species.death_sound)
			playsound(loc, species.death_sound, 80, TRUE, TRUE)
	handle_hud_list()

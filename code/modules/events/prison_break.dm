/datum/event/prison_break
	startWhen		= 5
	announceWhen	= 75

	var/releaseWhen = 60
	var/list/area/areas = list()		//List of areas to affect. Filled by start()

	var/eventDept = "Security"			//Department name in announcement
	var/list/areaName = list("Brig")	//Names of areas mentioned in AI and Engineering announcements
	var/list/areaType = list(/area/security/prison, /area/security/brig, /area/security/permabrig, /area/security/permahallway)	//Area types to include.
	var/list/areaNotType = list()		//Area types to specifically exclude.

/datum/event/prison_break/virology
	eventDept = "Medical"
	areaName = list("Virology")
	areaType = list(/area/medical/virology, /area/medical/virology/lab)

/datum/event/prison_break/xenobiology
	eventDept = "Science"
	areaName = list("Xenobiology")
	areaType = list(/area/toxins/xenobiology)
	areaNotType = list(/area/toxins/xenobiology/xenoflora, /area/toxins/xenobiology/xenoflora_storage)

/datum/event/prison_break/station
	eventDept = "Station"
	areaName = list("Brig","Virology","Xenobiology")
	areaType = list(/area/security/prison, /area/security/brig, /area/security/permabrig,  /area/security/permahallway, /area/medical/virology, /area/medical/virology/lab, /area/toxins/xenobiology)
	areaNotType = list(/area/toxins/xenobiology/xenoflora, /area/toxins/xenobiology/xenoflora_storage)


/datum/event/prison_break/setup()
	announceWhen = rand(75, 105)
	releaseWhen = rand(60, 90)

	src.endWhen = src.releaseWhen+2


/datum/event/prison_break/announce(false_alarm)
	if(length(areas) || false_alarm)
		GLOB.event_announcement.Announce("[pick("Вирус `Gr3y.T1d3`","Вредоносный троян")] обнаружен в подсистеме [(eventDept == "Security")? "заключения":"безопасности"] на [station_name()]. Немедленно обеспечьте безопасность всех затронутых отсеков. Рекомендуется участие ИИ станции.", "АВАРИЙНОЕ Оповещение [eventDept].")

/datum/event/prison_break/start()
	for(var/area/A as anything in GLOB.areas)
		if(is_type_in_list(A,areaType) && !is_type_in_list(A,areaNotType))
			areas += A

	if(areas && areas.len > 0)
		var/my_department = "[station_name()] firewall subroutines"
		var/rc_message = "An unknown malicious program has been detected in the [english_list(areaName)] lighting and airlock control systems at [station_time_timestamp()]. Systems will be fully compromised within approximately three minutes. Direct intervention is required immediately.<br>"
		for(var/obj/machinery/message_server/MS in GLOB.machines)
			MS.send_rc_message("Engineering", my_department, rc_message, "", "", 2)
		for(var/mob/living/silicon/ai/A in GLOB.player_list)
			to_chat(A, "<span class='danger'>Malicious program detected in the [english_list(areaName)] lighting and airlock control systems by [my_department].</span>")

	else
		log_runtime("Could not initate grey-tide. Unable to find suitable containment area.", src)
		kill()

/datum/event/prison_break/tick()
	if(activeFor == releaseWhen)
		if(areas && areas.len > 0)
			for(var/area/A in areas)
				for(var/obj/machinery/light/L in A.lights_cache)
					L.flicker(10)

/datum/event/prison_break/end()
	for(var/area/A in shuffle(areas))
		A.prison_break()

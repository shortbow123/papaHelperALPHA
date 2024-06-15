extends Control


# 1/1/2025 : 1735718400
# 31622400 366 days
#const papaEpoch = 1718607600 # 6/17/2024
const papaEpoch = 1717398000 # 6/3/2024 
const periodLength = 2419200
const biWeekly = 1209600 #2 seconds before midnight 2 weeks from before
const weekly = biWeekly / 2


var periods2024 = {
	1: 1704139200,
	2: 1706515200,
	3: 1708329600,
	4: 1710745200,
	5: 1713769200,
	6: 1716188400,
	
	7: 1718607600,
	8: 1720422000,
	9: 1723446000,
	10: 1725260400,
	11: 1727679600,
	12: 1730098800,
}
var alphabet = ['A', 'B', 'C', 'D','E','F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
var numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
var versionInfo = "Alpha "
var revisionNumber = "0.4.1 "
var revisionType = " " # A=Android I=IOS D=Debug
var popupFor = ""
var entries = []
var sortedEntries = []
var loadedSave
var currentPeriod = 0
var clearSave = false
var whichEntrySelected = 0
var whichUUIDSelected = null
var selectedPayView = "biweekly"
var payStart = 1718607600
var payInterval = 0
var random = RandomNumberGenerator.new()

func setSelectedPayStart(whichInterval):
	selectedPayView = whichInterval
	if selectedPayView == "biweekly":
		$canvas/popup/reviewView/biweekly.disabled = true
		$canvas/popup/reviewView/weekly.disabled = false
	elif selectedPayView == "weekly":
		$canvas/popup/reviewView/biweekly.disabled = false
		$canvas/popup/reviewView/weekly.disabled = true
	var currentPayWeek = papaEpoch
	if whichInterval == "biweekly":
		payInterval = biWeekly
	elif whichInterval == "weekly":
		payInterval = weekly
	while true:
		if returnTime() > currentPayWeek and returnTime() < currentPayWeek + payInterval:
			payStart = currentPayWeek
			break
		else:
			currentPayWeek += payInterval
	print(payStart)

func changePayStart(increase):
	if increase:
		payStart += payInterval
	else:
		payStart -= payInterval
	$canvas/popup/reviewView/dates.text = str(unixToHumanTime(payStart)) + " to " + str(unixToHumanTime(payStart + payInterval))
	reviewData()

func returnSortedDates():
	sortedEntries = []
	if selectedPayView == "biweekly":
		for entry in entries:
			print(entry["date"])
			print(payStart)
			print(payStart + biWeekly)
			if entry["date"] > payStart and entry["date"] < payStart + biWeekly:
				sortedEntries.append(entry)
	elif selectedPayView == "weekly":
		for entry in entries:
			if entry["date"] > payStart and entry["date"] < payStart + weekly:
				sortedEntries.append(entry)

func setPayCycleText():
	$canvas/popup/reviewView/dates.text = unixToHumanTime(payStart) + " - " + unixToHumanTime(payStart + payInterval)

func unixToHumanTime(unixTime):
	return(Time.get_date_dict_from_unix_time(unixTime))

func saveData():
	var saveLocation = "user://papaFile.save"
	var save_dict = {
		"saveVersion" : 2,
		"clearSave": clearSave,
		"savedEntries": entries
	}
	print(saveLocation)
	var save_game = File.new()
	save_game.open(saveLocation, File.WRITE)
	save_game.store_line(to_json(save_dict))
	save_game.close()

func loadData():
	var save_game = File.new()
	var saveLocation = "user://papaFile.save"
	print(saveLocation)
	if not save_game.file_exists(saveLocation):
		saveData()
	save_game.open(saveLocation, File.READ)
	loadedSave = parse_json(save_game.get_line())
	save_game.close()
	if loadedSave["saveVersion"] == 1: #Erases any version 1 data
		print("----------------")
		print("CLEARING ALL DATA")
		print("----------------")
		entries = [] 
		saveData()
	loadVariables()

func loadVariables(): 
	entries = loadedSave["savedEntries"]

func _ready():
	if clearSave:  #this works bc there is no data loaded to the variables so i call it to save and it overwrites data
		print("----------------") #in the save file, if clear save is not true it loads the data like normal
		print("CLEARING ALL DATA") #might have it backup data before saving but that is a problem for future me
		print("----------------")
		saveData()
	else:
		loadData()
	$canvas/homeScreen/version.text = str(versionInfo + revisionNumber + revisionType)
	random.randomize()
	#setCurrentPeriod()
	setSelectedPayStart("biweekly")
	returnSortedDates()
	setScreen("homeScreen")

func returnTime():
	return(Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system()))

func setScreen(screenToShow):
	for screen in get_tree().get_nodes_in_group("screen"):
		screen.visible = false
		if screen.name == screenToShow:
			screen.visible = true

func popupConfirm(pressed):
	if popupFor == "recordHours":
		if pressed:
			recordData("hours", $canvas/popup/recordHours/select.value)
		endPopup()
	elif popupFor == "recordTravel":
		if pressed:
			recordData("travel", $canvas/popup/recordHours/select.value)
		endPopup()
	elif popupFor == "editHours":
		var whichHours = ""
		if not entries[whichEntrySelected]["hoursWorked"] == 0:
			whichHours = "hoursWorked"
		else:
			whichHours = "travelHours"
		if pressed:
			entries[whichEntrySelected][whichHours] = $canvas/popup/recordHours/select.value
			saveData()
		reviewData()
		endPopup()
	elif popupFor == "deleteHours":
		if pressed:
			sortedEntries.remove(whichEntrySelected)
			print(len(entries))
			for i in len(entries):
				if entries[i]["UUID"] == whichUUIDSelected:
					entries.remove(i)
					saveData()
		reviewData()
		endPopup()

func endPopup():
	popupFor = ""
	$canvas/popup.visible = false
	$canvas/popup/recordHours.visible = false

func popupControl(whatPopup):
	$canvas/popup.popup()
	$canvas/popup/recordHours.visible = true
	$canvas/popup/recordHours/select.value
	$canvas/popup/recordHours/select.visible = true
	$canvas/popup/reviewView.visible = false
	if whatPopup == "recordHours":
		$canvas/popup.window_title = "Record hours"
		$canvas/popup/header.text = "Enter hours worked today:"
		popupFor = "recordHours"
	elif whatPopup == "recordTravel":
		$canvas/popup.window_title = "Record travel hours"
		$canvas/popup/header.text = "Enter hours traveled today:"
		popupFor = "recordTravel"
	elif whatPopup == "editHours":
		$canvas/popup.window_title = "Edit hours"
		$canvas/popup/header.text = "Edit hours"
		popupFor = "editHours"
	elif whatPopup == "deleteHours":
		$canvas/popup.window_title = "Delete Hours"
		$canvas/popup/header.text = "Remove timeclock record?"
		popupFor = "deleteHours"
		$canvas/popup/recordHours/select.visible = false
	elif whatPopup == "changeView":
		$canvas/popup.window_title = "Change view"
		$canvas/popup/header.text = "Select pay increment?"
		popupFor = "changeView"
		$canvas/popup/reviewView.visible = true
		$canvas/popup/recordHours.visible = false
	else:
		print("WRONG popupControl USAGE ", whatPopup)
	

func recordData(recordWhat, value):
	var newEntry = {
		"UUID": 0,
		"hoursWorked": 0,
		"insideTips": 0,
		"driverTips": 0,
		"travelHours": 0,
		"editTime": 0,
		"date": 0,
		"period": 0,
		"store": 0,
		"RV1" : null,
		"RV2" : null,
		"RV3" : null,
		"RV4" : null
	}
	newEntry["UUID"] = randomUUID()
	if recordWhat == "hours":
		newEntry["editTime"] = returnTime()
		newEntry["date"] = returnTime()
		newEntry["hoursWorked"] = $canvas/popup/recordHours/select.value
		newEntry["period"] = currentPeriod
	elif recordWhat == "travel":
		newEntry["editTime"] = returnTime()
		newEntry["date"] = returnTime()
		newEntry["travelHours"] = $canvas/popup/recordHours/select.value
		newEntry["period"] = currentPeriod
	if $canvas/popup/recordHours/select.value > 0:
		entries.append(newEntry)
	print(entries)
	saveData()

func randomUUID():
	var tempRandom = 0
	var uuidString = ""
	for i in range(11):
		tempRandom = random.randi_range(0, 1)
		if tempRandom == 0:
			uuidString += str(alphabet[random.randi_range(0, 25)])
		else:
			uuidString += str(random.randi_range(0, 9))
	return(uuidString)

func setCurrentPeriod(): #probably can remove
	var periodR = 1
	var tempEpoch = papaEpoch
	var currentEpoch = returnTime()
	while true:
		if periods2024[periodR] < currentEpoch and periods2024[periodR + 1] >= currentEpoch: 
			currentPeriod = periodR
			print(currentPeriod)
			break
		else:
			periodR += 1

func reviewData():
	var totalHours = 0
	returnSortedDates()
	for i in range($canvas/reviewData/list.get_item_count()):
		$canvas/reviewData/list.remove_item(0)
	for entry in sortedEntries:
		if entry["hoursWorked"] > 0:
			$canvas/reviewData/list.add_item((Time.get_date_string_from_unix_time(entry["date"]) + " - Work Hours: " + str(entry["hoursWorked"])))
			totalHours += entry["hoursWorked"]
		elif entry["hoursWorked"] == 0:
			$canvas/reviewData/list.add_item((Time.get_date_string_from_unix_time(entry["date"]) + " - Travel Hours: " + str(entry["travelHours"])))
			totalHours += entry["travelHours"]
	$canvas/reviewData/totalbg/total.text = "Total Hours: " + str(totalHours)

func reviseData(function):
	if function == "edit":
		popupControl("editHours")
		$canvas/popup/recordHours/select.value
	elif function == "delete":
		popupControl("deleteHours")

func selectEntryToEdit(index):
	toggleEditButtons(true)
	whichUUIDSelected = sortedEntries[index]["UUID"]
	whichEntrySelected = index
	
func toggleEditButtons(enable):
	if enable:
		$canvas/reviewData/controlbg/edit.disabled = false
		$canvas/reviewData/controlbg/delete.disabled = false
	else:
		$canvas/reviewData/controlbg/edit.disabled = true
		$canvas/reviewData/controlbg/delete.disabled = true

func _on_home_pressed(): 
	setScreen("homeScreen")

func _on_settings_pressed():
	setScreen("settingsScreen")

func _on_tools_pressed():
	setScreen("toolsScreen")

func _on_recordHours_pressed():
	popupControl("recordHours")

func _on_confirm_pressed():
	popupConfirm(true)

func _on_cancel_pressed():
	popupConfirm(false)

func _on_review_pressed():
	setScreen("reviewData")
	reviewData()

func _on_list_item_selected(index):
	selectEntryToEdit(index)

func _on_list_nothing_selected():
	whichEntrySelected = null
	toggleEditButtons(false)

func _on_edit_pressed():
	reviseData("edit")

func _on_delete_pressed():
	reviseData("delete")

func _on_recordTravel_pressed():
	popupControl("recordTravel")

func _on_biweekly_pressed():
	setSelectedPayStart("biweekly")

func _on_weekly_pressed():
	setSelectedPayStart("weekly")

func _on_back_pressed():
	changePayStart(false)

func _on_forward_pressed():
	changePayStart(true)

func _on_changeView_pressed():
	popupControl("changeView")

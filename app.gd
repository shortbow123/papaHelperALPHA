extends Control


const papaEpoch = 1704139200
const periodLength = 2419200

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
var versionInfo = "Alpha "
var revisionNumber = "0.1.5 "
var revisionType = "A " # A=Android I=IOS D=Debug
var popupFor = ""
var entries = []
var loadedSave
var currentPeriod = 0
var clearSave = false
var dummyEntry = {
	"hoursWorked": 0,
	"insideTips": 0,
	"driverTips": 0,
	"travelHours": 0,
	"editTime": 0,
	"date": 0,
	"period": 0
}
# datecode is how many days since jan 1st 2024
# dummy entry
# [hoursworked, insidetips, drivertips, hours driven]

func selectSave():
	var whichSave
	var save_game = File.new()
	save_game.open("user://runSave.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		whichSave = int(save_game.get_line())
	save_game.close()

func saveData():
	var saveLocation = "user://papaFile.save"
	var save_dict = {
		"saveVersion" : 1,
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
	loadVariables()

func loadVariables(): 
	entries = loadedSave["savedEntries"]

func _ready():
	$homeScreen/version.text = str(versionInfo + revisionNumber + revisionType)
	setCurrentPeriod()
	setScreen("homeScreen")
	if clearSave:
		print("----------------")
		print("CLEARING SAVE")
		print("----------------")
		saveData()
	else:
		loadData()
	

func returnEpoch():
	return(Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system()))


func setScreen(screenToShow):
	for screen in get_tree().get_nodes_in_group("screen"):
		screen.visible = false
		if screen.name == screenToShow:
			screen.visible = true

func popupConfirm(pressed):
	if popupFor == "recordHours":
		if pressed:
			recordData("hours", $popup/recordHours/select.value)
		else:
			pass
		popupFor = ""
		$popup.visible = false
		$popup/recordHours.visible = false

func popupControl(whatPopup):
	$popup.popup()
	if whatPopup == "recordHours":
		$popup.window_title = "Record hours"
		$popup/header.text = "Enter hours worked today:"
		popupFor = "recordHours"
		$popup/recordHours.visible = true

func recordData(recordWhat, value):
	var newEntry = {
		"hoursWorked": 0,
		"insideTips": 0,
		"driverTips": 0,
		"travelHours": 0,
		"editTime": 0,
		"date": 0,
		"period": 0
	}
	if recordWhat == "hours":
		newEntry["editTime"] = returnEpoch()
		newEntry["date"] = returnEpoch()
		newEntry["hoursWorked"] = $popup/recordHours/select.value
		newEntry["period"] = currentPeriod
	entries.append(newEntry)
	print(entries)
	saveData()

func setCurrentPeriod():
	var periodR = 1
	var tempEpoch = papaEpoch
	var currentEpoch = returnEpoch()
	while true:
		if periods2024[periodR] < currentEpoch and periods2024[periodR + 1] >= currentEpoch: 
			currentPeriod = periodR
			break
		else:
			print(currentEpoch)
			print(periods2024[periodR])
			periodR += 1

func reviewData():
	var totalHours = 0
	#var testt = Time.get_date_string_from_unix_time(entry["date"]) + ": " + str(entry["hoursWorked"])
	for i in range($reviewData/list.get_item_count()):
		$reviewData/list.remove_item(0)
	for entry in entries:
		$reviewData/list.add_item((Time.get_date_string_from_unix_time(entry["date"]) + ": " + str(entry["hoursWorked"])))
		totalHours += entry["hoursWorked"]
		#var newas = (testt(entry["date"]))
		# + ": " + str(entry[hoursWorked])))
	$reviewData/totalbg/total.text = "Total Hours: " + str(totalHours)

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

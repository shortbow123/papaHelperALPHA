extends Control

var versionInfo = "Alpha "
var revisionNumber = "0.1.1 "
var revisionType = "D " # A=Android I=IOS D=Debug
var popupFor = ""
var entries = []
var loadedSave
var entry = {
	"hoursWorked": 0,
	"insideTips": 0,
	"driverTips": 0,
	"travelHours": 0,
	"editTime": "",
	"period": 0
}
# dummy entry
# [hoursworked, insidetips, drivertips, hours driven]

func selectSave():
	var whichSave
	var save_game = File.new()
	save_game.open("user://runSave.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		whichSave = int(save_game.get_line())
	save_game.close()

func saveGame():
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

func loadGame():
	var save_game = File.new()
	var saveLocation = "user://papaFile.save"
	print(saveLocation)
	if not save_game.file_exists(saveLocation):
		saveGame()
	save_game.open(saveLocation, File.READ)
	loadedSave = parse_json(save_game.get_line())
	save_game.close()
	loadVariables()

func loadVariables(): 
	entries = loadedSave["savedEntries"]

func _ready():
	$homeScreen/version.text = str(versionInfo + revisionNumber + revisionType)


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
	$homeScreen/popup.popup()
	if whatPopup == "recordHours":
		$homeScreen/popup.window_title = "Record hours"
		$popup/header.text = "Enter hours worked today:"
		popupFor = "recordHours"
		$popup/recordHours.visible = true

func recordData(recordWhat, value):
	if recordWhat == "hours":
		pass

func reviewData():
	pass

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

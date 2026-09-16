extends Node

const SAVE_PATH := "res://Save/savegame.tres"

signal data_capture(data: SaveData)
signal data_dispense(data: SaveData)

func saveGame() -> void:
	var newData := SaveData.new()
	data_capture.emit(newData)
	ResourceSaver.save(newData, SAVE_PATH)
	print('Saved Game')

func loadGame() -> void:
	if not hasSave():
		push_warning('No save file found.')
		return
	var loadedData := ResourceLoader.load(SAVE_PATH) as SaveData
	if loadedData == null:
		push_error('Save file corrupted or invalid.')
		return
	data_dispense.emit(loadedData)
	print('Loaded Game')

func hasSave() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

extends Node

const SAVE_PATH := "res://Save/savegame.tres"

signal data_capture(data: SaveData)
signal data_dispense(data: SaveData)

func saveGame() -> void:
	var newData := SaveData.new()
	data_capture.emit(newData)
	ResourceSaver.save(newData, SAVE_PATH)
	print('Saved Game')

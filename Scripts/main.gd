extends Node2D

@onready var generator := $LevelGenerator
var levels = Levels.LEVELS
var current := 0

func _ready() -> void:
	randomize()
	_load_level(current)

func _input(event):
	#space to gen another level for testingggg
	if event.is_action_pressed("ui_select"):
		current = (current + 1) % levels.size()
		_load_level(current)

func _load_level(idx: int) -> void:
	generator.spawn_level(levels[idx])

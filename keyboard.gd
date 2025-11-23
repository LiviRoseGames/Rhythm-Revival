extends Node

@onready var player: AudioStreamPlayer = $AudioStreamPlayer
@onready var keys_container: HBoxContainer = $HBoxContainer

var note_streams := {
	"A3": preload("res://mp3 Notes/a3.mp3"),
	"A4": preload("res://mp3 Notes/a4.mp3"),
	"A5": preload("res://mp3 Notes/a5.mp3"),
	"A#3": preload("res://mp3 Notes/a-3.mp3"),
	"A#4": preload("res://mp3 Notes/a-4.mp3"),
	"A#5": preload("res://mp3 Notes/a-5.mp3"),
	"B3": preload("res://mp3 Notes/b3.mp3"),
	"B4": preload("res://mp3 Notes/b4.mp3"),
	"B5": preload("res://mp3 Notes/b5.mp3"),
	"C3": preload("res://mp3 Notes/c3.mp3"),
	"C4": preload("res://mp3 Notes/c4.mp3"),
	"C5": preload("res://mp3 Notes/c5.mp3"),
	"C6": preload("res://mp3 Notes/c6.mp3"),
	"C#3": preload("res://mp3 Notes/c-3.mp3"),
	"C#4": preload("res://mp3 Notes/c-4.mp3"),
	"C#5": preload("res://mp3 Notes/c-5.mp3"),
	"D3": preload("res://mp3 Notes/d3.mp3"),
	"D4": preload("res://mp3 Notes/d4.mp3"),
	"D5": preload("res://mp3 Notes/d5.mp3"),
	"D#3": preload("res://mp3 Notes/d-3.mp3"),
 	"D#4": preload("res://mp3 Notes/d-4.mp3"),
	"D#5": preload("res://mp3 Notes/d-5.mp3"),
	"E3": preload("res://mp3 Notes/e3.mp3"),
	"E4": preload("res://mp3 Notes/e4.mp3"),
	"E5": preload("res://mp3 Notes/e5.mp3"),
	"F3": preload("res://mp3 Notes/f3.mp3"),
	"F4": preload("res://mp3 Notes/f4.mp3"),
	"F5": preload("res://mp3 Notes/f5.mp3"),
	"F#3": preload("res://mp3 Notes/f-3.mp3"),
	"F#4": preload("res://mp3 Notes/f-4.mp3"),
	"F#5": preload("res://mp3 Notes/f-5.mp3"),
	"G3": preload("res://mp3 Notes/g3.mp3"),
	"G4": preload("res://mp3 Notes/g4.mp3"),
	"G5": preload("res://mp3 Notes/g5.mp3"),
	"G#3": preload("res://mp3 Notes/g-3.mp3"),
	"G#4": preload("res://mp3 Notes/g-4.mp3"),
	"G#5": preload("res://mp3 Notes/g-5.mp3"),
}

var NOTES := [
	"A3", "A#3", "B3",
	"C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4",
	"A4", "A#4", "B4",
	"C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5",
	"C6"
]

func _ready() -> void:
	create_keyboard_buttons()

func create_keyboard_buttons() -> void:
	for note in NOTES:
		var b := Button.new()
		b.text = note
		b.name = "Button_" + note
		if note.contains("#"):
			b.custom_minimum_size = Vector2(32, 80)
			b.modulate = Color(0.15, 0.15, 0.15)
			b.add_theme_color_override("font_color", Color.WHITE)
		else:
			b.custom_minimum_size = Vector2(48, 120)
		keys_container.add_child(b)
		b.pressed.connect(Callable(self, "_on_note_pressed").bind(note))

func _on_note_pressed(note: String) -> void:
	if note_streams.has(note):
		player.stream = note_streams[note]
		player.play()
	else:
		push_warning("No audio for note: %s" % note)

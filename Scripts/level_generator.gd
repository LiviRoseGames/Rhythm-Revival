extends Node2D

@export_range(1,512,1) var tile_width: int = 500
@export_range(1,512,1) var tile_height: int = 500

var IsoTileScene: PackedScene = preload("res://scenes/iso_tile.tscn")

var floor_textures: Array[Texture2D] = [
	preload("res://Environment/floor_bricks1.png"),
	preload("res://Environment/floor_bricks2.png"),
	preload("res://Environment/floor_bricks3.png"),
	preload("res://Environment/floor_bricks4.png")
]

var wall_textures: Array[Texture2D] = [
	preload("res://Environment/wall_bricks1.png"),
	preload("res://Environment/wall_bricks2.png"),
	preload("res://Environment/wall_bricks3.png"),
	preload("res://Environment/wall_bricks4.png")
]

#spawn a level from dictionary
func spawn_level(level_data: Dictionary) -> void:
	#clear existing
	for child in get_children():
		child.queue_free()

	var w: int = level_data.get("width", 0)
	var h: int = level_data.get("height", 0)
	var layout = level_data.get("layout", [])

	for y in range(h):
		for x in range(w):
			var code: String = layout[y][x]
			var tex := _texture_from_code(code)
			if tex:
				_spawn_iso_tile(tex, x, y)

func _texture_from_code(code: String) -> Texture2D:
	match code:
		"F":
			return floor_textures[randi() % floor_textures.size()]
		"W":
			return wall_textures[randi() % wall_textures.size()]
		_:
			return null

func _spawn_iso_tile(texture: Texture2D, gx: int, gy: int) -> void:
	var tile_node := IsoTileScene.instantiate() as Node2D
	#call setup() to assign textures and underlay
	tile_node.call_deferred("setup", texture, tile_width, tile_height)

	#isometric coordinate conversion
	var sx := (gx - gy) * (tile_width / 2.0)
	var sy := (gx + gy) * (tile_height / 2.0)
	tile_node.position = Vector2(sx, sy)

	#depth / sorting: set z_index by screen Y so tiles overlap correctly
	#the higher 'y' should draw later (larger z_index)
	tile_node.z_index = int(sy)
	add_child(tile_node)

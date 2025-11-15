extends Node2D

var white_texture: Texture2D = null

func setup(texture: Texture2D, tile_w: int, tile_h: int) -> void:
	#clear any existing children
	for c in get_children():
		c.queue_free()

	#brick overlay
	var brick := Sprite2D.new()
	brick.texture = texture
	brick.centered = true
	brick.position = Vector2.ZERO
	add_child(brick)

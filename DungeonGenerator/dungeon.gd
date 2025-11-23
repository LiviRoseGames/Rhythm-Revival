extends Node2D

@export var tilemap: TileMap
@export var WIDTH: int = 80
@export var HEIGHT: int = 60
@export var MAX_ROOMS: int = 10
@export var MIN_ROOM_SIZE: int = 5
@export var MAX_ROOM_SIZE: int = 10
@export var TILE_FLOOR: int
@export var TILE_WALL: int
@export var TILE_FILL: int
@export var seed: int = 0

var grid = []
var rooms = []
var rng := RandomNumberGenerator.new()

func _ready():
	if tilemap == null:
		push_error("TileMap not assigned!")
		return
	if seed == 0:
		rng.randomize()
	else:
		rng.seed = seed
	initialize_grid()
	generate_dungeon()
	draw_dungeon()

func initialize_grid():
	grid.clear()
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(1)

func generate_dungeon():
	rooms.clear()
	for i in range(MAX_ROOMS):
		var room = generate_room()
		if place_room(room):
			if rooms.size() > 0:
				connect_rooms(rooms[-1], room)
			rooms.append(room)

func generate_room():
	var w = rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
	var h = rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
	var x = rng.randi_range(1, WIDTH - w - 1)
	var y = rng.randi_range(1, HEIGHT - h - 1)
	return { "x": x, "y": y, "w": w, "h": h }

func place_room(room) -> bool:
	for x in range(room.x, room.x + room.w):
		for y in range(room.y, room.y + room.h):
			if grid[x][y] == 0:
				return false
	for x in range(room.x, room.x + room.w):
		for y in range(room.y, room.y + room.h):
			grid[x][y] = 0
	return true

func connect_rooms(room1, room2):
	var start = Vector2(int(room1.x + room1.w / 2), int(room1.y + room1.h / 2))
	var end = Vector2(int(room2.x + room2.w / 2), int(room2.y + room2.h / 2))
	var current = start
	while current.x != end.x:
		current.x += 1 if end.x > current.x else -1
		grid[current.x][current.y] = 0
	while current.y != end.y:
		current.y += 1 if end.y > current.y else -1
		grid[current.x][current.y] = 0

func draw_dungeon():
	tilemap.clear()
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_id = TILE_FLOOR if grid[x][y] == 0 else TILE_FILL
			tilemap.set_cell(0, Vector2i(x, y), tile_id)
	paint_walls_around_floors()

func paint_walls_around_floors():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			if grid[x][y] == 1:
				for dx in [-1,0,1]:
					for dy in [-1,0,1]:
						if dx==0 and dy==0:
							continue
						var nx = x+dx
						var ny = y+dy
						if nx>=0 and nx<WIDTH and ny>=0 and ny<HEIGHT:
							if grid[nx][ny] == 0:
								tilemap.set_cell(0, Vector2i(x, y), TILE_WALL)
								break

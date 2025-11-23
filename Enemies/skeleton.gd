extends CharacterBody2D

@export var walk_speed: float = 60.0
@export var chase_speed: float = 120.0
@export var wander_time_min: float = 1.0
@export var wander_time_max: float = 2.5
@export var idle_time_min: float = 0.5
@export var idle_time_max: float = 1.5

var state: String = "wander"  # "wander", "idle", "chase"
var state_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var player: Node = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea


func _ready() -> void:
	detection_area.connect("body_entered", Callable(self, "_on_player_entered"))
	detection_area.connect("body_exited", Callable(self, "_on_player_exited"))
	_enter_wander_state()


func _physics_process(delta: float) -> void:
	match state:
		"wander":
			handle_wander(delta)
		"idle":
			handle_idle(delta)
		"chase":
			handle_chase(delta)

	move_and_slide()

	# Check collision with player
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		if col.get_collider() and col.get_collider().name == "Player":
			_on_player_collision(col.get_collider())


# ======================================================
# ================   WANDER BEHAVIOR   =================
# ======================================================
func handle_wander(delta: float) -> void:
	state_timer -= delta

	velocity = wander_direction * walk_speed
	play_animation("Walk")

	update_flip()

	if state_timer <= 0:
		_enter_idle_state()


func _enter_wander_state() -> void:
	state = "wander"
	wander_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	state_timer = randf_range(wander_time_min, wander_time_max)


# ======================================================
# =================    IDLE BEHAVIOR    ================
# ======================================================
func handle_idle(delta: float) -> void:
	velocity = Vector2.ZERO
	play_animation("Idle")

	state_timer -= delta
	if state_timer <= 0:
		_enter_wander_state()


func _enter_idle_state() -> void:
	state = "idle"
	state_timer = randf_range(idle_time_min, idle_time_max)


# ======================================================
# ==================   CHASE PLAYER   ==================
# ======================================================
func handle_chase(delta: float) -> void:
	if player == null:
		_enter_wander_state()
		return

	var dir_to_player: Vector2 = (player.global_position - global_position).normalized()

	velocity = dir_to_player * chase_speed
	play_animation("Walk")
	update_flip(dir_to_player.x)


# ======================================================
# ================     DETECTION AREA    ===============
# ======================================================
func _on_player_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		state = "chase"


func _on_player_exited(body: Node) -> void:
	if body == player:
		player = null
		_enter_idle_state()


# ======================================================
# =============   COLLISION WITH PLAYER   ==============
# ======================================================
func _on_player_collision(player: Node) -> void:
	print("Enemy touched player! (Battle will start here.)")
	# Later:
	# get_tree().change_scene("res://BattleScene.tscn")


# ======================================================
# ================     ANIMATION PLAY    ===============
# ======================================================
func play_animation(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)


# ======================================================
# =================   SPRITE FLIPPING   ================
# ======================================================
func update_flip(x_dir := wander_direction.x) -> void:
	if x_dir < -0.1:
		anim.flip_h = true
	elif x_dir > 0.1:
		anim.flip_h = false

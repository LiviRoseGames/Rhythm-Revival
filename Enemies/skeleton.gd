extends CharacterBody2D

@export var walk_speed: float = 60.0
@export var chase_speed: float = 120.0
@export var idle_time_min: float = 0.5
@export var idle_time_max: float = 1.5
@export var wander_time_min: float = 1.0
@export var wander_time_max: float = 2.5
@export var attack_range: float = 32.0
@export var attack_damage: int = 1
@export var attack_cooldown: float = 1.0

var state: String = "wander"
var state_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var player: Node = null
var attack_timer: float = 0.0
var is_attacking: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox_area: Area2D = $AnimatedSprite2D/Hitbox
@onready var hitbox_shape: CollisionShape2D = $AnimatedSprite2D/Hitbox/CollisionShape2D

func _ready() -> void:
	detection_area.connect("body_entered", Callable(self, "_on_player_entered"))
	detection_area.connect("body_exited", Callable(self, "_on_player_exited"))
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))
	hitbox_area.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))
	hitbox_shape.disabled = true
	_enter_wander_state()

func _physics_process(delta: float) -> void:
	if attack_timer > 0:
		attack_timer -= delta
	if not is_attacking:
		match state:
			"wander":
				handle_wander(delta)
			"idle":
				handle_idle(delta)
			"chase":
				handle_chase(delta)
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	if player and not is_attacking:
		var dist = global_position.distance_to(player.global_position)
		if dist <= attack_range and attack_timer <= 0:
			attack_player()

func attack_player() -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	var attack_anim: String = ["Attack1", "Attack2"].pick_random()
	play_animation(attack_anim)
	hitbox_shape.disabled = false

func _on_hitbox_body_entered(body: Node) -> void:
	if body.name == "Player" and is_attacking:
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)

func _on_animation_finished() -> void:
	if anim.animation in ["Attack1", "Attack2"]:
		is_attacking = false
		hitbox_shape.disabled = true

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

func handle_idle(delta: float) -> void:
	velocity = Vector2.ZERO
	play_animation("Idle")
	state_timer -= delta
	if state_timer <= 0:
		_enter_wander_state()

func _enter_idle_state() -> void:
	state = "idle"
	state_timer = randf_range(idle_time_min, idle_time_max)

func handle_chase(delta: float) -> void:
	if player == null:
		_enter_wander_state()
		return
	var dir_to_player: Vector2 = (player.global_position - global_position).normalized()
	velocity = dir_to_player * chase_speed
	play_animation("Walk")
	update_flip(dir_to_player.x)

func _on_player_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		state = "chase"

func _on_player_exited(body: Node) -> void:
	if body == player:
		player = null
		_enter_idle_state()

func play_animation(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)

func update_flip(x_dir := wander_direction.x) -> void:
	if x_dir < -0.1:
		anim.flip_h = true
	elif x_dir > 0.1:
		anim.flip_h = false

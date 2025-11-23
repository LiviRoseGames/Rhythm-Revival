extends CharacterBody2D

@export var move_speed: float = 150.0
@export var dash_distance: float = 200.0
@export var dash_cooldown: float = 0.35

var is_dashing := false
var dash_cd_timer := 0.0
var dash_direction := Vector2.ZERO
var last_direction := Vector2.DOWN
var last_vertical := "Down"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	# Update cooldown
	if dash_cd_timer > 0:
		dash_cd_timer -= delta

	var input_vec := get_input()

	# -------------------------
	# DASH HANDLING
	# -------------------------
	if is_dashing:
		# Burst → smooth transition to walk
		var dash_peak_speed: float = dash_distance / 0.18  # peak dash speed over 0.18 sec
		var current_speed: float = lerp(dash_peak_speed, move_speed, anim.frame / float(anim.sprite_frames.get_frame_count(anim.animation)))

		velocity = dash_direction * current_speed
		move_and_slide()

		# Double animation speed during dash
		anim.speed_scale = 2.0
		return  # skip normal movement while dashing

	# -------------------------
	# NORMAL MOVEMENT
	# -------------------------
	if input_vec != Vector2.ZERO:
		last_direction = input_vec

		# Track vertical preference for left/right
		if input_vec.y < -0.2:
			last_vertical = "Up"
		elif input_vec.y > 0.2:
			last_vertical = "Down"

	velocity = input_vec * move_speed
	move_and_slide()

	# Start dash
	if Input.is_action_just_pressed("dash") and dash_cd_timer <= 0:
		start_dash()

	update_animation(input_vec)


# -------- INPUT --------
func get_input() -> Vector2:
	var v := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	return v.normalized()


# -------- LEAP DASH --------
func start_dash() -> void:
	is_dashing = true
	dash_cd_timer = dash_cooldown

	# Use the current input direction; if none, fall back to down
	var input_vec := get_input()
	dash_direction = input_vec
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.DOWN
	else:
		dash_direction = dash_direction.normalized()

	# Choose the dash animation based on direction
	var dir_suffix := get_direction_suffix(dash_direction)
	var anim_name := "Dash_" + dir_suffix

	# Play dash animation once at double speed
	anim.speed_scale = 2.0
	anim.play(anim_name)
	anim.frame = 0


# -------- ANIMATION FINISHED HANDLER --------
func _on_animation_finished() -> void:
	if anim.animation.begins_with("Dash_"):
		is_dashing = false
		anim.speed_scale = 1.0  # restore normal animation speed


# -------- ANIMATIONS --------
func update_animation(input_vec: Vector2) -> void:
	if is_dashing:
		return  # dash anim must play fully

	var suffix := get_direction_suffix(last_direction)
	var state := ""
	if input_vec == Vector2.ZERO:
		state = "Idle_" + suffix
	else:
		state = "Walk_" + suffix

	if anim.animation != state:
		anim.play(state)


# -------- DIRECTION RESOLVER WITH VERTICAL MEMORY --------
func get_direction_suffix(v: Vector2) -> String:
	var dx = v.x
	var dy = v.y

	if dy < -0.2:
		return "Up"
	if dy > 0.2:
		return "Down"

	if dx < -0.2:
		return "Left_" + last_vertical
	if dx > 0.2:
		return "Right_" + last_vertical

	# fallback when idle
	if abs(last_direction.y) > abs(last_direction.x):
		return last_vertical
	elif last_direction.x < 0:
		return "Left_" + last_vertical
	elif last_direction.x > 0:
		return "Right_" + last_vertical

	return last_vertical

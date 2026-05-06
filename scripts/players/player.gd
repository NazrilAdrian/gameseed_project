extends CharacterBody2D

@export var walk_speed: float = 150.0
@export var run_multiplier: float = 1.8
@export var jump_height: float = 24.0
@export var jump_duration: float = 0.45

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing_direction: String = "down"
var is_jumping: bool = false
var jump_timer: float = 0.0
var sprite_base_position: Vector2

func _ready() -> void:
	add_to_group("Player")
	sprite_base_position = animated_sprite.position
	_play_animation("idle_down")

func _physics_process(delta: float) -> void:
	var move_input := _get_move_input()
	var is_moving := move_input.length() > 0.0
	var is_running := _is_run_pressed()

	if is_moving:
		facing_direction = _direction_from_vector(move_input)
		var speed := walk_speed * (run_multiplier if is_running else 1.0)
		velocity = move_input.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	_handle_jump(delta)
	_try_start_jump()
	_update_animation(is_moving, is_running)

func _get_move_input() -> Vector2:
	return Vector2(
		_get_axis("move_left", "ui_left", "move_right", "ui_right"),
		_get_axis("move_up", "ui_up", "move_down", "ui_down")
	)

func _get_axis(neg_action: String, neg_fallback: String, pos_action: String, pos_fallback: String) -> float:
	var neg := _action_strength(neg_action, neg_fallback)
	var pos := _action_strength(pos_action, pos_fallback)
	return pos - neg

func _action_strength(primary: String, fallback: String) -> float:
	if InputMap.has_action(primary):
		return Input.get_action_strength(primary)
	if InputMap.has_action(fallback):
		return Input.get_action_strength(fallback)
	return 0.0

func _is_run_pressed() -> bool:
	return _is_action_pressed("run", "sprint")

func _is_jump_just_pressed() -> bool:
	return _is_action_just_pressed("jump", "ui_accept")

func _is_action_pressed(primary: String, fallback: String) -> bool:
	if InputMap.has_action(primary):
		return Input.is_action_pressed(primary)
	if InputMap.has_action(fallback):
		return Input.is_action_pressed(fallback)
	return false

func _is_action_just_pressed(primary: String, fallback: String) -> bool:
	if InputMap.has_action(primary):
		return Input.is_action_just_pressed(primary)
	if InputMap.has_action(fallback):
		return Input.is_action_just_pressed(fallback)
	return false

func _try_start_jump() -> void:
	if is_jumping:
		return
	if _is_jump_just_pressed():
		is_jumping = true
		jump_timer = 0.0

func _handle_jump(delta: float) -> void:
	if not is_jumping:
		animated_sprite.position = sprite_base_position
		return

	jump_timer += delta
	var t: float = clampf(jump_timer / jump_duration, 0.0, 1.0)
	var jump_offset: float = -4.0 * jump_height * t * (1.0 - t)
	animated_sprite.position = sprite_base_position + Vector2(0.0, jump_offset)

	if t >= 1.0:
		is_jumping = false
		animated_sprite.position = sprite_base_position

func _update_animation(is_moving: bool, is_running: bool) -> void:
	var state := "idle"
	if is_moving and is_running:
		state = "run"
	elif is_moving:
		state = "run"

	var animation_name := "%s_%s" % [state, facing_direction]
	_play_animation(animation_name)

func _play_animation(animation_name: String) -> void:
	if animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		return
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)

func _direction_from_vector(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

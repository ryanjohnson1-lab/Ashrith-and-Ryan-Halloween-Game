extends CharacterBody2D

@export var move_speed: float = 420.0
@export var bolt_scene: PackedScene
@export var bolt_color: Color = Color(0.55, 1.0, 0.35, 1.0)
@export var player_texture: Texture2D

var can_shoot := true
var screen_size := Vector2.ZERO
var damage_ready := true
var animation_clock := 0.0

@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $Muzzle

func _ready() -> void:
	screen_size = get_viewport_rect().size
	if player_texture:
		$Sprite2D.texture = player_texture
		$Sprite2D.hframes = 4
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _physics_process(delta: float) -> void:
	animation_clock += delta
	$Sprite2D.frame = int(animation_clock * 8.0) % 4
	var direction := Input.get_axis("move_up", "move_down")
	velocity = Vector2(0.0, direction * move_speed)
	move_and_slide()
	position.x = 105.0
	position.y = clampf(position.y, 48.0, screen_size.y - 48.0)
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot() -> void:
	if bolt_scene == null:
		return
	can_shoot = false
	shoot_timer.start()
	var bolt := bolt_scene.instantiate() as Area2D
	bolt.global_position = muzzle.global_position
	bolt.set("bolt_color", bolt_color)
	bolt.set("travel_direction", Vector2.RIGHT)
	get_tree().current_scene.add_child(bolt)

func set_analog_axis(axis_value: float, deadzone: float = 0.18) -> void:
	var bounded := clampf(axis_value, -1.0, 1.0)
	Input.action_release("move_up")
	Input.action_release("move_down")
	if bounded < -deadzone:
		Input.action_press("move_up", absf(bounded))
	elif bounded > deadzone:
		Input.action_press("move_down", bounded)

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func take_damage() -> void:
	if not damage_ready:
		return
	damage_ready = false
	get_tree().current_scene.lose_life()
	await get_tree().create_timer(0.9).timeout
	damage_ready = true


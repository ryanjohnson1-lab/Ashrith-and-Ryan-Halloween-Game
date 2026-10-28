extends Area2D
class_name EnemyBase

signal enemy_destroyed(score_value: int)
signal player_hit

@export var fall_speed: float = 120.0 # Horizontal travel speed.
@export var score_value: int = 10
@export var health: int = 1
@export var enemy_kind: StringName = &"pumpkin"
@export var attack_texture: Texture2D
@export var projectile_scene: PackedScene
@export var attack_interval: float = 2.0

var is_destroyed := false
var attack_clock := 0.8
var animation_clock := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	body_entered.connect(_on_body_entered)
	var sprite: Sprite2D = $Sprite2D
	if sprite.texture:
		sprite.hframes = 2

func _process(delta: float) -> void:
	if is_destroyed:
		return
	animation_clock += delta
	attack_clock += delta
	position.x -= fall_speed * delta
	$Sprite2D.frame = int(animation_clock * 4.0) % 2
	if attack_clock >= attack_interval:
		attack_clock = 0.0
		attack()
	if position.x <= -48.0:
		is_destroyed = true
		player_hit.emit()
		queue_free()

func attack() -> void:
	if projectile_scene == null or attack_texture == null:
		return
	if enemy_kind == &"candy":
		for angle in [-0.28, 0.0, 0.28]:
			spawn_projectile(Vector2.LEFT.rotated(angle), false, true)
	elif enemy_kind == &"ghost":
		spawn_projectile(Vector2.LEFT, true)
	else:
		spawn_projectile(Vector2.LEFT, false)

func spawn_projectile(direction: Vector2, wiggle: bool, face_direction: bool = false) -> void:
	var shot := projectile_scene.instantiate() as Area2D
	shot.set("travel_direction", direction)
	shot.set("projectile_texture", attack_texture)
	shot.set("wiggle", wiggle)
	shot.set("face_direction", face_direction)
	shot.global_position = global_position + Vector2(-26.0, 0.0)
	get_tree().current_scene.add_child(shot)

func _on_body_entered(body: Node2D) -> void:
	if is_destroyed or not body.is_in_group("player"):
		return
	is_destroyed = true
	player_hit.emit()
	queue_free()

func take_hit() -> void:
	if is_destroyed:
		return
	health -= 1
	if health > 0:
		return
	is_destroyed = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	enemy_destroyed.emit(score_value)
	queue_free()

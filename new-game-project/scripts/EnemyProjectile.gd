extends Area2D

@export var speed: float = 270.0
@export var travel_direction: Vector2 = Vector2.LEFT
@export var projectile_texture: Texture2D
@export var wiggle: bool = false
@export var face_direction: bool = false

var origin_y := 0.0
var forward_distance := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	add_to_group("enemy_projectile")
	$Sprite2D.texture = projectile_texture
	if face_direction:
		$Sprite2D.rotation = travel_direction.angle() + PI
	origin_y = global_position.y

func _physics_process(delta: float) -> void:
	var step := travel_direction.normalized() * speed * delta
	global_position += step
	forward_distance += step.length()
	if wiggle:
		global_position.y = origin_y + sin(forward_distance / 28.0) * 28.0
	if not get_viewport_rect().grow(40.0).has_point(global_position):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_projectile"):
		area.queue_free()
		queue_free()
		return
	if area.has_method("take_hit"):
		area.take_hit()
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		queue_free()

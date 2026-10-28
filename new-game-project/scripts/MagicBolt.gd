extends Area2D

@export var speed: float = 680.0
@export var bolt_color: Color = Color(0.55, 1.0, 0.35, 1.0)
@export var travel_direction: Vector2 = Vector2.UP
@export var bolt_texture: Texture2D = preload("res://assets/AttackSprite_strip4.png")

var animation_clock := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	area_entered.connect(_on_area_entered)
	add_to_group("player_projectile")
	$Sprite2D.texture = bolt_texture
	$Sprite2D.hframes = 4

func _physics_process(delta: float) -> void:
	animation_clock += delta
	$Sprite2D.frame = int(animation_clock * 12.0) % 4
	global_position += travel_direction.normalized() * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_projectile"):
		area.queue_free()
		queue_free()
		return
	if area.has_method("take_hit"):
		area.take_hit()
		queue_free()

func _on_screen_exited() -> void:
	queue_free()
	
func _process(_delta: float) -> void:
	var bounds := get_viewport_rect().grow(48.0)
	if not bounds.has_point(global_position):
		queue_free()


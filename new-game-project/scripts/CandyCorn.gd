extends EnemyBase

func _ready() -> void:
	enemy_kind = &"candy"
	score_value = 15
	attack_interval = 3.2
	attack_texture = preload("res://assets/CandyCornAttackSprite.png")
	projectile_scene = preload("res://scenes/EnemyProjectile.tscn")
	super._ready()

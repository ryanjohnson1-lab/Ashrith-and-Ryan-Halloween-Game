extends EnemyBase

func _ready() -> void:
	enemy_kind = &"ghost"
	score_value = 20
	attack_interval = 3.4
	attack_texture = preload("res://assets/GhostAttackSprite.png")
	projectile_scene = preload("res://scenes/EnemyProjectile.tscn")
	super._ready()

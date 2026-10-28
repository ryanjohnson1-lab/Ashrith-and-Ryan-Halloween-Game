extends EnemyBase

func _ready() -> void:
	enemy_kind = &"pumpkin"
	attack_interval = 2.8
	attack_texture = preload("res://assets/PumpkinAttackSprite.png")
	projectile_scene = preload("res://scenes/EnemyProjectile.tscn")
	super._ready()

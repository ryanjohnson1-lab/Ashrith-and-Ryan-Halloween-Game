extends Node2D

@export var pumpkin_scene: PackedScene
@export var ghost_scene: PackedScene
@export var candy_scene: PackedScene
@export var witch_scene: PackedScene
@export var game_over_audio: AudioStream
@export var starting_lives: int = 3
@export var candy_texture: Texture2D = preload("res://assets/CandySprite.png")

var score := 0
var lives := 3
var game_over := false
var game_paused := false
var background_clock := 0.0
var rng := RandomNumberGenerator.new()

@onready var enemies: Node2D = $Enemies
@onready var background: Sprite2D = $Background
@onready var background_next: Sprite2D = $BackgroundNext
@onready var spawn_timer: Timer = $SpawnTimer
@onready var witch: CharacterBody2D = $Witch
@onready var score_label: Label = $HUD/ScoreLabel
@onready var lives_container: HBoxContainer = $HUD/LivesContainer
@onready var overlay: ColorRect = $HUD/GameOverOverlay
@onready var pause_overlay: ColorRect = $HUD/PauseOverlay
@onready var result_label: Label = $HUD/GameOverOverlay/ResultLabel
@onready var game_over_player: AudioStreamPlayer = $GameOverAudio
@onready var resume_button: Button = $HUD/PauseOverlay/PausePanel/ResumeButton
@onready var restart_button: Button = $HUD/PauseOverlay/PausePanel/RestartButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	enemies.process_mode = Node.PROCESS_MODE_PAUSABLE
	spawn_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	witch.process_mode = Node.PROCESS_MODE_PAUSABLE
	get_tree().paused = false
	rng.randomize()
	lives = starting_lives
	game_over_player.stream = game_over_audio
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	resume_button.pressed.connect(_resume_game)
	restart_button.pressed.connect(restart)
	spawn_timer.wait_time = 2.5
	spawn_timer.start()
	_update_hud()

func _process(delta: float) -> void:
	if game_over or game_paused:
		return
	background_clock += delta
	var background_frame := int(background_clock * 1.25) % 2
	background.frame = background_frame
	background_next.frame = background_frame
	var scroll_speed := 70.0
	var background_width := background.texture.get_width() / float(background.hframes) * background.scale.x
	background.position.x -= scroll_speed * delta
	background_next.position.x -= scroll_speed * delta
	if background.position.x <= -background_width:
		background.position.x = background_next.position.x + background_width
	if background_next.position.x <= -background_width:
		background_next.position.x = background.position.x + background_width
	var difficulty := float(score) / 100.0
	var new_wait := maxf(2.0, 2.5 - difficulty * 0.05)
	if absf(spawn_timer.wait_time - new_wait) > 0.02:
		spawn_timer.wait_time = new_wait

func _on_spawn_timer_timeout() -> void:
	if game_over:
		return
	var roll := rng.randf()
	var scene := pumpkin_scene if roll < 0.38 else (ghost_scene if roll < 0.72 else candy_scene)
	var enemy := scene.instantiate() as EnemyBase
	enemy.position = Vector2(get_viewport_rect().size.x + 40.0, rng.randf_range(70.0, get_viewport_rect().size.y - 70.0))
	enemy.fall_speed = rng.randf_range(180.0, 230.0)
	enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	enemy.player_hit.connect(_on_enemy_player_hit)
	enemies.add_child(enemy)

func _on_enemy_destroyed(_value: int) -> void:
	if game_over:
		return
	score += 100
	_update_hud()

func _on_enemy_player_hit() -> void:
	lose_life()

func lose_life() -> void:
	if game_over:
		return
	lives -= 1
	_update_hud()
	if lives <= 0:
		end_game()

func end_game() -> void:
	if game_over:
		return
	game_over = true
	game_paused = false
	get_tree().paused = false
	pause_overlay.visible = false
	spawn_timer.stop()
	witch.set_physics_process(false)
	result_label.text = "FINAL SCORE  %06d\nPRESS ENTER TO RESTART" % score
	overlay.visible = true
	if game_over_player.stream:
		game_over_player.play()

func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not game_over:
			_set_paused(not game_paused)
		get_viewport().set_input_as_handled()
		return
	if game_over and event.is_action_pressed("ui_accept"):
		restart()

func _set_paused(value: bool) -> void:
	game_paused = value
	pause_overlay.visible = game_paused
	get_tree().paused = game_paused

func _resume_game() -> void:
	_set_paused(false)

func _update_hud() -> void:
	score_label.text = "SCORE  %06d" % score
	for icon in lives_container.get_children():
		icon.queue_free()
	for _i in range(maxi(lives, 0)):
		var candy := TextureRect.new()
		candy.texture = candy_texture
		candy.custom_minimum_size = Vector2(34.0, 34.0)
		candy.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		candy.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lives_container.add_child(candy)

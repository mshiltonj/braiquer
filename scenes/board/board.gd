extends Node2D
@export var STARTING_PLAYER_LIVES = 3
@export var rows = 9
@export var columns = 11
@export var CAMERA_SHAKE_STRENGTH = 5.0
@export var CAMERA_SHAKE_DECAY = 8.0

@onready var remaining_lives = STARTING_PLAYER_LIVES
@onready var hud = %HUD
@onready var camera = %Camera
@onready var ball = %Ball
@onready var play_again_button = %HUD/GameOverContainer/VBoxContainer/MarginContainer/VBoxContainer/PlayAgainButton
@onready var quit_button = %HUD/GameOverContainer/VBoxContainer/MarginContainer/VBoxContainer/QuitButton
@onready var game_over_container = %HUD/GameOverContainer
@onready var camera_shake_rng = RandomNumberGenerator.new()
@onready var wave2_timer = %Wave2Timer
@onready var block_layer = %BlockLayer
@onready var start_container = $HUD/StartContainer
@onready var pause_container = $HUD/PauseContainer
@onready var ball_lost_sound = $BallLostSound


var shake_strength = 0.0
var wave1_blocks = 0 
var wave1_finished = false
var wave2_started = true
var block_scene


func back_to_main():
	get_tree().change_scene_to_file("res://scenes/main-menu.tscn")
	pass

func _ready():
	block_scene = preload("res://entities/block.tscn")
	ball.connect("ball_collision", ball_collision_handler)
	ball.connect("ball_lost", ball_lost_handler)
	ball.connect("ball_started", ball_started_handler)
	quit_button.connect("pressed", func():
		back_to_main()
	)
	play_again_button.connect("pressed", reset_game)
	wave2_timer.connect('timeout', spawn_wave2_block)
	start_container.visible = true
	
	start_game()

func reset_game():
	clear_game()
	start_game()
	
	
func clear_game():
	for block_node in get_tree().get_nodes_in_group("Block"):
		block_node.collision_layer = 0
		block_node.collision_mask = 0
		block_node.queue_free()
	
func start_game():
	shake_strength = 0.0
	start_container.visible = true
	remaining_lives = STARTING_PLAYER_LIVES
	wave1_finished = false
	wave2_started = false
	hud.reset_score()
	game_over_container.visible = false
	#print("RESETTING GAME")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	var padding = 12
	var offset_top = 115
	var offset_left = 150
	for column in columns:
		for row in rows:
			var block = block_scene.instantiate()
			var y = (row * block.height) + (padding * row) + offset_top
			var x = (column * block.width) + (padding * column) + offset_left
			block.global_position.x = x
			block.global_position.y = y
			block.destroyed.connect(self.block_destroyed_handler)
			block.destroyed.connect(hud.collect_points)
			wave1_blocks += 1
			block_layer.add_child(block)
			
	ball.reset_ball()
	
func ball_started_handler():
	start_container.visible = false

func ball_lost_handler():
	#print("BALL LOST")
	ball_lost_sound.play()
	remaining_lives -= 1
	if remaining_lives <= 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		ball.velocity = Vector2(0,0)
		#print("GAME OVER")
		game_over_container.visible = true

	else:
		ball.reset_ball()

func block_destroyed_handler(_block):
	wave1_blocks -= 1
	#print("wave1_blocks " + str(wave1_blocks))
	#print("wave1_finished " + str(wave1_finished))
	if wave1_finished == false && wave1_blocks <= 0:
		wave1_finished = true
		wave2_started = true
		spawn_wave2_block()
		
func spawn_wave2_block():
	if ! wave2_started:
		return
	
	var block = block_scene.instantiate()
	var rand_row = camera_shake_rng.randi_range(1, 5)
	var y = rand_row * 42 + 114
	var x = 2000
	block.global_position.x = x
	block.global_position.y = y
	block.destroyed.connect(self.block_destroyed_handler)
	block.destroyed.connect(hud.collect_points)
	block.scrolling_block = true
	block.velocity = Vector2(-1, 0) * 300
	block_layer.add_child(block)
	
	if wave2_started:
		wave2_timer.start()

func ball_collision_handler():
	print("ball collision handled")
	shake_strength = CAMERA_SHAKE_STRENGTH
	pass
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE and not get_tree().paused:
			print("PAUSING!!!")
			pause()

func pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	pause_container.visible = true
	print("PAUSE CONTAINER VISIBLE: " + str(pause_container.visible))

func unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_container.visible = false
	get_tree().paused = false
	
func restart():
	reset_game();
	unpause()

func _process(delta):
	shake_strength = lerp(shake_strength, 0.0 , CAMERA_SHAKE_DECAY * delta)
	camera.offset = get_camera_offset()
	pass

func get_camera_offset():
	return Vector2(
		camera_shake_rng.randf_range(-shake_strength, shake_strength),
		camera_shake_rng.randf_range(-shake_strength, shake_strength)
	)


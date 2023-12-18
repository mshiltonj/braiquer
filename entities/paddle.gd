extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var mouse = null

# Get the gravity from the project settings to be synced with RigidBody nodes.

@onready var bounce_sound = %BounceSound
@onready var sprite = %PaddleSprite
@onready var hit_particles = %HitParticles	


func get_width():
	return sprite.texture.get_width()
	
func get_height():
	return sprite.texture.get_height()

func _physics_process(_delta):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_HIDDEN:
		return

	var mouse_position = get_global_mouse_position()
	
	global_position.x = clamp(5, mouse_position.x, 1920 - 145 )
	
func been_hit(_pos : Vector2):
	bounce_sound.play()
	hit_particles.emitting = true

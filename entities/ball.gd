extends CharacterBody2D


const SPEED = 600.0

@onready var is_ball_lost = false

@onready var started = false
@onready var timer = %StartTimer
@onready var sprite = %BallSprite
@onready var rng = RandomNumberGenerator.new()
@onready var current_speed = SPEED

signal ball_lost
signal ball_collision
signal ball_started
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 0

func get_width():
	return sprite.texture.get_width()
	
func get_height():
	return sprite.texture.get_height()
	
func _input(event):
	if event is InputEventMouseButton:
		started = true
		ball_started.emit()

func _ready():
	reset_ball()

func reset_ball():
	velocity = get_random_direction().normalized() * SPEED
	global_position.x = 860
	global_position.y = 700
	current_speed = SPEED
	is_ball_lost=false
	started = false

func start():
	started = true

func _physics_process(delta):

	if ! started:
		return
			
	if global_position.y > DisplayServer.screen_get_size().y + 12 && ! is_ball_lost:
		is_ball_lost = true
		ball_lost.emit()
		started = false
		
	var collision = move_and_collide(velocity * delta)
	
	if (! collision):
		return
		
	var collider = collision.get_collider()
	if collision.get_collider().has_method('been_hit') :
		collision.get_collider().been_hit(self.global_position)
		ball_collision.emit()
	
	if collider.is_in_group('paddle'):
		var ballx = global_position.x + (get_width() / 2)
		var paddlex = collider.global_position.x + (collider.get_width() / 2)
		var diff = ballx - paddlex
		#print("BALL POS: %.03f" % ballx)
		#print("PADD POS: %.03f" % paddlex)
		#print("DIFFERENCE: %.03f" % diff)
		#print("PADDLE WIDTH: %.03f" % collider.get_width())
		var bounce_angle_surface = Vector2(diff / collider.get_width() /2, -0.5)
		#print("wat1", bounce_angle_surface)
		#print("wat1", bounce_angle_surface.normalized())
		velocity *= 1.02
		velocity = velocity.bounce(bounce_angle_surface.normalized())			
	else:
		velocity = velocity.bounce(collision.get_normal())

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#velocity.y = direction.y * SPEED
	#velocity.x =  direction.x * SPEED

func get_random_direction():
	return Vector2(
		rng.randf_range(-2.5, 2.5),
		1,
	)

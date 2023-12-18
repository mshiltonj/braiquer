extends CharacterBody2D


@export var width = 150
@export var height = 30
@export var speed = 0
@export var scrolling_block = false 

@export var dead_fall_speed = 600
@onready var death_timer = %DeathTimer
@onready var dead = false
@onready var hit_sound = %HitSound
@onready var hit_particles = %HitParticles
@onready var points = 10
signal destroyed(ball)

func _ready():
	#print(velocity)
	#velocity = Vector2(0,0)
	pass

func been_hit(pos : Vector2):
	dead = true
	hit_sound.play()
	hit_particles.global_position = pos
	if OS.get_name() != "Web":
		hit_particles.emitting = true
	emit_signal("destroyed", self)
	collision_layer = 0
	collision_mask = 0
	velocity.y = dead_fall_speed
	var tween = create_tween()
	tween.tween_property(self, 'modulate', Color.TRANSPARENT, 0.5)
	death_timer.start()
	death_timer.timeout.connect(func():
		queue_free()
	)
	
func _physics_process(delta):
	
	move_and_collide(velocity * delta)
		
	if global_position.x < -200:
		queue_free()

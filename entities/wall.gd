extends StaticBody2D

@onready var bounce_sound = %BounceSound
@onready var hit_particles = %HitParticles

func been_hit(pos: Vector2):
	bounce_sound.play()
	if OS.get_name() != "Web":
		hit_particles.global_position = pos
		hit_particles.emitting = true

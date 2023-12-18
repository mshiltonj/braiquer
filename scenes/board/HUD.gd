extends Control

@onready var score = 0;
@onready var score_label = %ScoreLabel
@onready var ball = %Ball

func reset_score():
	score = 0

func _process(_delta):
	score_label.text = "Score: " + str(score)
	
func collect_points(block):
	score += block.points

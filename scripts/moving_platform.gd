extends Node2D

@export var speed: float = 0.25
@export var speed_curve: Curve

@onready var _path_follow: PathFollow2D	 = $PathFollow2D

var progress: float

func _physics_process(delta):
	if !speed_curve: return
	
	progress += delta * speed
	_path_follow.progress_ratio = speed_curve.sample(pingpong(progress, 1.0))

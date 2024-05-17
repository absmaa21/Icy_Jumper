extends Camera2D


@export var target: CharacterBody2D
## The lowest amount of zoom that can happen.
## This is used to define the zoom when the velocity reaches max_velocity.
@export var min_zoom: float = 8.0
## The highest amount of zoom that can happen.
## This is used to define the zoom when stationary.
@export var max_zoom: float = 10.0
@export var max_velocity: float = 100.0
@export var zoom_speed: float = 0.8


func _process(delta: float) -> void:
	if target == null: return
	
	var velocity = clamp(target.velocity.length_squared(), 0.0, max_velocity * max_velocity) / (max_velocity * max_velocity)
	var velocity_zoom = lerp(min_zoom, max_zoom, velocity)
	zoom.x = lerp(zoom.x, velocity_zoom, delta * zoom_speed)
	zoom.y = lerp(zoom.y, velocity_zoom, delta * zoom_speed)

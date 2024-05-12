extends CharacterBody2D


const SPEED = 70.0
const JUMP_VELOCITY = -500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var latest_jump_load_start = -1.0
var is_jump_loading = false

@onready var animated_sprite = $AnimatedSprite2D


func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		animated_sprite.play("jump")
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_jump_loading = true
		animated_sprite.play("jump_load")
		latest_jump_load_start = Time.get_ticks_msec()
	if Input.is_action_just_released("jump") and is_on_floor() and latest_jump_load_start > -1:
		is_jump_loading = false
		var time_since_load_jump = (Time.get_ticks_msec() - latest_jump_load_start) / 1000.0
		print(time_since_load_jump)
		var jump_power = 0
		if time_since_load_jump > 1:
			jump_power = 1
		elif time_since_load_jump < 0.3:
			jump_power = 0.3
		else:
			jump_power = time_since_load_jump
		velocity.y = JUMP_VELOCITY * jump_power
		latest_jump_load_start = -1
		
	var direction = Input.get_axis("left", "right")
	if is_on_floor() and not latest_jump_load_start > 0:
		velocity.x = 0
		animated_sprite.play("idle")
	elif not is_jump_loading:
		if direction:
			velocity.x = direction * SPEED

	move_and_slide()

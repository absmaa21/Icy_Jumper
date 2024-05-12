extends CharacterBody2D


const SPEED = 70.0
const JUMP_VELOCITY = -500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jump_loading = false
var deltaTimeSinceStart = 0
var changedDirectionInAir = false

@onready var animated_sprite = $AnimatedSprite2D


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		animated_sprite.play("jump")
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		is_jump_loading = true
		animated_sprite.play("jump_load")
		deltaTimeSinceStart += delta
	if Input.is_action_just_released("jump") and is_on_floor():
		is_jump_loading = false
		print(deltaTimeSinceStart)
		var jump_power = clamp(deltaTimeSinceStart, 0.1, 0.7)
		velocity.y = JUMP_VELOCITY * jump_power
		deltaTimeSinceStart = 0
	
	if not is_on_floor() and (Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right")):
		changedDirectionInAir = true
	
	var direction = Input.get_axis("left", "right")
	if is_on_floor() and not deltaTimeSinceStart > 0:
		resetMoveVelocity()
		animated_sprite.play("idle")
	elif not is_jump_loading and not is_on_floor():
		if direction:
			if changedDirectionInAir:
				velocity.x = direction * 0.4 * SPEED
			else:
				velocity.x = direction * SPEED
	else:
		resetMoveVelocity()

	move_and_slide()

func resetMoveVelocity():
	velocity.x = 0
	changedDirectionInAir = false

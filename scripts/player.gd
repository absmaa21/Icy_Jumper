extends CharacterBody2D

@export var speed: float = 70.0
@export var jump_velocity: float = -500.0
@export var mid_air_direction_movment: float = 0.3
@export var jump_direction_movement: float = 1.2
@export var min_jump_charge_time: float = 0.1
@export var max_jump_charge_time: float = 0.7
@export var auto_jump_on_max_charge_time_reached: bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jump_loading = false
var deltaTimeSinceStart = 0
var changedDirectionInAir = false
var isFallingFromHigh = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var fall_time = $FallTime

@onready var jump_sound = $Sounds/Jump
@onready var fall_onto_ground_sound = $Sounds/FallOntoGround


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if velocity.y < 0: # is jumping
			animated_sprite.play("jump")
		elif velocity.y > 0: # is falling
			if fall_time.is_stopped() or fall_time.paused:
				fall_time.start()
			animated_sprite.play("fall")
		velocity.y += gravity * delta

	# Handle Landing
	if is_on_floor() and isFallingFromHigh:
		handleLandingEffects()

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		is_jump_loading = true
		animated_sprite.play("jump_load")
		deltaTimeSinceStart += delta
	if (Input.is_action_just_released("jump") or (deltaTimeSinceStart >= max_jump_charge_time and auto_jump_on_max_charge_time_reached)) and is_on_floor():
		is_jump_loading = false
		print(deltaTimeSinceStart)
		var jump_power = clamp(deltaTimeSinceStart, min_jump_charge_time, max_jump_charge_time)
		velocity.y = jump_velocity * jump_power
		deltaTimeSinceStart = 0
		jump_sound.play()

	# Handle air movement
	if not is_on_floor() and (Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right")):
		changedDirectionInAir = true

	# Handle movement
	var direction = Input.get_axis("left", "right")
	changeSpriteDirection(direction)
	if is_on_floor() and not deltaTimeSinceStart > 0:
		resetMoveVelocity()
	elif not is_jump_loading and not is_on_floor():
		if direction:
			if changedDirectionInAir:
				velocity.x = direction * mid_air_direction_movment * speed
			else:
				velocity.x = direction * jump_direction_movement * speed
	else:
		resetMoveVelocity()

	move_and_slide()

func handleLandingEffects():
	if isFallingFromHigh:
		fall_onto_ground_sound.play()
		animated_sprite.play("fell_from_high")
	isFallingFromHigh = false

func resetMoveVelocity():
	if animated_sprite.animation != 'fell_from_high' and not is_jump_loading:
		animated_sprite.play("idle")
	velocity.x = 0
	changedDirectionInAir = false
	fall_time.stop()

func changeSpriteDirection(direction):
	if animated_sprite.animation == 'fell_from_high':
		return

	if animated_sprite.flip_h:
		if direction <= 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false
	
	else:
		if direction >= 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true

func _on_fall_time_timeout():
	isFallingFromHigh = true

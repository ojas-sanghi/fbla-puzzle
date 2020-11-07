extends Actor
class_name Player

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer

# # We use separate functions to calculate the direction and velocity to make this one easier to read.
# At a glance, you can see that the physics process loop:
	# 1. Calculates the move direction.
	# 2. Calculates the move velocity.
	# 3. Moves the character.
	# 4. Updates the sprite direction.
	# 5. Shoots bullets.
	# 6. Updates the animation.
func _physics_process(delta):
	var direction = get_direction()

	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)

	var is_snapping = Vector2.DOWN * 60.0 if direction.y == 0.0 else Vector2.ZERO
	if in_antigravity:
		is_snapping = Vector2(0, 0)
	_velocity = move_and_slide_with_snap(
		_velocity, is_snapping, FLOOR_NORMAL, true, 4,  0.9, true
	)
	# When the character’s direction changes, we want to to scale the Sprite accordingly to flip it.
	# This will make Robi face left or right depending on the direction you move.
	if direction.x != 0:
		sprite.scale.x = direction.x

	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func get_direction():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-Input.get_action_strength("jump") if is_on_floor() and Input.is_action_just_pressed("jump") else 0.0
	)


# This function calculates a new velocity whenever you need it.
# It allows you to interrupt jumps.
func calculate_move_velocity(
		linear_velocity,
		direction,
		speed,
		is_jump_interrupted
	):
	var velocity = linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		velocity.y = 0.0
	return velocity


func get_new_animation():
	var animation_new = ""
	if is_on_floor():
		animation_new = "walk" if abs(_velocity.x) > 0.1 else "idle"
	else:
		animation_new = "fall" if _velocity.y > 0 else "jump"
	return animation_new

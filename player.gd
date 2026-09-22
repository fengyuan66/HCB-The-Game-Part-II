extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500

const MAX_JUMPS = 2
var jumps_left = MAX_JUMPS



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		jumps_left = MAX_JUMPS

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()



	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)

		if collision.get_collider() == get_node("../Deadly"):
			set_physics_process(false)
			get_tree().call_deferred("reload_current_scene")
			return

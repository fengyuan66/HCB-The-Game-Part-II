extends CharacterBody2D

@export var appearances: Array[Texture2D] = []
@export var lifetime: float = 30.0


func _ready() -> void:
	if not appearances.is_empty():
		$Sprite2D.texture = appearances.pick_random()
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

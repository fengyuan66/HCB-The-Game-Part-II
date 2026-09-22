extends Node



@export var sponsorships_needed: int = 3
@export_range(0.0, 1.0) var acceptance_chance: float = 0.6
@export var interaction_distance: float = 300
@export var spawn_interval: float = 5
@export var max_sponsors: int = 15
@export var spawn_left: float = 0.0
@export var spawn_right: float = 18500
@export var spawn_y: float = -400
var sponsorships: int = 0
var won: bool = false

const SPONSOR_SCENE = preload("res://sponsor.tscn")
@onready var player: CharacterBody2D = $Player
@onready var sponsors: Node2D = $Sponsors
@onready var station: Node2D = $Skytrain
@onready var spawn_timer: Timer = $SpawnTimer
@onready var status: Label = $HUD/Status


func _ready() -> void:
	spawn_timer.timeout.connect(_spawn_sponsor)
	spawn_timer.start(spawn_interval)

	for i in range(3):
		_spawn_sponsor()

	_show_message("Press E to ask out a sponsor")


func _spawn_sponsor() -> void:
	if won or sponsors.get_child_count() >= max_sponsors:
		return
		
	var sponsor := SPONSOR_SCENE.instantiate() as CharacterBody2D
	sponsors.add_child(sponsor)

	sponsor.global_position = Vector2(randf_range(spawn_left, spawn_right), spawn_y)


func _process(_delta: float) -> void:
	if won or not player.is_physics_processing():
		return

	if Input.is_action_just_pressed("interact"):
		_interact()
		
	if Input.is_action_just_pressed("cheat"):
		sponsorships += 3
		_show_message("Called daddy's connections")


func _interact() -> void:
	var target: Node2D = null
	var station_distance := player.global_position.distance_to(station.global_position)
	var closest: float = interaction_distance
	
	if station_distance <= closest:
		target = station
		closest = station_distance


	for sponsor in sponsors.get_children():
		if sponsor.is_queued_for_deletion():
			continue

		var distance = player.global_position.distance_to(sponsor.global_position)
		if distance < closest:
			target = sponsor
			closest = distance

	if target == null:
		_show_message("Too far from sponsor!")
	elif target == station:
		_interact_with_station()
	else:
		if randf() < acceptance_chance:
			sponsorships += 1
			_show_message("Sure! We will sponsor you")
		else:
			_show_message("*Ghosted*")
		target.queue_free()
			


func _interact_with_station() -> void:
	if sponsorships < sponsorships_needed:
		var remaining := sponsorships_needed - sponsorships
		_show_message("You don't have enough sponsors")
		return

	won = true
	spawn_timer.stop()
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	_show_message("Yay!!! Good job today boys you can go home")


func _show_message(message: String)-> void:
	status.text = str("Sponsorships: ", sponsorships, " / ", sponsorships_needed, "\n", message)

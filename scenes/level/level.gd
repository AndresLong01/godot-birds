extends Node2D

const ANIMAL = preload("res://scenes/animal/animal.tscn")
@onready var animal_spawn = $AnimalSpawn

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_animal_died.connect(add_animal)
	add_animal()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_animal() -> void:
	var new_animal = ANIMAL.instantiate()
	new_animal.position = animal_spawn.position
	add_child(new_animal)
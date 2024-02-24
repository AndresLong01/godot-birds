extends TextureButton

@onready var level = $MC/VBoxContainer/Level
@onready var score = $MC/VBoxContainer/Score

@export var level_number: int = 1

const HOVER_SCALE: Vector2 = Vector2(1.1, 1.1)
const DEFAULT_SCALE: Vector2 = Vector2(1.0, 1.0)

var levelScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	level.text = str(level_number)
	var bestScore = ScoreManager.get_best_for_level(str(level_number))
	score.text = str(bestScore)
	levelScene = load("res://scenes/level/level%s.tscn" % level_number)

func _on_pressed():
	ScoreManager.set_level_selected(level_number)
	get_tree().change_scene_to_packed(levelScene)

func _on_mouse_entered():
	scale = HOVER_SCALE

func _on_mouse_exited():
	scale = DEFAULT_SCALE

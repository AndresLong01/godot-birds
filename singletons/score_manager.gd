extends Node

const DEFAULT_SCORE: int = 1000
const SCORES_PATH = "user://animals.json"

var levelSelected: int = 1
var levelScores: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	load_from_disc()

func set_level_selected(level: int) -> void:
	levelSelected = level

func get_level_selected() -> int:
	return levelSelected

func check_and_add(level: String) -> void:
	if levelScores.has(level) == false:
		levelScores[level] = DEFAULT_SCORE

func set_score_for_level(score: int, level: String):
	check_and_add(level)
	if levelScores[level] > score:
		levelScores[level] = score
		save_to_disc()

func get_best_for_level(level: String) -> int:
	check_and_add(level)
	return levelScores[level]

func save_to_disc():
	var file = FileAccess.open(SCORES_PATH, FileAccess.WRITE)
	var scoreJsonStr = JSON.stringify(levelScores)
	file.store_string(scoreJsonStr)

func load_from_disc():
	var file = FileAccess.open(SCORES_PATH, FileAccess.READ)
	if file == null:
		save_to_disc()
	else:
		var data = file.get_as_text()
		levelScores = JSON.parse_string(data)

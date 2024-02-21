extends RigidBody2D

@onready var label = $Label

enum ANIMAL_STATE { READY, DRAG, RELEASE }

const DRAG_LIM_MAX: Vector2 = Vector2(0, 60)
const DRAG_LIM_MIN: Vector2 = Vector2(-60, 0)

var state: ANIMAL_STATE = ANIMAL_STATE.READY
var startPosition: Vector2 = Vector2.ZERO
var dragStart: Vector2 = Vector2.ZERO
var draggedVector: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	startPosition = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update(delta)
	label.text = "%s\n" % ANIMAL_STATE.keys()[state]
	label.text += "%.1f, %.1f" % [draggedVector.x, draggedVector.y]	

func set_new_state(new_state: ANIMAL_STATE) -> void:
	state = new_state
	if state == ANIMAL_STATE.RELEASE:
		freeze = false
	elif state == ANIMAL_STATE.DRAG:
		dragStart = get_global_mouse_position()

func detect_release() -> bool:
	if state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released("drag") == true:
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false

func get_dragged_vector(gmp: Vector2) -> Vector2:
	return gmp - dragStart

func drag_in_limits() -> void:
	draggedVector.x = clampf(draggedVector.x, DRAG_LIM_MIN.x, DRAG_LIM_MAX.x)
	draggedVector.y = clampf(draggedVector.y, DRAG_LIM_MIN.y, DRAG_LIM_MAX.y)
	
	position = startPosition + draggedVector

func update_drag() -> void:
	if detect_release() == true:
		return
	
	var globalMousePosition = get_global_mouse_position()
	draggedVector = get_dragged_vector(globalMousePosition)
	drag_in_limits()

func update(delta: float) -> void:
	match state:
		ANIMAL_STATE.DRAG:
			update_drag()

func die() -> void:
	SignalManager.on_animal_died.emit()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	die()


func _on_input_event(viewport, event, shape_idx):
	if state == ANIMAL_STATE.READY and event.is_action_pressed("drag"):
		set_new_state(ANIMAL_STATE.DRAG)

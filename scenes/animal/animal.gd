extends RigidBody2D

@onready var label = $Label
@onready var stretch_sound = $StretchSound
@onready var arrow = $Arrow
@onready var launch_sound = $LaunchSound
@onready var collision_sound = $CollisionSound

enum ANIMAL_STATE { READY, DRAG, RELEASE }

const DRAG_LIM_MAX: Vector2 = Vector2(0, 60)
const DRAG_LIM_MIN: Vector2 = Vector2(-60, 0)
const IMPULSE_MULT: float = 15.0
const IMPULSE_MAX: float = 1200.0

var state: ANIMAL_STATE = ANIMAL_STATE.READY
var startPosition: Vector2 = Vector2.ZERO
var dragStart: Vector2 = Vector2.ZERO
var draggedVector: Vector2 = Vector2.ZERO
var lastDraggedVector: Vector2 = Vector2.ZERO
var arrowScaleX: float = 0.0
var lastCollisionCount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	arrowScaleX = arrow.scale.x
	arrow.hide()
	startPosition = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update(delta)
	label.text = "%s\n" % ANIMAL_STATE.keys()[state]
	label.text += "%.1f, %.1f" % [draggedVector.x, draggedVector.y]	

func get_impulse() -> Vector2:
	return draggedVector * -1 * IMPULSE_MULT

func set_release() -> void:
	arrow.hide()
	freeze = false
	apply_central_impulse(get_impulse())
	launch_sound.play()
	SignalManager.on_attempt_made.emit()

func set_drag() -> void:
	dragStart = get_global_mouse_position()
	arrow.show()

func set_new_state(new_state: ANIMAL_STATE) -> void:
	state = new_state
	if state == ANIMAL_STATE.RELEASE:
		set_release()
	elif state == ANIMAL_STATE.DRAG:
		set_drag()

func detect_release() -> bool:
	if state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released("drag") == true:
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false

func scale_arrow() -> void:
	var impulseLength = get_impulse().length()
	var percentage = impulseLength / IMPULSE_MAX
	
	arrow.scale.x = (arrowScaleX * percentage) + arrowScaleX
	
	arrow.rotation = (startPosition - position).angle()

func play_stretch_sound() -> void:
	if(lastDraggedVector - draggedVector).length() > 0:
		if stretch_sound.playing == false:
			stretch_sound.play()

func get_dragged_vector(gmp: Vector2) -> Vector2:
	return gmp - dragStart

func drag_in_limits() -> void:
	lastDraggedVector = draggedVector
	
	draggedVector.x = clampf(draggedVector.x, DRAG_LIM_MIN.x, DRAG_LIM_MAX.x)
	draggedVector.y = clampf(draggedVector.y, DRAG_LIM_MIN.y, DRAG_LIM_MAX.y)
	
	position = startPosition + draggedVector

func update_drag() -> void:
	if detect_release() == true:
		return
	
	var globalMousePosition = get_global_mouse_position()
	draggedVector = get_dragged_vector(globalMousePosition)
	play_stretch_sound()
	drag_in_limits()
	scale_arrow()

func play_collision() -> void:
	if(lastCollisionCount == 0 and get_contact_count() > 0 and collision_sound.playing == false):
		collision_sound.play()
	
	lastCollisionCount = get_contact_count()

func update_flight() -> void:
	play_collision()

func update(_delta: float) -> void:
	match state:
		ANIMAL_STATE.DRAG:
			update_drag()
		ANIMAL_STATE.RELEASE:
			update_flight()

func die() -> void:
	SignalManager.on_animal_died.emit()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	die()

func _on_input_event(_viewport, event, _shape_idx):
	if state == ANIMAL_STATE.READY and event.is_action_pressed("drag"):
		set_new_state(ANIMAL_STATE.DRAG)

func _on_sleeping_state_changed():
	if sleeping == true:
		var bodies = get_colliding_bodies()
		
		if bodies.size() > 0:
			bodies[0].vanish()
		
		call_deferred("die")

@tool
extends HSlider
class_name HSliderResizable

@export var end_fill_on_center_of_graber:bool=true
@export var grabber_centered_on_limits:bool=true
@export_storage var _initialized := false
		
@onready var fill_container:Control
@onready var fill:Control
@onready var grabber_container:Control
@onready var grabber:Control

var _active:bool = false
var _ratio_before_dragging:float = 0.0
var _start_pos:float = 0.0
var _start_ratio:float = 0.0

var _default_scene:PackedScene
	
func _get_default_scene() -> PackedScene:
	return preload("res://addons/h_slider_resizable/scenes/h_slider_resizable_default.tscn")
	
func _get_fill_container()->Control:
	return $Track/FillContainer

func _get_fill()->Control:
	return $Track/FillContainer/FillWrapper/Fill

func _get_grabber_container()->Control:
	return $GrabberContainer
	
func _get_grabber()->Control:
	return $GrabberContainer/GrabberWrapper/Grabber

func _value_changed(_new_value: float) -> void:
	_update_ui(_new_value)

func _notification(what):
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		_update_ui(value)
		
func _ready() -> void:
	if _default_scene == null:
		_default_scene = _get_default_scene()

	if Engine.is_editor_hint() and not _initialized:
		_on_reset_children()
		_initialized = true
	else:
		_bind_ui()
	
	_update_ui(value)

func _bind_ui()->void:
	fill_container = _get_fill_container()
	fill = _get_fill()
	grabber_container = _get_grabber_container()
	grabber = _get_grabber()
	
	if grabber:
		if not grabber.resized.is_connected(_on_grabber_resized):
			grabber.resized.connect(_on_grabber_resized)
	
	if not gui_input.is_connected(_on_gui_input):
		gui_input.connect(_on_gui_input)

func _update_ui(_value:float) -> void:
	if not is_inside_tree() or not fill or not grabber:
		return
	
	var visual_value:float = ratio
	
	fill.anchor_right = visual_value
	grabber.anchor_left = visual_value
	grabber.anchor_right = visual_value

func _update_margins() -> void:
	if not grabber or not grabber_container or not fill_container:
		return
		
	var margin_value=0.0
	if !grabber_centered_on_limits:
		margin_value = grabber.size.y / 2.0
		
	fill.offset_left=-margin_value
	if !end_fill_on_center_of_graber:
		fill.offset_right=margin_value
	else:
		fill.offset_right=0
		
	fill_container.add_theme_constant_override("margin_left", margin_value)
	fill_container.add_theme_constant_override("margin_right", margin_value)
	grabber_container.add_theme_constant_override("margin_left", margin_value)
	grabber_container.add_theme_constant_override("margin_right", margin_value)

func _on_reset_children()-> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	var instance = _default_scene.instantiate()
	
	for child in instance.get_children():
		ReparentHelper.reparent(child, self)
	
	instance.queue_free()
	_bind_ui()
	_update_ui(value)

func _on_grabber_resized() -> void:
	_update_margins()

func _on_gui_input(event:InputEvent)->void:
	if event is InputEventMouseButton:
		_on_mouse_button(event)
	elif event is InputEventMouseMotion:
		_on_mouse_motion(event)
	else:
		_on_joypad_input(event)

func _on_mouse_button(event:InputEventMouseButton)->void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_pos=event.position.x
			_ratio_before_dragging=ratio
			var _max:float = size.x - grabber.size.x
			set_block_signals(true)
			ratio=(_start_pos)/_max
			set_block_signals(false)
			drag_started.emit()
			_active=true
			_start_ratio=ratio
			value_changed.emit(value)
		else:
			_active=false
			var has_changed:bool = is_equal_approx(_ratio_before_dragging,ratio)
			drag_ended.emit(has_changed)
	elif scrollable:
		if event.pressed:
			if get_focus_mode_with_override()!=FOCUS_NONE:
				grab_focus()
				
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				value=value+step
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				value=value-step

func _on_mouse_motion(event:InputEventMouseMotion)->void:
	if _active:
		var _motion:float = event.position.x - _start_pos
		var _area_size:float = size.x
		if _area_size<=0: return
		if is_layout_rtl():
			_motion=-_motion
		var _motion_ratio:float=_motion/_area_size
		ratio=_start_ratio+_motion_ratio

func _on_joypad_input(event:InputEvent)->void:
	var is_joypad_action:bool=event is InputEventJoypadButton or event is InputEventJoypadMotion
	if event.is_action_pressed("ui_left"):
		if is_joypad_action:
			if !Input.is_action_just_pressed_by_event("ui_left", event, true):
				return
			set_process_internal(true)
		if is_layout_rtl():
			value=value+step
		else:
			value=value-step
		accept_event()
	elif event.is_action_pressed("ui_right"):
		if is_joypad_action:
			if !Input.is_action_just_pressed_by_event("ui_right", event, true):
				return
			set_process_internal(true)
		if is_layout_rtl():
			value=value-step
		else:
			value=value+step
		accept_event()
	elif event.is_action("ui_home") and event.is_pressed():
		value=min_value
		accept_event()
	elif event.is_action("ui_end") and event.is_pressed():
		value=max_value
		accept_event()

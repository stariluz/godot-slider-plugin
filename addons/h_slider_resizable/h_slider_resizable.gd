@tool
extends HSlider
class_name HSliderResizable

@export var end_fill_on_center_of_graber:bool=true

@export_storage var _initialized := false

@onready var track_margin:Control = $Track/TrackContainer
@onready var track_fill:Control = $Track/TrackContainer/TrackWrapper/TrackFill
@onready var grabber_margin:Control = $GrabberContainer
@onready var grabber:Control = $GrabberContainer/GrabberWrapper/Grabber

var _active:bool = false
var _ratio_before_dragging:float = 0.0
var _start_pos:float = 0.0
var _start_ratio:float = 0.0

func _value_changed(_new_value: float) -> void:
	_update_ui(_new_value)

func _notification(what):
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		_update_ui(value)
		
func _ready() -> void:
	if Engine.is_editor_hint() and not _initialized:
		_reset_children()
		_initialized = true
	else:
		_bind_ui()
	
	_update_ui(value)

func _reset_children()-> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	var default_scene = preload("res://addons/h_slider_resizable/scenes/h_slider_resizable_default.tscn")
	var instance = default_scene.instantiate()
	
	for child in instance.get_children():
		ReparentHelper.reparent(child, self)
	
	instance.queue_free()
	_bind_ui()
	_update_ui(value)
	

func _bind_ui()->void:
	track_margin = $Track/TrackContainer
	track_fill = $Track/TrackContainer/TrackWrapper/TrackFill
	grabber_margin = $GrabberContainer
	grabber = $GrabberContainer/GrabberWrapper/Grabber
	
	if grabber:
		if not grabber.resized.is_connected(_on_grabber_resized):
			grabber.resized.connect(_on_grabber_resized)
	
	if not gui_input.is_connected(_on_gui_input):
		gui_input.connect(_on_gui_input)


func _update_ui(_value:float) -> void:
	if not is_inside_tree() or not track_fill or not grabber:
		return
	
	var visual_value:float = ratio
	
	track_fill.anchor_right = visual_value
	grabber.anchor_left = visual_value
	grabber.anchor_right = visual_value


func _update_margins() -> void:
	if not grabber or not grabber_margin or not track_margin:
		return
		
	var margin_value = grabber.size.y / 2.0
	
	track_fill.offset_left=-margin_value
	if !end_fill_on_center_of_graber:
		track_fill.offset_right=margin_value
	else:
		track_fill.offset_right=0
		
	track_margin.add_theme_constant_override("margin_left", margin_value)
	track_margin.add_theme_constant_override("margin_right", margin_value)
	grabber_margin.add_theme_constant_override("margin_left", margin_value)
	grabber_margin.add_theme_constant_override("margin_right", margin_value)
	

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

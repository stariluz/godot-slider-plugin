@tool
extends HSlider
class_name HSliderResizable

enum GrabberAlignmentMode{
	MANUAL,
	PROPORTIONAL_TO_GRABBER_HEIGHT
}

@export var grabber_alignment_mode:GrabberAlignmentMode = GrabberAlignmentMode.PROPORTIONAL_TO_GRABBER_HEIGHT:
	set(value):
		grabber_alignment_mode=value
		_update_margins()
		
@export var fill_offset:float=0.0:
	set(value):
		fill_offset=value
		_update_margins()
		
@export_storage var _initialized:bool = false
@export_storage var _alignment_ratio:AlignmentRatios = AlignmentRatios.new()
		
@onready var fill_container:Control
@onready var fill:Control
@onready var grabber_container:Control
@onready var grabber:Control

var _active:bool = false
var _ratio_before_dragging:float = 0.0
var _start_pos:float = 0.0
var _start_ratio:float = 0.0

var _default_scene:PackedScene
	
func _load_default_scene() -> PackedScene:
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
	_update_ui()

func _notification(what):
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		_update_ui()
		
func _ready() -> void:
	if _default_scene == null:
		_default_scene = _load_default_scene()

	if Engine.is_editor_hint() and not _initialized:
		reset_children()
		_initialized = true
	else:
		_bind_ui()
	
	_update_margins()
	_update_ui()

func get_state():
	var scene := PackedScene.new()
	scene.pack(self)
	return scene
	
func set_state(state:PackedScene) -> void:
	if state == null:
		return
	
	ReparentHelper.clean_children(self)
	
	var instance = state.instantiate()
	
	for child in instance.get_children():
		ReparentHelper.reparent(child, self)
	
	instance.queue_free()
	_restore_properties(instance)
	
	await get_tree().process_frame
	_bind_ui()
	_update_margins()
	_update_ui()
	
func _restore_properties(instance:HSliderResizable):
	if !instance is HSliderResizable:
		return
	
	self._alignment_ratio=instance._alignment_ratio
	
func reset_children()-> void:
	set_state(_default_scene)
	
func save_alignment_ratio()->void:
	_alignment_ratio=AlignmentRatios.new(
		grabber_container.offset_left/grabber.size.y,
		grabber_container.offset_right/grabber.size.y,
		grabber.size.x/grabber.size.y,
		grabber.offset_left/grabber.size.y,
		grabber.offset_right/grabber.size.y,
	) 
	print(_alignment_ratio)
	
func _bind_ui()->void:
	fill_container = _get_fill_container()
	fill = _get_fill()
	grabber_container = _get_grabber_container()
	grabber = _get_grabber()
	
	if not self.resized.is_connected(_on_resized):
		self.resized.connect(_on_resized)
	
	if not gui_input.is_connected(_on_gui_input):
		gui_input.connect(_on_gui_input)

func _update_ui() -> void:
	if not is_inside_tree() or not fill or not grabber:
		return
	
	var visual_value:float = ratio
	
	fill.anchor_right = visual_value
	grabber.anchor_left = visual_value
	grabber.anchor_right = visual_value

func _update_margins() -> void:
	if not grabber or not grabber_container or not fill_container:
		return
	
	if grabber_alignment_mode == GrabberAlignmentMode.PROPORTIONAL_TO_GRABBER_HEIGHT:
		#print("UPDATE MARGINS")
		#self.print_debug(grabber_container)
		#self.print_debug(grabber.get_parent())
		#self.print_debug(grabber)
		#
		#print(_alignment_ratio)
		
		grabber_container.offset_left=grabber.size.y*_alignment_ratio.offset_left
		grabber_container.offset_right=grabber.size.y*_alignment_ratio.offset_right
		grabber.size.x=grabber.size.y*_alignment_ratio.inner_size_ratio
		grabber.offset_left=grabber.size.y*_alignment_ratio.inner_offset_left
		grabber.offset_right=grabber.size.y*_alignment_ratio.inner_offset_right
	
func print_debug(a: Node) -> void:
	print(a.name," p:", a.position, " ol:", a.offset_left, " or:", a.offset_right, " s:", a.size)

func _on_resized() -> void:
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
			value_changed.emit()
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

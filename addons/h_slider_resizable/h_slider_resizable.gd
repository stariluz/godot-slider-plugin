@tool
extends HSlider
class_name HSliderResizable

@export_storage var _initialized := false

@onready var fill = $TrackContainer/Track/TrackFill
@onready var thumb_margin = $ThumbContainer
@onready var thumb = $ThumbContainer/ThumbWrapper/Thumb

func _value_changed(_new_value: float) -> void:
	_update_ui()

func _notification(what):
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		_update_ui()
		
func _ready() -> void:
	if Engine.is_editor_hint() and not _initialized:
		_reset_children()
		_initialized = true
	
	if thumb:
		if not thumb.resized.is_connected(_on_thumb_resized):
			thumb.resized.connect(_on_thumb_resized)
	
	_update_ui()

func _reset_children()-> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	var default_scene = preload("res://addons/h_slider_resizable/scenes/h_slider_resizable_default.tscn")
	var instance = default_scene.instantiate()
	
	for child in instance.get_children():
		ReparentHelper.reparent(child, self)
		
	instance.queue_free()
	
func _update_ui() -> void:
	if not is_inside_tree() or not fill or not thumb:
		return
	
	fill.anchor_right = value
	thumb.anchor_left = value
	thumb.anchor_right = value

func _update_margins() -> void:
	if not thumb or not thumb_margin:
		return
		
	var margin_value = thumb.size.y / 2.0
	
	thumb_margin.add_theme_constant_override("margin_left", margin_value)
	thumb_margin.add_theme_constant_override("margin_right", margin_value)
	
func _on_thumb_resized() -> void:
	_update_margins()

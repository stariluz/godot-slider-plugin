@tool
extends Range
class_name HSliderResizable

@onready var fill = $BorderMargin/ShaderedSubViewportContainer/SubViewport/Background/Fill
@onready var grabber_margin = $GrabberMargin
@onready var grabber = $GrabberMargin/GrabberParent/Grabber

func _value_changed(_new_value: float) -> void:
	_update_ui()

func _notification(what):
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		_update_ui()
		
func _ready() -> void:
	if grabber:
		if not grabber.resized.is_connected(_on_grabber_resized):
			grabber.resized.connect(_on_grabber_resized)
	
	_update_ui()
		
func _update_ui() -> void:
	if not is_inside_tree() or not fill or not grabber:
		return
	
	fill.anchor_right = value
	grabber.anchor_left = value
	grabber.anchor_right = value

func _update_margins() -> void:
	if not grabber or not grabber_margin:
		return
		
	var margin_value = grabber.size.y / 2.0
	
	grabber_margin.add_theme_constant_override("margin_left", margin_value)
	grabber_margin.add_theme_constant_override("margin_right", margin_value)
	
func _on_grabber_resized() -> void:
	_update_margins()

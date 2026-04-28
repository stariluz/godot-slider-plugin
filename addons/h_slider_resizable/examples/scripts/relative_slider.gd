@tool
extends HSliderResizable

func _get_fill_container()->Control:
	return $Track/FillContainer

func _get_fill()->Control:
	return $Track/FillContainer/FillWrapper/Fill

func _get_grabber_container()->Control:
	return $GrabberContainer
	
func _get_grabber()->Control:
	return $GrabberContainer/GrabberWrapper/AspectRatioContainer

func _load_default_scene() -> PackedScene:
	return preload("res://addons/h_slider_resizable/scenes/h_slider_resizable_default.tscn")

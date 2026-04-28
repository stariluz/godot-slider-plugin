@tool
extends HSliderResizable

func _get_fill_container()->Control:
	return $TrackBorder/SubViewportContainer/SubViewport/Track/TrackFillContainer

func _get_fill()->Control:
	return $TrackBorder/SubViewportContainer/SubViewport/Track/TrackFillContainer/TrackWrapper/TrackFill

func _get_grabber_container()->Control:
	return $TrackBorder/GrabberContainer
	
func _get_grabber()->Control:
	return $TrackBorder/GrabberContainer/GrabberWrapper/Grabber

func _load_default_scene() -> PackedScene:
	return preload("res://addons/h_slider_resizable/scenes/h_slider_resizable_default.tscn")

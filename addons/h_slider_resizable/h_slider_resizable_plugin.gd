@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("HSliderResizable", "Slider", preload("h_slider_resizable.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type("HSliderResizable")

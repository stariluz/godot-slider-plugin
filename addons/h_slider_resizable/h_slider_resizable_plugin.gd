@tool
extends EditorPlugin

const SliderResizablePlugin = preload("h_slider_resizable.gd")
const ResetSliderPlugin = preload("reset_slider_inspector_plugin.gd")
var reset_slider_plugin = ResetSliderPlugin.new()


func _enter_tree():
	add_custom_type("HSliderResizable", "Slider", SliderResizablePlugin, preload("icon.svg"))
	add_inspector_plugin(reset_slider_plugin)


func _exit_tree():
	remove_custom_type("HSliderResizable")
	remove_inspector_plugin(reset_slider_plugin)

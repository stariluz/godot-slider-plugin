extends EditorInspectorPlugin

func _can_handle(object):
	return object is HSliderResizable
	
func _parse_begin(object):
	var button = Button.new()
	button.text = "Reset Slider Structure"
	
	var dialog = ConfirmationDialog.new()
	dialog.title = "Confirm Reset"
	dialog.dialog_text = "Are you sure you want to reset the slider structure?"
	EditorInterface.get_base_control().add_child(dialog)
	
	button.pressed.connect(func():
		dialog.popup_centered()
		dialog.show()
	)
	
	dialog.confirmed.connect(func():
		var obj:HSliderResizable=object
		obj._on_reset_children()
	)
	
	add_custom_control(button)

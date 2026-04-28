extends EditorInspectorPlugin

func _can_handle(object):
	return object is HSliderResizable
	
func _parse_begin(object:Object):
	init_reset_button(object)
	init_alignment_button(object)

func init_reset_button(object:HSliderResizable):
	var action:String ="Reset children to default scene"
	var button = Button.new()
	button.text = "Reset Slider Structure"
	
	var dialog = ConfirmationDialog.new()
	dialog.title = "Confirm Reset"
	dialog.dialog_text = "Are you sure you want to reset the slider structure?"
	
	bind_controls(button,dialog, func():
		var undo_redo = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action(action)
		var previous_state = object.get_state()
		undo_redo.add_do_method(object, object.reset_children.get_method())
		undo_redo.add_undo_method(object, object.set_state.get_method(), previous_state)
		undo_redo.commit_action()
	)
	
func init_alignment_button(object:HSliderResizable):
	var action:String ="Save new alignment ratio for grabber"
	var button = Button.new()
	button.text = "Save current alignment ratio"
	button.tooltip_text = "The ratio will only be applied if Grabber Alignment is 'Proportional to grabber height'."
	#button.add_theme_color_override("background",Color.DODGER_BLUE)
	
	var dialog = ConfirmationDialog.new()
	dialog.title = "Confirm new proportion?"
	dialog.dialog_text = "This change is unreversable. The last proportion will be lost."
	
	bind_controls(button, dialog, func():
		var undo_redo = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action(action)
		var previous_state = object.get_state()
		undo_redo.add_do_method(object, object.save_alignment_ratio.get_method())
		undo_redo.add_undo_method(object, object.set_state.get_method(), previous_state)
		undo_redo.commit_action()
	)


func bind_controls(button:Button, dialog:AcceptDialog, command:Callable):
	EditorInterface.get_base_control().add_child(dialog)
	
	button.pressed.connect(func():
		dialog.popup_centered()
		dialog.show()
	)
	
	dialog.confirmed.connect(command)
	add_custom_control(button)

extends EditorInspectorPlugin

func _can_handle(object):
	return object is HSliderResizable
	
func _parse_category(object, category):
	if object is HSliderResizable and category == "h_slider_resizable.gd":
		var obj:HSliderResizable=object
		if obj.debug_mode:
			print(_parse_category)
		var container = VBoxContainer.new()
		var button1=init_reset_button(obj)
		var button2=init_alignment_button(obj)
		var separator=create_separator()
		container.add_child(button1)
		container.add_child(separator)
		container.add_child(button2)
		add_custom_control(container)
	
func create_separator():
	var separator=HSeparator.new()
	separator.add_theme_constant_override("separation",2)
	separator.add_theme_stylebox_override("separator",StyleBoxEmpty.new())
	return separator
	
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
	return button
	
func init_alignment_button(object:HSliderResizable):
	var action:String ="Save new alignment ratios for slider"
	var button = Button.new()
	button.text = "Save current alignment ratios"
	button.tooltip_text = "The ratios will only be applied if Grabber Alignment is 'Proportional to grabber height'."
	#button.add_theme_color_override("background",Color.DODGER_BLUE)
	
	var dialog = ConfirmationDialog.new()
	dialog.title = "Confirm new alignment?"
	dialog.dialog_text = "Remember this plugin is yet experimental, so it is posible that the history of changes can broke in unexpected cases. Use this action with caution."
	
	button.visible = not object.autosave_alignment_ratios
	if object.autosave_alignment_ratios_changed.is_connected(_on_autosave_alignment_ratios_changed):
		object.autosave_alignment_ratios_changed.disconnect(_on_autosave_alignment_ratios_changed)
	object.autosave_alignment_ratios_changed.connect(
		_on_autosave_alignment_ratios_changed.bind(object, button)
	)
		
	bind_controls(button, dialog, func():
		var undo_redo = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action(action)
		var previous_state = object.get_state()
		undo_redo.add_do_method(object, object.save_alignment_ratios.get_method())
		undo_redo.add_undo_method(object, object.set_state.get_method(), previous_state)
		undo_redo.commit_action()
	)
	return button

func bind_controls(button:Button, dialog:AcceptDialog, command:Callable):
	EditorInterface.get_base_control().add_child(dialog)
	
	button.pressed.connect(func():
		dialog.popup_centered()
		dialog.show()
	)
	
	dialog.confirmed.connect(command)

func _on_autosave_alignment_ratios_changed(object, button):
	button.visible = not object.autosave_alignment_ratios

class_name ReparentHelper

static func clean_children(parent:Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
		
static func reparent(child:Node, parent:Node) -> void:
	child.owner=null
	if child is Control:
		ReparentHelper.print_debug(child)
		
	child.reparent(parent,false)
	_set_owner_recursive(child, parent.get_tree().edited_scene_root)
		
static func _set_owner_recursive(node: Node, new_owner: Node) -> void:
	node.owner = new_owner
	
	if node is Control:
		ReparentHelper.print_debug(node)
		
	for child in node.get_children():
		_set_owner_recursive(child, new_owner)
		

static func print_debug(a: Node) -> void:
	return
	print(a.name," p:", a.position, " ol:", a.offset_left, " or:", a.offset_right, " s:", a.size)

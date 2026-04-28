class_name ReparentHelper

static func clean_children(parent:Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
		
static func reparent(child:Node, parent:Node) -> void:
		child.owner=null
		
		child.reparent(parent,false)
		#child.position=Vector2.ZERO
		_set_owner_recursive(child, parent.get_tree().edited_scene_root)
		
static func _set_owner_recursive(node: Node, new_owner: Node) -> void:
	node.owner = new_owner
	for child in node.get_children():
		_set_owner_recursive(child, new_owner)
		

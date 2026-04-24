class_name ReparentHelper

static func reparent(child:Node, parent:Node) -> void:
		child.owner=null
		child.reparent(parent)
		child.position=Vector2.ZERO
		_set_owner_recursive(child, parent.get_tree().edited_scene_root)
		
static func _set_owner_recursive(node: Node, new_owner: Node) -> void:
	node.owner = new_owner
	for child in node.get_children():
		_set_owner_recursive(child, new_owner)
		

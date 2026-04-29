extends Resource
class_name AlignmentRatios

@export_storage var offset_left:float=0.0
@export_storage var offset_right:float=0.0
@export_storage var inner_size_ratio:float=0.0
@export_storage var inner_offset_left:float=0.0
@export_storage var inner_offset_right:float=0.0

func _init(
	_offset_left: float = 0.0,
	_offset_right: float = 0.0,
	_inner_size_ratio: float = 0.0,
	_inner_offset_left: float = 0.0,
	_inner_offset_right: float = 0.0
):
	offset_left = _offset_left
	offset_right = _offset_right
	inner_size_ratio = _inner_size_ratio
	inner_offset_left = _inner_offset_left
	inner_offset_right = _inner_offset_right
	

func _to_string() -> String:
	return "AlignmentRatios(%s, %s, %s, %s, %s)" % [
		offset_left,
		offset_right,
		inner_size_ratio,
		inner_offset_left,
		inner_offset_right
	]

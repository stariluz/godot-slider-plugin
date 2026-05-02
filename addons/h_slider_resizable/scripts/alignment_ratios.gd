
@tool
extends Resource
class_name AlignmentRatios

@export_storage var grabber_container_offset_left:float=0.0
@export_storage var grabber_container_offset_right:float=0.0
@export_storage var grabber_size_ratio:float=0.0
@export_storage var grabber_offset_left:float=0.0
@export_storage var grabber_offset_right:float=0.0
@export_storage var fill_offset_left:float=0.0
@export_storage var fill_offset_right:float=0.0
@export_storage var fill_container_offset_left:float=0.0
@export_storage var fill_container_offset_right:float=0.0

func _init(
	_grabber_container_offset_left: float = 0.0,
	_grabber_container_offset_right: float = 0.0,
	_grabber_size_ratio: float = 0.0,
	_grabber_offset_left: float = 0.0,
	_grabber_offset_right: float = 0.0,
	_fill_offset_left: float = 0.0,
	_fill_offset_right: float = 0.0,
	_fill_container_offset_left: float = 0.0,
	_fill_container_offset_right: float = 0.0
):
	grabber_container_offset_left = _grabber_container_offset_left
	grabber_container_offset_right = _grabber_container_offset_right
	grabber_size_ratio = _grabber_size_ratio
	grabber_offset_left = _grabber_offset_left
	grabber_offset_right = _grabber_offset_right
	fill_offset_left = _fill_offset_left
	fill_offset_right = _fill_offset_right
	fill_container_offset_left = _fill_container_offset_left
	fill_container_offset_right = _fill_container_offset_right
	

func _to_string() -> String:
	return "AlignmentRatios(gc_ol: %s, gc_or: %s, g_sr: %s, g_ol%s, g_or%s, f_ol%s, f_or%s, fc_ol%s, fc_or%s)" % [
		grabber_container_offset_left,
		grabber_container_offset_right,
		grabber_size_ratio,
		grabber_offset_left,
		grabber_offset_right,
		fill_offset_left,
		fill_offset_right,
		fill_container_offset_left,
		fill_container_offset_right
	]
	
static func calculate_ratios(grabber:Control, grabber_container:Control, fill:Control, fill_container:Control)->AlignmentRatios:
	return AlignmentRatios.new(
		grabber_container.offset_left/grabber.size.y,
		grabber_container.offset_right/grabber.size.y,
		grabber.size.x/grabber.size.y,
		grabber.offset_left/grabber.size.y,
		grabber.offset_right/grabber.size.y,
		fill.offset_left/grabber.size.y,
		fill.offset_right/grabber.size.y,
		fill_container.offset_left/grabber.size.y,
		fill_container.offset_right/grabber.size.y,
	) 

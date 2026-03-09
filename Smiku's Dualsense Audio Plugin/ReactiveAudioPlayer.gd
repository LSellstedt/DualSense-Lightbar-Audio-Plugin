@tool
extends AudioStreamPlayer

var _mixer: Node = null

enum AudioBus {}
## Put your desired audio bus channel name here. It's [b]not[/b] recommended to use the [b]Master[/b] audio bus.
@export var audio_bus: AudioBus:
	set(value):
		audio_bus = value
		_apply_bus()
	

@export_range(-80.0, 0.0, 0.1) var activity_threshold_db: float = -50.0
@export var sensitivity:float = 4.0

var _bus_index:int = -1
var _dualsense_id:int = -1

func _resolve_mixer() -> Node:
	if _mixer == null:
		_mixer = get_node_or_null("/root/ReactiveAudioMixer")
	return _mixer
	

func _validate_property(property: Dictionary):
	if property.name == "audio_bus":
		var options := ""
		for i in AudioServer.bus_count:
			if i > 0:
				options += ","
			options += AudioServer.get_bus_name(i)
		
		property.hint_string = options
	

func _apply_bus():
	if audio_bus >= 0 and audio_bus < AudioServer.bus_count:
		var name := AudioServer.get_bus_name(audio_bus)
		bus = name
		_bus_index = audio_bus
	

func _get_energy() -> float:
	if _bus_index == -1:
		return 0.0
	
	var l := AudioServer.get_bus_peak_volume_left_db(_bus_index, 0)
	var r := AudioServer.get_bus_peak_volume_right_db(_bus_index, 0)
	
	var peak_db := max(l, r)
	if peak_db < activity_threshold_db:
		return 0.0
	
	var energy := max(db_to_linear(l), db_to_linear(r))
	return clamp(energy * sensitivity, 0.0, 1.0)
	

func find_dualsense() -> int:
	for id in Input.get_connected_joypads():
		var name := Input.get_joy_name(id).to_lower()
		
		if "dualsense" in name or "wireless controller" in name:
			return id
	
	return -1
	

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if Engine.is_editor_hint():
		return
	
	_dualsense_id = find_dualsense()
	

func _ready():
	if Engine.is_editor_hint():
		return
	
	_apply_bus()
	
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_dualsense_id = find_dualsense()
	

func _process(delta):
	if Engine.is_editor_hint():
		return
	
	var mixer := _resolve_mixer()
	if mixer == null:
		return
	var energy := _get_energy()
	mixer.submit_energy(get_instance_id(), energy)
	

func _exit_tree():
	if not Engine.is_editor_hint():
		var mixer := _resolve_mixer()
		if mixer:
			mixer.remove(get_instance_id())
	

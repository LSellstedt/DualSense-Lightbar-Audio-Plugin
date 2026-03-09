## [/b]Recives whatever the two ReactiveAudioPlayers output and transform them into the colors shown on your [b]dualsense controller[/b].[b]
extends Node

var _energies := {}
var _dualsense_id := -1

var _current_energy := 0.0

var low_color := Color.BLUE
var mid_color := Color.YELLOW
var high_color := Color.RED

var color:Color

var low_threshold := 0.33

func _energy_to_color(e: float) -> Color:
	if e <= low_threshold:
		var t := e / low_threshold
		return low_color.lerp(mid_color, t)
	else:
		var t := (e - low_threshold) / (1.0 - low_threshold)
		return mid_color.lerp(high_color, t)
	

func _find_dualsense() -> int:
	for id in Input.get_connected_joypads():
		var name := Input.get_joy_name(id).to_lower()
		if "dualsense" in name or "wireless controller" in name:
			return id
	return -1
	

func _ready():
	_dualsense_id = _find_dualsense()
	

func submit_energy(id: int, energy: float):
	_energies[id] = energy
	

func remove(id: int):
	_energies.erase(id)
	

func _process(delta):
	if _dualsense_id == -1:
		return
	
	if _energies.is_empty():
		return
	
	var total := 0.0
	for e in _energies.values():
		total += e
	total = clamp(total, 0.0, 1.0)
	
	var smoothing := 5.0
	_current_energy = lerp(_current_energy, total, smoothing * delta)
	
	color = _energy_to_color(_current_energy)
	Input.set_joy_light(_dualsense_id, color)
	

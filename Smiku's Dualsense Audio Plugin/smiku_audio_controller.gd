@tool
extends EditorPlugin

const AUTOLOAD_NAME = "ReactiveAudioMixer"

func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/Smiku's Dualsense Audio Plugin/ReactiveAudioMixer.gd")
func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)

func _enter_tree() -> void:
	add_custom_type("ReactiveAudioPlayer3D", "AudioStreamPlayer3D", preload("res://addons/Smiku's Dualsense Audio Plugin/ReactiveAudioPlayer3D.gd"), preload("res://addons/Smiku's Dualsense Audio Plugin/Icons/ReactiveAudioPlayer3D.png"))
	add_custom_type("ReactiveAudioPlayer", "AudioStreamPlayer", preload("res://addons/Smiku's Dualsense Audio Plugin/ReactiveAudioPlayer.gd"), preload("res://addons/Smiku's Dualsense Audio Plugin/Icons/ReactiveAudioPlayer.png"))

func _exit_tree() -> void:
	remove_custom_type("ReactiveAudioPlayer3D")
	remove_custom_type("ReactiveAudioPlayer")

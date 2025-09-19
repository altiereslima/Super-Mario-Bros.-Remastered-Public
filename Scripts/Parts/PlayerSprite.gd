class_name PlayerSprite
extends AnimatedSprite2D

@export var player_id := 0
@export var force_power_state := ""
@export var force_character := ""
var character := ""

@export var resource_setter: ResourceSetterNew

static func get_char_path() -> String:
	var exe_dir = OS.get_executable_path().get_base_dir()
	var portable_flag = exe_dir.path_join("portable.txt")
	if FileAccess.file_exists(portable_flag):
		return exe_dir.path_join("config/custom_characters/")
	else:
		return "user://custom_characters/"
	
func _ready() -> void:
	Global.player_characters_changed.connect(update)
	Global.level_theme_changed.connect(update)
	update()

func update() -> void:
	character = Player.CHARACTERS[int(Global.player_characters[player_id])]
	var power_state = Global.player_power_states[player_id]
	if force_power_state != "":
		power_state = force_power_state
	if force_character != "":
		character = force_character
	if resource_setter != null:
		var path = "res://Assets/Sprites/Players/" + character + "/" + Player.POWER_STATES[int(power_state)] + ".json"
		if Player.CHARACTERS.find(character) > 3:
			path = path.replace("res://Assets/Sprites/Players/", get_char_path())
		var json = resource_setter.get_resource(load(path))
		sprite_frames = json
		if sprite_frames == null: 
			return
		if sprite_frames.get_frame_texture(animation, frame):
			offset.y = -(sprite_frames.get_frame_texture(animation, frame).get_height() / 2.0)

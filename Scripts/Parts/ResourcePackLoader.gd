extends Node
const RESOURCE_PACK_CONTAINER = preload("uid://lggi3b4310yl")

var resource_packs := []
var containers := []

static func get_resource_dir() -> String:
	var exe_dir = OS.get_executable_path().get_base_dir()
	var portable_flag = exe_dir.path_join("portable.txt")
	if FileAccess.file_exists(portable_flag):
		return exe_dir.path_join("config/resource_packs/")
	else:
		return "user://resource_packs"
	
func _ready() -> void:
	get_resource_packs()

func open_folder() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(get_resource_dir()), true)

func get_resource_packs() -> void:
	for i in containers:
		get_parent().options.erase(i)
		i.queue_free()
	containers = []
	resource_packs = []
	for i in DirAccess.get_directories_at(get_resource_dir()):
		resource_packs.append(i)
	for i in resource_packs:
		var pack_info_path = get_resource_dir() + i + "/" + "pack_info.json"
		if FileAccess.file_exists(pack_info_path) and i != Global.ROM_PACK_NAME:
			create_container(get_resource_dir() + i)

func create_container(resource_pack := "") -> void:
	var container = RESOURCE_PACK_CONTAINER.instantiate()
	container.pack_json = JSON.parse_string(FileAccess.open(resource_pack + "/pack_info.json", FileAccess.READ).get_as_text())
	if FileAccess.file_exists(resource_pack + "/config.json"):
		container.config = JSON.parse_string(FileAccess.open(resource_pack + "/config.json", FileAccess.READ).get_as_text())
		container.config_path = resource_pack + "/config.json"
	if FileAccess.file_exists(resource_pack + "/icon.png"):
		var image = Image.new()
		image.load(resource_pack + "/icon.png")
		container.icon = ImageTexture.create_from_image(image)
	elif FileAccess.file_exists(resource_pack + "/icon.gif"):
		container.icon = GifManager.animated_texture_from_file(resource_pack + "/icon.gif")
	container.pack_name = resource_pack.replace(get_resource_dir(), "")
	$"../ScrollContainer/VBoxContainer".add_child(container)
	containers.append(container)
	container.add_to_group("Options")
	container.open_config.connect(owner.open_pack_config_menu)
	get_parent().options.append(container)

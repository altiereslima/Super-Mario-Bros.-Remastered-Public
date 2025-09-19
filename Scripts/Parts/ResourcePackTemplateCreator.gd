extends Node

var files := []
var directories := []

const base_info_json := {
	"name": "New Pack",
	"description": "Template, give me a description!",
	"author": "Me, until you change it"
	}

static func get_resource_dir() -> String:
	var exe_dir = OS.get_executable_path().get_base_dir()
	var portable_flag = exe_dir.path_join("portable.txt")
	if FileAccess.file_exists(portable_flag):
		return exe_dir.path_join("config/resource_packs/")
	else:
		return "user://resource_packs/new_pack"
	
func create_template() -> void:
	var base_dir = get_resource_dir().path_join("new_pack")
	get_directories("res://Assets", files, directories)
	for i in directories:
		DirAccess.make_dir_recursive_absolute(i.replace("res://Assets", base_dir))
	for i in files:
		var destination = i
		if destination.contains("res://"):
			destination = i.replace("res://Assets", base_dir)
		else:
			destination = i.replace("user://resource_packs/BaseAssets", base_dir)
		print("Copying '" + i + "' to: '" + destination)
		if i.contains(".bgm") or i.contains(".json") or i.starts_with(base_dir):
			DirAccess.copy_absolute(i, destination)
		else:
			var resource = load(i)
			if resource is Texture:
				resource.get_image().save_png(destination)
			elif resource is AudioStream:
				var file = FileAccess.open(destination, FileAccess.WRITE)
				file.store_buffer(resource.data)
				file.close()
			
	var pack_info_path = base_dir.path_join("pack_info.json")
	DirAccess.make_dir_recursive_absolute(pack_info_path.get_base_dir())
	var file = FileAccess.open(pack_info_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(base_info_json, "\t"))
	file.close()
	print("Done")

func get_directories(base_dir := "", files := [], directories := []) -> void:
	for i in DirAccess.get_directories_at(base_dir):
		if base_dir.contains("LevelGuides") == false:
			directories.append(base_dir + "/" + i)
			get_directories(base_dir + "/" + i, files, directories)
			get_files(base_dir + "/" + i, files)

func get_files(base_dir := "", files := []) -> void:
	for i in DirAccess.get_files_at(base_dir):
		if base_dir.contains("LevelGuides") == false:
			i = i.replace(".import", "")
			print(i)
			var target_path = base_dir + "/" + i
			var rom_assets_path = target_path.replace("res://Assets", get_resource_dir() + "/BaseAssets")
			if FileAccess.file_exists(rom_assets_path):
				files.append(rom_assets_path)
			else:
				files.append(target_path)

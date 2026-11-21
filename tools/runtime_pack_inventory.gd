extends SceneTree
var entries: Array = []
func _walk(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null: return
	for name: String in directory.get_files():
		var full: String = path.path_join(name)
		entries.append({"path": full, "bytes": FileAccess.get_file_as_bytes(full).size(), "sha256": FileAccess.get_sha256(full)})
	for name: String in directory.get_directories():
		_walk(path.path_join(name))
func _initialize() -> void:
	_walk("res://")
	var output := FileAccess.open(OS.get_cmdline_user_args()[0], FileAccess.WRITE)
	output.store_string(JSON.stringify(entries, "\t"))
	output.close()
	print("P08_RUNTIME_INVENTORY_OK: ", entries.size())
	quit()

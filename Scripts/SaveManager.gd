class_name SaveManager

const SAVE_PATH:String = "user://VaultSaveData.tres"

static var saveData:SaveResource

static func save_resource() -> void:
	var saveError:Error = ResourceSaver.save(saveData, SAVE_PATH, ResourceSaver.FLAG_NONE)
	if ( saveError != OK ):
		print("Save Failure: [%s]" % saveError)

# resource loading/creation must be done before _ready() calls, so in an _enter_tree()
static func load_resource() -> void:
	if !ResourceLoader.exists(SAVE_PATH):
		print("Create Save")
		saveData = SaveResource.new()
	else:
		print("Load Save")
		saveData = ResourceLoader.load(SAVE_PATH)

static func clear_save() -> void:
	saveData = SaveResource.new()
	save_resource()

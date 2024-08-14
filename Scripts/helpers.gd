class_name Helpers

static func disable_and_hide_node(node:Node) -> void:
	node.process_mode = Node.PROCESS_MODE_DISABLED
	node.hide()

static func enable_and_show_node(node:Node) -> void:
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	node.show()

#func toggle_show_hide_node(node:Node) -> void:
	#if (node.process_mode == Node.PROCESS_MODE_DISABLED):
		#enable_and_show_node(node)
	#else:
		#disable_and_hide_node(node)

static func get_frame_string(node:Node) -> String:
	return "frame %s" % node.get_tree().get_frame()

extends Node

func disable_and_hide_node(node:Node) -> void:
	node.process_mode = Node.PROCESS_MODE_DISABLED
	node.hide()

func enable_and_show_node(node:Node) -> void:
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	node.show()

func get_frame_string() -> String:
	return "frame %s" % get_tree().get_frame()

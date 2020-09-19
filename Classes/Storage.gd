extends Node

class_name Storage

items = {}

func _init():
	pass

func get_class(): 
	return "Item"

func is_class( name : String ): 
	return name == "Storage"
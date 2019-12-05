extends Node

class_name Item

enum ITEM_TYPE { WEAPON, ARMOR, EQUIPMENT, CONSOLE, MODULE , SHIP_WEAPON , COMMODITY , QUEST }

var itemWeight = 0
var itemVolume = 0
var itemType = self.ITEM_TYPE.QUEST

func _init():
	pass

func get_class(): 
	return "Item"

func is_class( name : String ): 
	return name == "Item"
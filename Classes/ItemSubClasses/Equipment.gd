extends Item

class_name Equipment


var equipmentToHit 	= { 'base' : 0 , "mod" : 0 , "total" : 0 }
var equipmentToDmg	= { 'base' : 0 , "mod" : 0 , "total" : 0 }

# Action Key zero will be the default action
var equipmentActionKeys = []

func _ready():
	pass # Replace with function body.

func _init( key: String):
	self.itemKey = key
	self.itemTextureType = self.TEXTURE_GRID_TYPE.SINGLE

func get_class():
	return "Equipment"

func is_class( name : String ):
	return name == "Equipment"

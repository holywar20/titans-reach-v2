extends Item

class_name Weapon

var weaponToDmg = { 'base' : 0 , "mod" : 0 , "total" : 0 }
var weaponToHit = { 'base' : 0 , "mod" : 0 , "total" : 0 }

# Action Key zero will be the default action
var weaponActionKeys = []

func _ready():
	pass

func _init( key : String ):
	itemKey = key
	itemTextureType = TEXTURE_GRID_TYPE.ROW
# Overrides
func get_class(): 
	return "Weapon"

func is_class( name : String ): 
	return name == "Weapon"

func getAbilities():
	return weaponActionKeys
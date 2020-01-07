extends Item

class_name Frame

# Populated by Json
var frameArmorValue = 1
var frameClass = FRAME_CLASS.LIGHT

# FRAME_CLASS data
var frameClassString = "Light Frame"
var frameInitCost = 0
var frameWeight = 1
var frameActionKeys = []

enum FRAME_CLASS { LIGHT, MEDIUM, HEAVY, ASSAULT }
const FRAME_CLASS_DATA = [
	{ "frameClassString" : "Light" , "frameInitCost" : 0 , "frameWeight" : 1}, 
	{ "frameClassString" : "Heavy" , "frameInitCost"  : 2 , "frameWeight" : 2}, 
	{ "frameClassString" : "Medium" , "frameInitCost" : 4 , "frameWeight" : 3},
	{ "frameClassString" : "Assault"  , "frameInitCost" : 6 , "frameWeight" : 4}
]

func _init( key : String ):
	itemKey = key
	itemTextureType = TEXTURE_GRID_TYPE.COL

# Overrides
func get_class(): 
	return "Frame"

func is_class( name : String ): 
	return name == "Frame"

func getAbilities():
	return frameActionKeys


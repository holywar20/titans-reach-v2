extends Item

class_name Frame

# Populated by Json
var frameArmorValue = 1
var frameClass = self.FRAME_CLASS.LIGHT

# FRAME_CLASS data
var frameClassString = "Light Frame"
var frameInitCost = 0
var frameWeight = 1

enum FRAME_CLASS { LIGHT, MEDIUM, HEAVY, ASSAULT }
const FRAME_CLASS_DATA = [
	{ "frameClassString" : "Light" , "frameInitCost" : 0 , "frameWeight" : 1}, 
	{ "frameClassString" : "Heavy" , "frameInitCost"  : 2 , "frameWeight" : 2}, 
	{ "frameClassString" : "Medium" , "frameInitCost" : 4 , "frameWeight" : 3},
	{ "frameClassString" : "Assault"  , "frameInitCost" : 6 , "frameWeight" : 4}
]

func _init( key : String ):
	self.itemKey = key
	self.itemTextureType = self.TEXTURE_GRID_TYPE.COL

# Overrides
func get_class(): 
	return "Frame"

func is_class( name : String ): 
	return name == "Frame"

# TODO add sanity checks?
func equip():
	self.itemAssigned = self.itemAssigned + 1

# TODO add sanity checks?
func unequip():
	self.itemAssigned = self.itemAssigned - 1
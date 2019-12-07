extends Item

class_name Frame

var framePriTrait = null
var frameSecTrait = null

var frameArmorValue = 1
var frameArmorClass = "Light"
var frameRarity = "COMMON"

# Assigned and owned only apply to the starship. Though this object could be used by enemy crew.
var frameAssigned = 0
var frameOwned = 0

enum RARITY { COMMON , UNCOMMON , RARE , LEGENDARY , UNIQUE }
const RARITY_DATA = {
	"COMMON" 	: { "String" : "Common" 	,"Color" : Color(0 ,0 ,0 ,0) },
	"UNCOMMON"	: { "String" : "Uncommon" 	,"Color" : Color(0 ,0 ,0 ,0) },
	"RARE" 		: { "String" : "Rare" 		,"Color" : Color(0 ,0 ,0 ,0) },
	"LEGENDARY" : { "String" : "Legendary" ,"Color" : Color(0 ,0 ,0 ,0) },
	"UNIQUE" 	: { "String" : "Unique"		,"Color" : Color(0 ,0 ,0 ,0) }
}

const FRAME_CLASS = {
	"LIGHT" : "Light" , 
	"HEAVY" : "Heavy" , 
	"MEDIUM" : "Medium" , 
	"ASSAULT" : "Assault"
}

func _init( key : String ):
	self.itemKey = key

# Overrides
func get_class(): 
	return "Frame"

func is_class( name : String ): 
	return name == "Frame"

func getRemaining():
	return self.frameOwned - self.frameAssigned
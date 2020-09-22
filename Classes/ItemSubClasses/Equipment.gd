extends Item

class_name Equipment


var equipmentToHit 	= { 'base' : 0 , "mod" : 0 , "total" : 0 }
var equipmentToDmg	= { 'base' : 0 , "mod" : 0 , "total" : 0 }

# Action Key zero will be the default action
var equipmentActionKeys = []

func _ready():
	pass # Replace with function body.

func _init( dataDict : Dictionary ):
	self.prepareItem( dataDict );
	if( dataDict.defaultAbility ):
		equipmentActionKeys.insert( 0 , dataDict.defaultAbility )
	else:
		equipmentActionKeys.insert( 0 , null )

func get_class():
	return "Equipment"

func is_class( name : String ):
	return name == "Equipment"

func getAbilities():
	return equipmentActionKeys

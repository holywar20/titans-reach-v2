extends Node

class_name Item

# Texture grid size , used for determining Lock & Icon size in UI, meant to give equipment a distinct but simple profile
enum TEXTURE_GRID_TYPE { SINGLE, ROW, COL, BIG_SINGLE }
const TEXTURE_TYPES = [ # TODO - may not need this. Texture rects seem to scale correctly on their own.
	Vector2( 64 , 64) , Vector2( 128 , 64) , Vector2( 64, 128) , Vector2( 128 , 128 )
]

# Metadata universal to all items
var itemMass = 0
var itemVolume = 0
var itemValue = 0
var itemDisplayName = "Unassigned"
var itemDisplayNameShort = null
var itemKey = "Unassigned"
var itemTexturePath = "res://icon.png"
var itemTextureType = TEXTURE_GRID_TYPE.SINGLE

var itemOwned = 0
var itemAssigned = 0

# Metathat applies to crew equipable items
var itemIsCrewEquipable = false
var itemCarryWeight = 0
var itemRarity = RARITY.COMMON

# Meta

enum RARITY { COMMON , UNCOMMON , RARE , LEGENDARY , UNIQUE }
const RARITY_DATA = [
	{ "String" : "Common" 	,"Color" : Color(0 ,0 ,0 ,0) },
	{ "String" : "Uncommon" ,"Color" : Color(0 ,0 ,0 ,0) },
	{ "String" : "Rare" 		,"Color" : Color(0 ,0 ,0 ,0) },
	{ "String" : "Legendary","Color" : Color(0 ,0 ,0 ,0) },
	{ "String" : "Unique"	,"Color" : Color(0 ,0 ,0 ,0) }
]

func _init():
	pass

func get_class(): 
	return "Item"

func is_class( name : String ): 
	return name == "Item"

func prepareItem( dataDict ):
	self.itemKey = dataDict.itemKey
	self.itemMass = dataDict.itemMass
	self.itemVolume = dataDict.itemVolume
	self.itemValue = dataDict.itemValue
	self.itemDisplayName = dataDict.itemDisplayName
	self.itemDisplayNameShort = dataDict.itemDisplayNameShort
	self.itemTexturePath = dataDict.itemTexturePath
	self.itemTextureType = dataDict.itemTextureType

func setOwned( num ):
	itemOwned = num;

func getOwned( num ):
	return itemOwned;

func getItemDisplay( short = false ):
	if( short ):
		return itemDisplayNameShort
	else:
		return itemDisplayName

func getMassDisplay():
	return str( itemMass ) + " Kg"

func getVolumeDisplay():
	return str( itemVolume ) + " m3"

func getItemValueDisplay():
	return str( itemValue ) + " Ink"

func getRemaining():
	return itemOwned - itemAssigned

func addToAssigned():
	itemAssigned = itemAssigned + 1

func subFromAssigned():
	itemAssigned = itemAssigned - 1

# meant to be overridden. Should return an array of strings.
func getAbilities():
	return []

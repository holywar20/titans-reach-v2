extends Node

class_name Item

# Texture grid size , used for determining Lock & Icon size in UI, meant to give equipment a distinct but simple profile
enum TEXTURE_GRID_TYPE { SINGLE, ROW, COL, BIG_SINGLE }

var itemMass = 0
var itemVolume = 0
var itemValue = 0
var itemDisplayName = "Unassigned"
var itemDisplayNameShort = null
var itemKey = "Unassigned"
var itemTexturePath = "res://icon.png"
var itemTextureType = self.TEXTURE_GRID_TYPE.SINGLE

var itemWeight = 0

func _init():
	pass

func get_class(): 
	return "Item"

func is_class( name : String ): 
	return name == "Item"

func getMassDisplay():
	return str( self.itemMass ) + " Kg"

func getVolumeDisplay():
	return str( self.itemVolume ) + " m3"

func getItemValueDisplay():
	return str( self.itemValue ) + " Ink"
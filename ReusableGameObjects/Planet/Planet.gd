extends Node2D

class_name Planet

var eventBus = null

onready var nodes = {
	'sprite'		: get_node("Area/Sprite"),
	'nameLabel'	: get_node("Label")
}

var fullName = "name not set"
var planetSeed = null # TODO figure out how to get this number of the seed function.
var classification = null
var className = null 

# Meta data
var orbit = null
var atmopshere = null
var minerals = []
var radius = null
var mass = null
var temp = null
var color = null
var description = null
var radial = null


# Various Flags
var isBiopshere = false 
var isInhabitated = false 
var isHabitable = false 

#img DATA
var iconTexturePath = ""
var fullTexturePath = ""

func _ready():
	nodes.nameLabel.set_text( fullName )
	nodes.sprite.set_texture( load( fullTexturePath ) ) # DO we need an override for this?
	nodes.sprite.set_self_modulate( color )

func setEvents( eBus : EventBus ):
	eventBus = eBus

func _onAreaInputEvent( viewport, event, shape_idx ):
	if( event.is_action_pressed( "GUI_SELECT" ) ):
		eventBus.emit( "PlanetClickedStart" , [self] )

# Getters & Setters
func getIconTexturePath():
	return iconTexturePath

func getColor():
	return color

func getOrbit():
	return orbit

func getFullName():
	return fullName

func getDetailText():
	var bbcodeText = """[table][/table]"""

	return bbcodeText
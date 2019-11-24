extends Node2D

class_name Planet

onready var nodes = {
	'sprite'		: get_node("Sprite"),
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

# Various Flags
var isBiopshere = false 
var isInhabitated = false 
var isHabitable = false 


#img DATA
var iconTexturePath = ""
var fullTexturePath = ""

func _ready():
	self.nodes.nameLabel.set_text( self.fullName )
	self.nodes.sprite.set_texture( load( fullTexturePath ) ) # DO we need an override for this?
	self.nodes.sprite.set_self_modulate( self.color )

func _onAreaInputEvent( viewport, event, shape_idx ):
	if( Input.is_mouse_button_pressed( BUTTON_LEFT ) ):
		pass # TODO - link to event bus.
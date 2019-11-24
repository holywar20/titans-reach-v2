extends RigidBody2D

var planetObject

signal SpaceItemSelect # TODO - move this over to the event bus

func _ready():
	var TravelUINode = get_node( Common.TRAVEL_SCENE )
	self.connect("SpaceItemSelect", TravelUINode, "updateTravelSelect")

func setPlanetScale( scaleVector ):
	self.set_scale( scaleVector )

func constructPlanet( inputObject ):
	self.planetObject = inputObject
	
	$PlanetName.set_text( self.planetObject.planetName )
	$Sprite.set_texture( self.planetObject.largeTexture )
	$Sprite.set_self_modulate( self.planetObject.planetColor )
	
	self.set_scale( Vector2( self.planetObject.radius , self.planetObject.radius ) )

func _onAreaInputEvent( viewport, event, shape_idx ):
	if( Input.is_mouse_button_pressed( BUTTON_LEFT ) ):
		self.emit_signal( "SpaceItemSelect" , "Planet" , self.planetObject )

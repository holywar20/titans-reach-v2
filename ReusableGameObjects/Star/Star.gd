extends Node2D

class_name Star

onready var nodes = {
	'sprite'		: get_node("Area2D/Sprite"),
	'nameLabel'	: get_node("Label")
}

const ORBIT_COUNT = 8 # should result in 9 orbits, due to index of zero being first planet.
const ORBIT_SIZE_FACTOR = 1000
const ORBIT_LINE_WIDTH = 5
const ORBIT_LINE_SEGMENTS = 128
const CONNECTION_COLOR = Color( .2, .4 , .2, .5)

var firstName = "X"
var lastName = "X"

# Class data
var starSeed = 0
var classification = "M"
var className = "Red Dwarf"
var boilLine = 0
var freezeLine = 0
var radius = 0
var temp = 0
var mass = 0
var orbitSize = 0
var color = Color( 0 , 0 ,0 , 0 )
var description = ""

# IMG Data
var smallTexturePath = "" 
var iconTexturePath = ""
var fullTexturePath = ""

# Star Metadata
var orbitArray = [ false , false , false, false, false, false, false, false, false, false ] # NOTE 9 valid orbits.
var connectionArray = []
var chanceOfPlanetPerOrbit = 100

var eventBus = EventBusStore.getEventBus( EventBusStore.BUS.EXPLORE )

enum TEXTURE{ FULL, SMALL , ICON }

func _ready():
	self.nodes.nameLabel.set_text( self.getName() )
	self.nodes.sprite.set_texture( load( self.fullTexturePath ) ) # DO we need an override for this?
	self.nodes.sprite.set_self_modulate( self.color )

func getName():
	return self.firstName + " " + self.lastName

func setOrbitState( orbit : int , state : bool ):
	self.orbitArray[orbit] = state 

func getOrbitalDistance( orbit: int ):
	return self.ORBIT_SIZE_FACTOR + ( self.orbitSize * orbit * ORBIT_SIZE_FACTOR )

func _draw():
	for orbit in range( 0, self.orbitArray.size() ):
		var orbitColor = Color( .2, .4, .2 , float(orbit) / 20 + .5  )
		
		if( orbitArray[orbit] ):
			var position = self.get_position()
			var orbitDistance = self.getOrbitalDistance( orbit )
			Common.drawCircle( position, orbitDistance , orbitColor , self , self.ORBIT_LINE_WIDTH , self.ORBIT_LINE_SEGMENTS )
	
	for connection in range( 0 , self.connectionArray.size() ):
		var radians = deg2rad( self.connectionArray[connection].degrees )
		var targetVector = Vector2( cos(radians) * 100000 , sin(radians) * 100000 ) 
		draw_line( Vector2(0, 0) , targetVector, self.CONNECTION_COLOR , self.ORBIT_LINE_WIDTH )

func setName( fName : String , lName: String ):
	self.firstName = fName
	self.lastName = lName

func _onAreaInputEvent( viewport, event, shape_idx ):
	if( event.is_action_pressed( "GUI_SELECT" ) ):
		self.eventBus.emit( "StarClickedStart" , self )